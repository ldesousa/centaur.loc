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
 * The Class FloodedSegments.
 */
public class FloodedSegments 
{	
	
	/** The safety margin in meters; to be deducted from node depth. */
	static double safetyMargin = 0.1;
	
	/** The prospects. */
	static LinkedList<Node> prospects;
	
	/** The candidates. */
	static ArrayList<Node> candidates = new ArrayList<Node>();
	
	/** The flooded links and their respective practical flows. */
	static HashMap<Link, Double> floodedLinks = new HashMap<Link, Double>();
	
	/** The energy line offsets, indexed by the conduit id. */
	static HashMap<Integer, Double> energyOffsets = new HashMap<Integer, Double>();
	
	/** The current overflow. */
	static double currentOverflow = Double.MAX_VALUE;
	
	/** Determines if the energy line should be used or note in overflow computation. */
	static Boolean useEnergySlope = Boolean.TRUE;
	
	/** The database session. */
	static Session session;
	

	/**
	 * Computes the floodable network links for each of the possible gate 
     * locations in the network.
	 *
	 * @param session the session
	 * @param useEnergySlopeFlag if true the algorithm uses the energy slope.
	 */
	public static void compute(Session sess, Boolean useEnergySlopeFlag) 
	{
		session = sess;
		useEnergySlope = useEnergySlopeFlag;
		System.out.println("Clearing database ...");
		clearDB();
															// Testing with node 64
		Query query =  session.createQuery("from Node n");  // Where id = -545475706");
		prospects = new LinkedList<Node>(query.list());
		
		while(prospects.size() > 0)
		{
			System.out.println("Candidates: " + prospects.size());
			Node n = prospects.pop();					
			currentOverflow = Double.MAX_VALUE;
			floodedLinks = new HashMap<Link, Double>();
			
			Set<Link> links = n.getLinksForIdNodeTo();
			if(links.size() > 0)
			{
				System.out.println("--------\nId: " + n.getId() + " arrivals: " + links.size());
				candidates.add(n);
				searchLinks(links, Double.MAX_VALUE);
				System.out.println("Calculated overflow: " + currentOverflow);
				System.out.println("Number of links: " + floodedLinks.size());
				prune();
				System.out.println("Number of links after pruning: " + floodedLinks.size());
				save(n);
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
	 */
	static void clearDB()
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
	 * @param practicalFlow practical flow in the downstream conduit
	 */
	protected static void analyseNode(Node n, VConduit vc, double practicalFlow)
	{
		Set<Link> linksTo   = n.getLinksForIdNodeTo();
		Set<Link> linksFrom = n.getLinksForIdNodeFrom();
				
		// Search stops if:
		// 1. No links arrive at this node;
		// 2. This node is an outfall or a storage.
		// 3. There is more than one link leading downstream (bifurcation). 
		if( linksTo.size() <= 0    || linksFrom.size() > 1   ||
		    n.getOutfall() != null || n.getStorage() != null )
			updateCurrentOverflow(n, vc, 0, practicalFlow);
		else
		{
			updateCurrentOverflow(n, vc, n.getJunction().getMaxDepth().doubleValue(), practicalFlow);
			searchLinks(linksTo, practicalFlow);
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
	 * @param practicalFlow maximum practical flow downstream the node 
	 */
	protected static void searchLinks(Set<Link> links, double practicalFlow)
	{
		double newPracticalFlow;
		
		for (Link l : links)
		{
			VConduit vconduit = (VConduit) session.get(VConduit.class, l.getId());
			
			// Pump: search stops at downstream junction
			if (l.getPump() != null) 
				updateCurrentOverflow(l.getNodeByIdNodeTo(), vconduit, 0, practicalFlow);

			// Weir: search stops at crest height
			else if (l.getWeir() != null) 
			{
				newPracticalFlow = enqueueFlooded(l, 0, practicalFlow);
				updateCurrentOverflow(
						l.getNodeByIdNodeTo(), 
						vconduit,
						l.getWeir().getCrestHeight().doubleValue(),
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
	protected static double enqueueFlooded(Link l, double linkMaxFlow, double downstreamPracticalFlow)
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
	 * @param practicalFlow practical flow in the downstream conduit
	 */
	protected static void updateCurrentOverflow(Node n, VConduit vc, double depth, double practicalFlow)
	{
		Double newLevel = n.getElevation().doubleValue();
		
		//Dynamic - update current overflow with energy slope
		if(useEnergySlope && (vc != null))
		{
			double energyLineOffset = Math.pow(
				(practicalFlow * vc.getRoughness().doubleValue()) /
				 (vc.getArea() * 
				  Math.pow(vc.getArea().doubleValue() / vc.getPerimeter().doubleValue(), 2.0/3.0)), 
				 2.0); 

			VJunction j = (VJunction) session.get(VJunction.class, n.getId());
			if(j != null) // Check if it is a manhole
			{
				currentOverflow += energyLineOffset;
				energyOffsets.put(vc.getId(), energyLineOffset);
			}
		}
		
		//Static
		newLevel = newLevel + depth - safetyMargin;
		if(newLevel < currentOverflow) 
			currentOverflow = newLevel;
	}
	
	/**
	 * Removes from the flooded Conduits array (floodedLinks) all those whose
	 * outlet is above the current Candidate overflow height. 
	 */
	protected static void prune()
	{
		HashMap<Link, Double> prunedLinks = new HashMap<Link, Double>();
		for(Link l : floodedLinks.keySet()) 
		{
		    Node arrivalNode = l.getNodeByIdNodeTo();
		    if (arrivalNode.getElevation().doubleValue() < currentOverflow)
		    	prunedLinks.put(l, floodedLinks.get(l));
		}
		floodedLinks = prunedLinks;
	}
	
	/**
	 * Saves a new Candidate instance to the database. It saves the respective
	 * flooded conduits (stored in floodedLinks) and computes the usable volume 
	 * in each conduit according to the Candidate overflow height.
	 *
	 * @param n the Node instance on which the Candidate is to be created.
	 */
	protected static void save(Node n)
	{
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
