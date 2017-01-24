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
import centaur.db.Contribution;
import centaur.db.Subcatchment;
import centaur.db.Link;


// TODO: Auto-generated Javadoc
/**
 * The Class OptimalByVolume.
 */
public class ServedAreas {
	
	/** The subcatchments. */
	static LinkedList<Subcatchment> subcatchments;
	
	/** The database session. */
	static Session session;
	
	/** 
	 * Initialises the calculation of contributing areas.
	 * 
	 * @param sess the database session.
	 */
	public static void compute(Session sess)
	{
		System.out.println("Starting computation of served areas and contributions...");
		session = sess;
		clearAreas();
		computeContributions();
	}
	
	/**
	 * Finalises the calculation of contributing areas.
	 * 
	 * @param numGates the number of gates to site.
	 */
	protected static void finalise(int numGates)
	{
		resetCandidates();
		session.getTransaction().commit();
        session.beginTransaction();
        
		System.out.println("\nSucessfully sited " + numGates + " gates.");
	}
	
	
	/**
	 * Marks all the gate candidates as available for future calculations.
	 */
	static void resetCandidates ()
	{
		Query query = session.createQuery("update Node set taken = 'FALSE' ");
		query.executeUpdate();
		session.getTransaction().commit();
        session.beginTransaction();
	}
	
	/**
	 * Clears the Contribution table and the area served by each Candidate, 
	 * setting it to zero.
	 *
	 */
	static void clearAreas()
	{
		session.createQuery(String.format("delete from %s", Contribution.class.getName())).executeUpdate();
		session.createQuery(String.format("UPDATE %s SET served_area = 0", Candidate.class.getName())).executeUpdate();
		session.flush();
	}
	
	/**
	 * Computes the contributing areas for each candidate.
	 * 
	 * @param session the database session
	 */
	static void computeContributions()
	{
		Query query =  session.createQuery("from Subcatchment s");
		subcatchments = new LinkedList<Subcatchment>(query.list());
		
		int numSubs = subcatchments.size();
		
		while(subcatchments.size() > 0)
		{
			Subcatchment s = subcatchments.pop();
			System.out.print("\rProcessing subcatchment " + (numSubs - subcatchments.size()) + 
					" of " + numSubs + " : " + s.getId());
			
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
					
					createContribution(c, s, servedArea);
				}	
				
				transportDownstream(
						servedArea, 
						s.getNode().getLinksForIdNodeFrom(),
						s);
			}
		}		
		System.out.println("\nSucessfully calculated contributing areas.");
	}
	
	/**
	 * Creates a new Contribution instance. Checks if the candidate has already
	 * been registered for the given Subcatchment to avoid double counting with 
	 * upstream bifurcations. 
	 * 
	 * @param candidate the candidate instance.
	 * @param subcatchment the subcatchment instance.
	 * @param value the contribution to assign to the pair 
	 *        (candidate, subcatchment)
	 
	 * @return true if the candidate has already been visited for the given 
	 *         subcatchment, false otherwise
	 */
	static Boolean createContribution(Candidate candidate, Subcatchment subcatchment, 
			BigDecimal value)
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
			//System.out.println("Been here before! " + candidate.getIdNode() + "  " + subcatchment.getId());
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
	 */
	static void transportDownstream(BigDecimal area, Set<Link> outwardLinks, Subcatchment sub)
	{	
		for (Link l : outwardLinks)
		{
			// Pumps have to be ignored - they send water upstream creating loops
			if (l.getPump() == null) 
			{	
				Node n = l.getNodeByIdNodeTo();
				BigDecimal areaShare = new BigDecimal(area.doubleValue() / outwardLinks.size());
				
				if(n.getCandidate() == null)
				{
					System.out.println("\n!!!! Node without candidate: " + n.getId() 
						+ " Link: " + l.getId());
				}
				
				else
				{
					if (n.getCandidate().getServedArea() == null)
						n.getCandidate().setServedArea(areaShare);
					else
						n.getCandidate().setServedArea(
							n.getCandidate().getServedArea().add(areaShare));
					
					Boolean visited = createContribution(n.getCandidate(), sub, areaShare);
					
					if(!visited && (n.getLinksForIdNodeFrom().size() > 0))
						transportDownstream(areaShare, n.getLinksForIdNodeFrom(), sub);
				}
			}
		}
	}
	
	
}