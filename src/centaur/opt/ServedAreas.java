/* *****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 17-03-2016
 * Description:
 * Computes the area served by each gate Candidate. Recursively assigns the area 
 * of each Subcatchment to the Candidates downstream. The total served area 
 * provides a proxy to the maximum flow at the Candidate.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ****************************************************************************/
package centaur.opt;

import java.math.BigDecimal;
import java.util.LinkedList;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Subcatchment;
import centaur.db.Link;


// TODO: Auto-generated Javadoc
/**
 * The Class ServedAreas.
 */
public class ServedAreas {
	
	/** The subcatchments. */
	static LinkedList<Subcatchment> subcatchments;

	/**
	 * Computes the total Subcatchment area served by each gate Candidate.
	 *
	 * @param session the database session.
	 */
	public static void compute(Session session) 
	{
		System.out.println("Starting up");
		
		clearAreas(session);
		
		Query query =  session.createQuery("from Subcatchment s");
		subcatchments = new LinkedList<Subcatchment>(query.list());
		
		System.out.println("Subcatchments: " + subcatchments.size());
		
		while(subcatchments.size() > 0)
		{
			Subcatchment s = subcatchments.pop();
			System.out.println("==== Processing subcatchment: " + s.getId());
			
			if(s.getNode() != null)
			{
				BigDecimal servedArea = BigDecimal.valueOf(
						s.getArea().doubleValue() * s.getImperv().doubleValue() / 100);
				
				Candidate c = s.getNode().getCandidate();
				// If there is no candidate this is a leaf node
				if (c != null)
				{					
					if (c.getServedArea() == null) c.setServedArea(servedArea);
					else c.setServedArea(c.getServedArea().add(servedArea));
				}	
				
				transportDownstream(
						servedArea, 
						s.getNode().getLinksForIdNodeFrom());
			}
		}
		System.out.println("\nSucessfully calculated served areas.");
	}
	
	/**
	 * Clears area served by each Candidate setting it to zero.
	 *
	 * @param session the database session.
	 */
	static void clearAreas(Session session)
	{
		session.createQuery(String.format("UPDATE %s SET served_area = 0", Candidate.class.getName())).executeUpdate();
		session.flush();
	}
	
	/**
	 * Recursively transports downstream the area served by a Candidate, 
	 * summing it up to any Candidates found in the path to the Outfall(s). 
	 * If more than one link departs from the current Candidate, the served 
	 * area is split proportionately. 
	 *
	 * @param area the area to be transported.
	 * @param outwardLinks the set of links departing from a particular node.
	 */
	static void transportDownstream(BigDecimal area, Set<Link> outwardLinks)
	{	
		for (Link l : outwardLinks)
		{
			// Pumps have to be ignored - they send water upstream creating loops
			if (l.getPump() == null) 
			{	
				Node n = l.getNodeByIdNodeTo();
				BigDecimal areaShare = new BigDecimal(area.doubleValue() / outwardLinks.size());
				
				if (n.getCandidate().getServedArea() == null)
					n.getCandidate().setServedArea(areaShare);
				else
					n.getCandidate().setServedArea(
						n.getCandidate().getServedArea().add(areaShare));
				
				if(n.getLinksForIdNodeFrom().size() > 0)
					transportDownstream(areaShare, n.getLinksForIdNodeFrom());
			}
		}
	}
}
