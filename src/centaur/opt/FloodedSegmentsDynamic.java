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
public class FloodedSegmentsDynamic extends FloodedSegments
{	
	/** The flooded links and their respective practical flows. */
	protected HashMap<Link, Double> floodedLinks = new HashMap<Link, Double>();
	
	protected void resetFloodedLinks()
	{
		floodedLinks = new HashMap<Link, Double>();
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
		double newPracticalFlow;
		
		for (Link l : links)
		{
			VConduit vconduit = (VConduit) session.get(VConduit.class, l.getId());
			
			// Pump: search stops at downstream junction
			if (l.getPump() != null) 
				updateCurrentOverflow(l.getNodeByIdNodeTo(), 0.0, vconduit, practicalFlow);

			// Weir: search stops at crest height
			else if (l.getWeir() != null) 
			{
				newPracticalFlow = enqueueFlooded(l, 0, practicalFlow);
				updateCurrentOverflow(
						l.getNodeByIdNodeTo(), 
						l.getWeir().getCrestHeight().doubleValue(),
						vconduit,
						newPracticalFlow);
			}
			
			// Conduit: search continues if upstream junction is lower than current overflow
			else
			{ 						
				newPracticalFlow = enqueueFlooded(l, vconduit.getQMax(), practicalFlow);
				if(l.getNodeByIdNodeFrom().getElevation().doubleValue() < currentOverflow)
					analyseNode(l.getNodeByIdNodeFrom(), vconduit, newPracticalFlow);
			}
		}
	}
	
	/**
	 * Adds a new link to the list of flooded conduits. It also calculates the 
	 * practical flow for the conduit.
	 * @param l the link to add to the flooded list
	 * @param linkMaxFlow theoritical flow of the conduit
	 * @param downstreamPracticalFlow practical flow of the downstream conduit
	 * @return the practical flow calculated.
	 */
	protected double enqueueFlooded(Link l, double linkMaxFlow, double downstreamPracticalFlow)
	{
		double parallelTeoriticalFlow = 0;

		// Get other conduits leading to the some node and sum their practical flow
		Set<Link> linksTo = l.getNodeByIdNodeTo().getLinksForIdNodeTo();
		for (Link lt : linksTo)
		{
			VConduit vc = (VConduit) session.get(VConduit.class, lt.getId());
			if (vc != null) parallelTeoriticalFlow += vc.getQMax();
		}

		double practicalFlow = linkMaxFlow * downstreamPracticalFlow / parallelTeoriticalFlow;
		if (linkMaxFlow < practicalFlow) practicalFlow = linkMaxFlow;
		
		// This replaces the old flow value if the link is already in the hashMap 
		floodedLinks.put(l, practicalFlow);		
		return practicalFlow;
	}
	
	/**
	 * Updates the current overflow height. Takes depth as argument to allow
	 * alternative values, e.g. pump or wier. In the dynamic calculation it is
	 * always updated with the energy line offset. 
	 *
	 * @param n the node being analysed.
	 * @param depth the node depth (e.g. from groundsill to manhole lid).
	 * @param vc the conduit downstrem the node
	 * @param practicalFlow practical flow in the downstream conduit
	 */
	protected void updateCurrentOverflow(Node n, Double depth, VConduit vc, Double practicalFlow)
	{
		if(vc != null)
		{
			double energyLineSlope = Math.pow(
				(practicalFlow * vc.getRoughness().doubleValue()) /
				 (vc.getArea() * 
				  Math.pow(vc.getArea().doubleValue() / vc.getPerimeter().doubleValue(), 2.0/3.0)), 
				 2.0); 
			
			double projectPipeLength = vc.getLength().doubleValue() / 
									   Math.sqrt(Math.pow(vc.getSlope().doubleValue(), 2) + 1);
			
			double energyLineOffset = projectPipeLength * energyLineSlope;

			VJunction j = (VJunction) session.get(VJunction.class, n.getId());
			if(j != null) // Check if it is a manhole
			{
				currentOverflow += energyLineOffset;
				energyOffsets.put(vc.getId(), energyLineOffset);
			}
		}
		
		Double newLevel = n.getElevation().doubleValue() + depth - safetyMargin;
		if(newLevel < currentOverflow) currentOverflow = newLevel;
	}
	
	/**
	 * Removes from the flooded Conduits array (floodedLinks) all those whose
	 * outlet is above the current Candidate overflow height. 
	 */
	protected void prune()
	{
		System.out.println("Number of links before pruning: " + floodedLinks.size());
		HashMap<Link, Double> prunedLinks = new HashMap<Link, Double>();
		for(Link l : floodedLinks.keySet()) 
		{
		    Node arrivalNode = l.getNodeByIdNodeTo();
		    if (arrivalNode.getElevation().doubleValue() < currentOverflow)
		    	prunedLinks.put(l, floodedLinks.get(l));
		}
		floodedLinks = prunedLinks;
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
		if(Double.isNaN(currentOverflow)) return;
			
		Candidate c = new Candidate(n, new BigDecimal(currentOverflow));
		session.save(c);
		
		for(Link l : floodedLinks.keySet())
		{
			Flooded f = new Flooded(c, l);
			// Record practical flow and energy line offset
			double practicalFlow = floodedLinks.get(l);
			if(! Double.isNaN(practicalFlow))
				f.setQPrac(new BigDecimal(practicalFlow));
			if(energyOffsets.containsKey(l.getId()))
				f.setEnergyLineOffset(new BigDecimal(energyOffsets.get(l.getId())));
			// Compute wet fraction
			double outletElev = l.getNodeByIdNodeTo().getElevation().doubleValue();
		    double inletElev = l.getNodeByIdNodeFrom().getElevation().doubleValue();
		    if (l.getNodeByIdNodeFrom().getElevation().doubleValue() >= currentOverflow)
		    	f.setVolumeFraction(new BigDecimal(
		    			(currentOverflow - outletElev) / (inletElev - outletElev)));
			session.save(f);
		}
	}
}
