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
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.criterion.Order;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Contribution;
import centaur.db.Subcatchment;
import centaur.db.VCandidate;
import centaur.in.Outfall;
import centaur.db.Link;


// TODO: Auto-generated Javadoc
/**
 * The Class ServedAreas.
 */
public class ServedAreas {
	
	/** The subcatchments. */
	static LinkedList<Subcatchment> subcatchments;
	
	/** The contributions of each subcatchment */
	static Map<Integer, BigDecimal> contributions = new HashMap<Integer, BigDecimal>();

	/**
	 * Computes the total Subcatchment area served by each gate Candidate.
	 *
	 * @param session the database session.
	 */
	public static void compute(Session session) 
	{
		System.out.println("Starting up");
		
		clearAreas(session);
		
		computeContributions(session);
		 	
		VCandidate cand = getBestCandidate(session);
		
		System.out.println("The best candidate: " + cand.getId());
		
		//updateContributions(cand, session);
	}
	
	/**
	 * Clears the Contribution table and the area served by each Candidate, 
	 * setting it to zero.
	 *
	 * @param session the database session.
	 */
	static void clearAreas(Session session)
	{
		session.createQuery(String.format("delete from %s", Contribution.class.getName())).executeUpdate();
		session.createQuery(String.format("UPDATE %s SET served_area = 0", Candidate.class.getName())).executeUpdate();
		session.flush();
	}
	
	/**
	 * Computes the contributing areas for each candidate.
	 * 
	 * @ param session the database session
	 */
	static void computeContributions(Session session)
	{
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
				
				contributions.put(s.getId(), servedArea);
				
				Candidate c = s.getNode().getCandidate();
				// If there is no candidate this is a leaf node
				if (c != null)
				{					
					// => This sum can be removed later on
					if (c.getServedArea() == null) c.setServedArea(servedArea);
					else c.setServedArea(c.getServedArea().add(servedArea));
					
					createContribution(c, s, servedArea, session);
				}	
				
				transportDownstream(
						servedArea, 
						s.getNode().getLinksForIdNodeFrom(),
						s, session);
			}
		}
		
		session.getTransaction().commit();
        session.beginTransaction();
		
		System.out.println("\nSucessfully calculated served areas.");
	}
	
	/**
	 * Creates a new Contribution instance. Checks if the candidate has already
	 * been registered for the given Subcatchment to avoid double couting with 
	 * upstream bifurcations. 
	 * 
	 * @param candidate the candidate instance.
	 * @param subcatchment the subcatchment instance.
	 * @param value the contribution to assign to the pair 
	 *        (candidate, subcatchment)
	 * @param session the database session
	 * @return true if the candidate has already been visited for the given 
	 *         subcatchment, false otherwise
	 */
	static Boolean createContribution(Candidate candidate, Subcatchment subcatchment, 
			BigDecimal value, Session session)
	{		
		// Check if this pair has already been registered.
		// Bifurcations may carry the same subcatchment more than once downstream.	
		String check = 	"SELECT c FROM Contribution c WHERE c.candidate.idNode = :idNode " +
						" AND c.subcatchment.id = :idSubcatchment";
		Query checkQuery = session.createQuery(check);
		checkQuery.setParameter("idNode", candidate.getIdNode());
		checkQuery.setParameter("idSubcatchment", subcatchment.getId());
		if (checkQuery.list().size() > 0)
		{
			System.out.println("Been here before! " + candidate.getIdNode() + "  " + subcatchment.getId());
			return true;
		}
		
		Contribution cb = new Contribution();
		cb.setCandidate(candidate);
		cb.setSubcatchment(subcatchment);
		cb.setValue(value);
		session.save(cb);
		return false;
	}
	
	/**
	 * Recursively transports downstream the area served by a Candidate, 
	 * summing it up to any Candidates found in the path to the Outfall(s). 
	 * If more than one link departs from the current Candidate, the served 
	 * area is split proportionately. 
	 *
	 * @param area the area to be transported.
	 * @param outwardLinks the set of links departing from a particular node.
	 * @param sub the contributing subcatchment.
	 * @param session the database session.
	 */
	static void transportDownstream(BigDecimal area, Set<Link> outwardLinks, Subcatchment sub, Session session)
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
				
				Boolean visited = createContribution(n.getCandidate(), sub, areaShare, session);
				
				if(!visited && (n.getLinksForIdNodeFrom().size() > 0))
					transportDownstream(areaShare, n.getLinksForIdNodeFrom(), sub, session);
			}
		}
	}
	
	/**
	 * Retrieves the best candidate according to a particular objective 
	 * function. Presently this is storage volume times contributing area.
	 * 
	 * @param session the database session.
	 * @return the best candidate.
	 */
	static VCandidate getBestCandidate(Session session)
	{		
		String max = "Select max(c.floodedVolume * c.contributions) FROM VCandidate c";
		Query maxQuery = session.createQuery(max);
		
		System.out.println("\nMax: " + maxQuery.list().get(0));
		
		String best = "From VCandidate as v where (v.floodedVolume * v.contributions) >= " + 
				maxQuery.list().get(0);
		Query bestQuery = session.createQuery(best);
		return (VCandidate) bestQuery.list().get(0);
	}
}
