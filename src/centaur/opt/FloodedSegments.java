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
public abstract class FloodedSegments
{	
	
	/** The safety margin in meters; to be deducted from node depth. */
	protected double safetyMargin = 0.1;
	
	/** The prospects. */
	protected LinkedList<Node> prospects;
	
	/** The candidates. */
	protected ArrayList<Node> candidates = new ArrayList<Node>();
	
	/** The energy line offsets, indexed by the conduit id. */
	protected HashMap<Integer, Double> energyOffsets = new HashMap<Integer, Double>();
	
	/** The current overflow. */
	protected double currentOverflow = Double.MAX_VALUE;
	
	/** The database session. */
	protected Session session;
	

	/**
	 * Computes the floodable network links for each of the possible gate 
     * locations in the network.
	 *
	 * @param session the session
	 * @param useEnergySlopeFlag if true the algorithm uses the energy slope.
	 */
	public void compute(Session sess) 
	{
		session = sess;
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
			resetFloodedLinks();
			
			Set<Link> links = n.getLinksForIdNodeTo();
			if(links.size() > 0)
			{
				System.out.println("--------\nId: " + n.getId() + " arrivals: " + links.size());
				candidates.add(n);
				searchLinks(links, Double.MAX_VALUE);
				System.out.println("Calculated overflow: " + currentOverflow);
				prune();
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
	
	protected abstract void resetFloodedLinks();
	
	/**
	 * Clears the Candidate and Flooded database tables.
	 */
	protected void clearDB()
	{
		session.createQuery(String.format("delete from %s", Flooded.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Candidate.class.getName())).executeUpdate();
		session.flush();
	}
	
	protected abstract void searchLinks(Set<Link> links, Double practicalFlow);

	/**
	 * Analyses a Node, stopping if no Conduit leads to it, if it is an Outfall 
	 * or if it is a Storage. Proceeds with the analysis recursively to the 
	 * Links arriving at the node. 
	 *
	 * @param n the node to be analysed.
	 * @param practicalFlow practical flow in the downstream conduit
	 */
	protected void analyseNode(Node n, VConduit vc, Double practicalFlow)
	{
		Set<Link> linksTo   = n.getLinksForIdNodeTo();
		Set<Link> linksFrom = n.getLinksForIdNodeFrom();
				
		// Search stops if:
		// 1. No links arrive at this node;
		// 2. This node is an outfall or a storage.
		// 3. There is more than one link leading downstream (bifurcation). 
		if( linksTo.size() <= 0    || linksFrom.size() > 1   ||
		    n.getOutfall() != null || n.getStorage() != null )
			updateCurrentOverflow(n, 0.0, vc, practicalFlow);
		else
		{
			updateCurrentOverflow(n, n.getJunction().getMaxDepth().doubleValue(), vc, practicalFlow);
			searchLinks(linksTo, practicalFlow);
		}
	}
	
	protected abstract void updateCurrentOverflow(Node n, Double depth, VConduit vc, Double practicalFlow);
	
	protected abstract void prune();

	protected abstract void save(Node n);
}
