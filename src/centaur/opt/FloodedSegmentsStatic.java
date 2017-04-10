/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 15-03-2016
 * Description:
 * Computes the floodable network links for each of the possible gate 
 * locations in the network.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.opt;

import java.lang.Math;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Flooded;
import centaur.db.Link;
import centaur.db.VJunction;
import centaur.db.VConduit;


// TODO: Auto-generated Javadoc
/**
 * The Class FloodedSegmentsDynamic.
 */
public class FloodedSegmentsStatic extends FloodedSegments
{		
	/** The flooded links. */
	static ArrayList<Link> floodedLinks = new ArrayList<Link>();
	
	protected void resetFloodedLinks()
	{
		floodedLinks = new ArrayList<Link>();
	}
	
	/**
	 * Iterates through a set of Links identifying those floodable by the 
	 * current Candidate instance, updating the current overflow height. 
	 * Stops the analysis if the upstream Node is a pump or weir. Proceeds the
	 * analysis recursively for those inlet nodes whose height is lower than 
	 * the current overflow. 
	 *
	 * @param links the set of links with a common outlet.
	 * @param practicalFlow maximum practical flow downstream the node 
	 */
	protected void searchLinks(Set<Link> links, Double practicalFlow)
	{
		for (Link l : links)
		{
			// Pump: search stops at downstream junction
			if (l.getPump() != null) 
				updateCurrentOverflow(l.getNodeByIdNodeTo(), 0.0, null, null);

			// Weir: search stops at crest height
			else if (l.getWeir() != null) 
			{
				updateCurrentOverflow(
						l.getNodeByIdNodeTo(), 
						l.getWeir().getCrestHeight().doubleValue(), 
						null, null);
				if(!floodedLinks.contains(l)) floodedLinks.add(l);
			}
			
			// Conduit: search continues if upstream junction is lower than current overflow
			else
			{ 						
				if(!floodedLinks.contains(l)) floodedLinks.add(l);
				if(l.getNodeByIdNodeFrom().getElevation().doubleValue() < currentOverflow)
					analyseNode(l.getNodeByIdNodeFrom(), null, null);
			}
}
	}
	
	/**
	 * Updates the current overflow height. Takes depth as argument to allow
	 * alternative values, e.g. pump or wier. In the static caomputation the
	 * conduit and practical flow arguments are ignored. 
	 *
	 * @param n the node being analysed.
	 * @param depth the node depth (e.g. from groundsill to manhole lid).
	 */
	protected void updateCurrentOverflow(Node n, Double depth, VConduit vc, Double practicalFlow)
	{
		Double newLevel = n.getElevation().doubleValue() + depth - safetyMargin;
		if(newLevel < currentOverflow) 
			currentOverflow = newLevel;
	}
	
	/**
	 * Removes from the flooded Conduits array (floodedLinks) all those whose
	 * outlet is above the current Candidate overflow height. 
	 */
	protected void prune()
	{
		System.out.println("Number of links before: " + floodedLinks.size());
		for (Iterator<Link> it = floodedLinks.iterator(); it.hasNext(); ) 
		{
		    Link l = it.next();
		    Node arrivalNode = l.getNodeByIdNodeTo();
		    if (arrivalNode.getElevation().doubleValue() >= currentOverflow)
				it.remove();
		}
		System.out.println("Number of links after pruning: " + floodedLinks.size());
	}
	
	/**
	 * Saves a new Candidate instance to the database. It saves the respective
	 * flooded conduits (stored in floodedLinks) and computes the usable volume 
	 * in each conduit according to the Candidate overflow height.
	 *
	 * @param n the Node instance on which the Candidate is to be created.
	 */
	protected void save(Node n)
	{
		Candidate c = new Candidate(n, new BigDecimal(currentOverflow));
		session.save(c);
		for(Link l : floodedLinks)
		{
			Flooded f = new Flooded(c, l);
			double outletElev = l.getNodeByIdNodeTo().getElevation().doubleValue();
		    double inletElev = l.getNodeByIdNodeFrom().getElevation().doubleValue();
		    if (l.getNodeByIdNodeFrom().getElevation().doubleValue() >= currentOverflow)
		    	f.setVolumeFraction(new BigDecimal(
		    			(currentOverflow - outletElev) / (inletElev - outletElev)));
			session.save(f);
		}
	}

}
