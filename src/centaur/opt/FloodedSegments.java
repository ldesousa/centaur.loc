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

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Flooded;
import centaur.db.Link;


// TODO: Auto-generated Javadoc
/**
 * The Class FloodedSegments.
 */
public class FloodedSegments 
{	
	
	/** The safety margin. */
	static BigDecimal safetyMargin = new BigDecimal(0.9);
	
	/** The prospects. */
	static LinkedList<Node> prospects;
	
	/** The candidates. */
	static ArrayList<Node> candidates = new ArrayList<Node>();
	
	/** The flooded links. */
	static ArrayList<Link> floodedLinks = new ArrayList<Link>();
	
	/** The current overflow. */
	static BigDecimal currentOverflow = BigDecimal.valueOf(Double.MAX_VALUE);

	/**
	 * Computes the floodable network links for each of the possible gate 
     * locations in the network.
	 *
	 * @param session the session
	 */
	public static void compute(Session session) 
	{
		System.out.println("Clearing database ...");
		clearDB(session);
		
		Query query =  session.createQuery("from Node n");
		prospects = new LinkedList<Node>(query.list());
		
		while(prospects.size() > 0)
		{
			System.out.println("Candidates: " + prospects.size());
			Node n = prospects.pop();					
			currentOverflow = BigDecimal.valueOf(Double.MAX_VALUE);
			floodedLinks = new ArrayList<Link>();
			
			Set<Link> links = n.getLinksForIdNodeTo();
			if(links.size() > 0)
			{
				System.out.println("--------\nId: " + n.getId() + " arrivals: " + links.size());
				candidates.add(n);
				searchLinks(links);
				System.out.println("Calculated overflow: " + currentOverflow);
				System.out.println("Number of links: " + floodedLinks.size());
				prune();
				System.out.println("Number of links after pruning: " + floodedLinks.size());
				save(n, session);
				System.out.println("Gate candidates: " + candidates.size());
			}
		}
		System.out.println();
		System.out.println("############################################");
		System.out.println("# Successfully computed floodable segments #");
		System.out.println("############################################");
		System.out.println();
	}
	
	/**
	 * Clears the Candidate and Flooded database tables.
	 *
	 * @param session the database session.
	 */
	static void clearDB(Session session)
	{
		session.createQuery(String.format("delete from %s", Flooded.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Candidate.class.getName())).executeUpdate();
		session.flush();
	}

	/**
	 * Analyses a Node, stopping if no Conduit leads to it, if it is an Outfall 
	 * or if it is a Storage. Proceeds with the analysis recursively to the 
	 * Links arriving at the node. 
	 *
	 * @param n the node to be analysed.
	 */
	protected static void analyseNode(Node n)
	{
		Set<Link> linksTo   = n.getLinksForIdNodeTo();
		Set<Link> linksFrom = n.getLinksForIdNodeFrom();
		
		// Search stops if:
		// 1. No links arrive at this node;
		// 2. This node is an outfall or a storage.
		// 3. There is more than one link leading downstream (bifurcation). 
		if( linksTo.size() <= 0    || linksFrom.size() > 1   ||
		    n.getOutfall() != null || n.getStorage() != null )
			updateCurrentOverflow(n.getElevation(), BigDecimal.ZERO);
		else
		{
			updateCurrentOverflow(n.getElevation(), n.getJunction().getMaxDepth());
			searchLinks(linksTo);
		}
	}
	
	/**
	 * Iterates through a set of Links identifying those floodable by the 
	 * current Candidate instance, updating the current overflow height. 
	 * Stops the analysis if the upstream Node is a pump or weir. Proceeds the
	 * analysis recursively for those inlet nodes whose height is lower than 
	 * the current overflow. 
	 *
	 * @param links the set of links with a common outlet.
	 */
	protected static void searchLinks(Set<Link> links)
	{
		for (Link l : links)
		{
			// Pump: search stops at downstream junction
			if (l.getPump() != null) 
				updateCurrentOverflow(l.getNodeByIdNodeTo().getElevation(), BigDecimal.ZERO);

			// Weir: search stops at crest height
			else if (l.getWeir() != null) 
			{
				updateCurrentOverflow(
						l.getNodeByIdNodeTo().getElevation(), l.getWeir().getCrestHeight());
				if(!floodedLinks.contains(l)) floodedLinks.add(l);
			}
			
			// Conduit: search continues if upstream junction is lower than current overflow
			else
			{ 						
				if(!floodedLinks.contains(l)) floodedLinks.add(l);
				if(l.getNodeByIdNodeFrom().getElevation().compareTo(currentOverflow) < 0)
					analyseNode(l.getNodeByIdNodeFrom());
			}
		}
	}
	
	/**
	 * Updates the current overflow height.
	 *
	 * @param newLevel the node groundsill height.
	 * @param depth the node depth (e.g. from groundsill to manhole lid).
	 */
	protected static void updateCurrentOverflow(BigDecimal newLevel, BigDecimal depth)
	{
		newLevel = newLevel.add(depth.multiply(safetyMargin));
		if(newLevel.compareTo(currentOverflow) < 0) 
			currentOverflow = newLevel;
	}
	
	/**
	 * Removes from the flooded Conduits array (floodedLinks) all those whose
	 * outlet is above the current Candidate overflow height. 
	 */
	protected static void prune()
	{
		for (Iterator<Link> it = floodedLinks.iterator(); it.hasNext(); ) 
		{
		    Link l = it.next();
		    Node arrivalNode = l.getNodeByIdNodeTo();
		    if (arrivalNode.getElevation().compareTo(currentOverflow) > 0)
				it.remove();
		}
	}
	
	/**
	 * Saves a new Candidate instance to the database. It saves the respective
	 * flooded conduits (stored in floodedLinks) and computes the usable volume 
	 * in each conduit according to the Candidate overflow height.
	 *
	 * @param n the Node instance on which the Candidate is to be created.
	 * @param session the Database session.
	 */
	protected static void save(Node n, Session session)
	{
		Candidate c = new Candidate(n, currentOverflow);
		session.save(c);
		for(Link l : floodedLinks)
		{
			Flooded f = new Flooded(c, l);
			double outletElev = l.getNodeByIdNodeTo().getElevation().doubleValue();
		    double inletElev = l.getNodeByIdNodeFrom().getElevation().doubleValue();
		    if (l.getNodeByIdNodeFrom().getElevation().compareTo(currentOverflow) > 0)
		    	f.setVolumeFraction(new BigDecimal(
		    			(currentOverflow.doubleValue() - outletElev) / (inletElev - outletElev)));
			session.save(f);
		}
	}
}
