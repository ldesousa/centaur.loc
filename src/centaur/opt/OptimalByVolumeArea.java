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
import java.text.DecimalFormat;
import java.util.HashMap;
import java.util.LinkedList;
import java.util.Map;
import java.util.Set;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Contribution;
import centaur.db.Flooded;
import centaur.db.Subcatchment;
import centaur.db.VCandidate;
import centaur.db.Link;


// TODO: Auto-generated Javadoc
/**
 * The Class OptimalByVolumeArea.
 */
public class OptimalByVolumeArea {
	
	/** The subcatchments. */
	static LinkedList<Subcatchment> subcatchments;
	
	/** The contributions of each subcatchment */
	static Map<Integer, BigDecimal> contributions = new HashMap<Integer, BigDecimal>();
	
	/** The database session. */
	static Session session;
	
	/** Number format for Console printing */
	static DecimalFormat df = new DecimalFormat("###.##");
	
	/** 
	 * Initialises the calculation of contributing areas.
	 * 
	 * @param sess the database session.
	 */
	public static void init(Session sess)
	{
		System.out.println("Starting up");
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
	 * Updates contributing areas after a best candidate is selected.
	 * 
	 * @param cand the best candidate in the present iteration
	 * @param intensity the rain event intensity to consider (mm/h == l/m2).
	 * @param duration the time length of the rain event (minutes)
	 */
	protected static void updateBestCandidate(VCandidate cand, double intensity, double duration)
	{
		updateContributions(cand, intensity, duration);
		removeCandidates(cand);
		session.getTransaction().commit();
        session.beginTransaction();
	}

	/**
	 * Computes the locations of a number of flood control gates optimising by 
	 * pipe volume times contributing area. A node of interest may be indicated 
	 * to restrict search to a subset of the sewer network. Takes into account 
	 * a rain event with a specific intensity during a determined time.
	 *
	 * @param session the database session.
	 * @param numGates the number of gates to site.
	 * @param nio the node of interest (ignored if NULL)
	 * @param intensity the rain event intensity to consider (mm/h == l/m2).
	 * @param duration the time length of the rain event (minutes)
	 * @param database schema containing the CENTAUR tables
	 */
	public static void computeVolumeArea(Session sess, int numGates, Integer noi, 
			double intensity, double duration, String schema) 
	{
		init(sess);
		
		for (int i = 1; i <= numGates; i++)
		{
			VCandidate cand = getBestCandidateVolumeArea(noi, schema);
			System.out.println(
					"Candidate #" + i + ": " + cand.getId() + 
					"\n\tvolume: " + df.format(cand.getFloodedVolume()) + " m3" + 
					"\n\tcontributing area: " + df.format(cand.getContributions()) + " ha");
			
			updateBestCandidate(cand, intensity, duration);
		}
		
		finalise(numGates);
	}
	
	/**
	 * Computes the locations of a number of flood control gates optimising by 
	 * pipe volume times contributing area divided by the number of 
	 * contributing sub-catchments. Takes into account a rain event with a 
	 * specific intensity during a determined time.
	 *
	 * @param session the database session.
	 * @param numGates the number of gates to site.
	 * @param nio the node of interest (ignored if NULL)
	 * @param intensity the rain event intensity to consider (mm/h == l/m2).
	 * @param duration the time length of the rain event (minutes)
	 * @param database schema containing the CENTAUR tables
	 */
	public static void computeVolumeAreaNumSubcatchments(Session sess, int numGates, 
			Integer noi, double intensity, double duration, String schema) 
	{
		init(sess);
		
		for (int i = 1; i <= numGates; i++)
		{
			VCandidate cand = getBestCandidateVolumeAreaNumSubcatchments(noi, schema);
			System.out.println(
					"Candidate #" + i + ": " + cand.getId() + 
					"\n\tvolume: " + df.format(cand.getFloodedVolume()) + " m3" + 
					"\n\tcontributing area: " + df.format(cand.getContributions()) + " ha" +
					"\n\tnum subcatchments: " + cand.getNumSubcatchments());
			
			updateBestCandidate(cand, intensity, duration);
		}
		finalise(numGates);
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
				
				contributions.put(s.getId(), servedArea);
				
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
	
	/**
	 * Retrieves the best candidate according to a particular objective 
	 * function, in this case storage volume times contributing area.
	 * 
	 * @param noi node of interest - search is to restricted to its upstream 
	 * sub-network; ignored if null
	 * @param database schema containing the CENTAUR tables
	 * 
	 * @return the best candidate.
	 */
	static VCandidate getBestCandidateVolumeArea(Integer noi, String schema)
	{	
		// Set search_path
		String query = "SET search_path TO " + schema + " , public";
		session.createSQLQuery(query).executeUpdate();
		
		query = "SELECT * FROM f_optimal("; 
		if(noi != null)
			query += noi.toString() + ", FALSE)";
		else 
			query += "NULL, FALSE)";
		
		List max = session.createSQLQuery(query).list();
		System.out.println("\nMax: " + df.format(max.get(0)));
		return (VCandidate) session.get(VCandidate.class, new Integer(max.get(0).toString()));
	}
	
	/**
	 * Retrieves the best candidate according to a particular objective 
	 * function. Presently this is storage volume times contributing area.
	 * 
	 * @param noi the node of interest (ignored if NULL)
	 * @param database schema containing the CENTAUR tables
	 * 
	 * @return the best candidate.
	 */
	static VCandidate getBestCandidateVolumeAreaNumSubcatchments(Integer noi, String schema)
	{		
		// Set search_path
		String query = "SET search_path TO " + schema + ", public";
		session.createSQLQuery(query).executeUpdate();
		
		query = "SELECT * FROM f_optimal("; 
		if(noi != null)
			query += noi.toString() + ", TRUE)";
		else 
			query += "NULL, TRUE)";
		
		List max = session.createSQLQuery(query).list();
		System.out.println("\nMax: " + df.format(max.get(0)));
		return (VCandidate) session.get(VCandidate.class, new Integer(max.get(0).toString()));
	}
	
	/**
	 * 
	 * @param candidate
	 * @param intensity the rain event intensity to consider (mm/h == l/m2).
	 * @param duration the time length of the rain event (minutes)
	 */
	static void updateContributions(VCandidate candidate, double intensity, double duration)
	{
		// Calculate water volume per hectare 
		// intensity / litres per cubic meter * square meters per hectare * hours
		Double volumeH = intensity / 1000 * 10000 * duration / 60;
		
		// Compute maximum volume stored by this candidate for this event.
		Double volumeStored = volumeH * candidate.getContributions().doubleValue();
		if(volumeStored > candidate.getFloodedVolume().doubleValue())
			volumeStored = candidate.getFloodedVolume().doubleValue();
		
		// Get all the subcatchments served by this candidate
		String select = "SELECT c FROM Contribution c WHERE c.candidate.idNode = :idNode";
		Query selectQuery = session.createQuery(select);
		selectQuery.setParameter("idNode", candidate.getId());
		LinkedList<Contribution> contribs = new LinkedList<Contribution>(selectQuery.list());
		
		for (Contribution contrib : contribs) 
		{
			// weight of this subcatchment
			double weight = 
					contrib.getValue().doubleValue() / 
					candidate.getContributions().doubleValue();
			
			// total contribution from this subcatchment
			double subValue = contrib.getSubcatchment().getArea().doubleValue() * volumeH;
			
			// fraction of the subcatchment contribution stored by the gate
			double fraction = subValue / (volumeStored * weight);
			
			select = "SELECT c FROM Contribution c WHERE c.subcatchment.id = :id";
			selectQuery = session.createQuery(select);
			selectQuery.setParameter("id", contrib.getSubcatchment().getId());
			LinkedList<Contribution> subContribs = 
					new LinkedList<Contribution>(selectQuery.list());
			
			for (Contribution subContrib : subContribs)
			{
				subContrib.setValue(new BigDecimal(
						subContrib.getValue().doubleValue() * (1 - fraction)));
				session.save(subContrib);
			}
		}
	}
	
	/**
	 * Marks all the nodes flooded by a gate as taken. This way they will no 
	 * longer figure in the VCandidate collection.
	 *  
	 * @param candidate the node where the gate is to be installed.
	 */
	static void removeCandidates (VCandidate candidate)
	{
		String select = "SELECT f FROM Flooded f WHERE f.candidate.id = :id";
		Query selectQuery = session.createQuery(select);
		selectQuery.setParameter("id", candidate.getId());
		LinkedList<Flooded> flooded = 
				new LinkedList<Flooded>(selectQuery.list());
		
		for (Flooded f : flooded)
		{
			Node node = f.getLink().getNodeByIdNodeTo();
			node.setTaken(true);
			session.save(node);
		}
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
}