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
import centaur.db.ContributionTemp;
import centaur.db.Flooded;
import centaur.db.Subcatchment;
import centaur.db.VCandidate;
import centaur.db.Link;


// TODO: Auto-generated Javadoc
/**
 * The Class OptimalByVolume.
 */
public class OptimalByVolume {
	
	/** The subcatchments. */
	static LinkedList<Subcatchment> subcatchments;
	
	/** The contributions of each subcatchment */
	static Map<Integer, BigDecimal> contributions = new HashMap<Integer, BigDecimal>();
	
	/** The database session. */
	static Session session;
	
	/** Number format for Console printing */
	static DecimalFormat df = new DecimalFormat("###.##");
	
	/**
	 * Computes the locations of a number of flood control gates optimising by 
	 * pipe volume times contributing area. A node of interest may be indicated 
	 * to restrict search to a subset of the sewer network. Takes into account 
	 * a rain event with a specific intensity during a determined time.
	 *
	 * @param session the database session.
	 * @param numGates the number of gates to site.
	 * @param nio the node of interest (ignored if NULL)
	 * @param useArea if true, the contributing area to each node is used in 
	 * their ranking.
	 * @param useCatchments if true, the number of subcatchments upstream of 
	 * each node is used in their ranking.
	 * @param intensity the rain event intensity to consider (mm/h == l/m2).
	 * @param duration the time length of the rain event (minutes)
	 * @param database schema containing the CENTAUR tables
	 */
	public static void compute(Session sess, int numGates, Integer noi,  
			boolean useArea, boolean useCatchments, double intensity, 
			double duration, String schema) 
	{	
		System.out.println("\nStarting gate siting computation...");
		
		session = sess;
		resetContributions(schema);
		
		for (int i = 1; i <= numGates; i++)
		{
			VCandidate cand = getBestCandidate(noi, useArea, useCatchments, schema);
			System.out.println(
					"Candidate #" + i + ": " + cand.getName() + " id: "+ cand.getId() + 
					"\n\tvolume: " + df.format(cand.getFloodedVolume()) + " m3" + 
					"\n\tserved area: " + df.format(cand.getServedArea()) + " ha" + 
					"\n\tnum catchemnts: " + df.format(cand.getNumSubcatchments())); // +
					//"\n\nUpdating contributions data...\n");
			
			updateBestCandidate(cand, intensity, duration);
		}
		
		finalise(numGates);
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
	 * Retrieves the temporary contributions table to restart the computation.
	 * This table contains the data used by the f_optimal function.
	 */
	static void resetContributions(String schema)
	{	
		// Set search_path
		String query = "SET search_path TO " + schema + " , public";
		session.createSQLQuery(query).executeUpdate();
		
		query = "SELECT FROM p_reset_contributions();"; 
		session.createSQLQuery(query).list();
		//session.createSQLQuery(query).executeUpdate();
	}
	

	/**
	 * Retrieves the best candidate according to a particular objective 
	 * function, in this case strictly storage volume.
	 * 
	 * @param noi node of interest - search is to restricted to its upstream 
	 * sub-network; ignored if null
	 * @param useArea if true, the contributing area to each node is used in 
	 * their ranking.
	 * @param useCatchments if true, the number of subcatchments upstream of 
	 * each node is used in their ranking.
	 * @param schema database schema containing the CENTAUR tables
	 * 
	 * @return the best candidate.
	 */
	static VCandidate getBestCandidate(Integer noi, boolean useArea, 
			boolean useCatchments,  String schema)
	{	
		// Set search_path
		String query = "SET search_path TO " + schema + " , public";
		session.createSQLQuery(query).executeUpdate();
		
		query = "SELECT * FROM f_optimal("; 
		if(noi != null)
			query += noi.toString() + ", ";
		else 
			query += "NULL, ";
		
		query += useArea + ", " + useCatchments + ")";
		
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
		String select = "SELECT c FROM ContributionTemp c WHERE c.candidate.idNode = :idNode";
		Query selectQuery = session.createQuery(select);
		selectQuery.setParameter("idNode", candidate.getId());
		LinkedList<ContributionTemp> contribs = new LinkedList<ContributionTemp>(selectQuery.list());
		
		for (ContributionTemp contrib : contribs) 
		{
			// weight of this subcatchment
			double weight = 
					contrib.getValue().doubleValue() / 
					candidate.getContributions().doubleValue();
			
			// total contribution from this subcatchment
			double subValue = contrib.getSubcatchment().getArea().doubleValue() * volumeH;
			
			// fraction of the subcatchment contribution stored by the gate
			double fraction = subValue / (volumeStored * weight);
			
			select = "SELECT c FROM ContributionTemp c WHERE c.subcatchment.id = :id";
			selectQuery = session.createQuery(select);
			selectQuery.setParameter("id", contrib.getSubcatchment().getId());
			LinkedList<ContributionTemp> subContribs = 
					new LinkedList<ContributionTemp>(selectQuery.list());
			
			for (ContributionTemp subContrib : subContribs)
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
	 * Finalises the calculation by Marking all the gate candidates as 
	 * available for future calculations.
	 * 
	 * @param numGates the number of gates to site.
	 */
	protected static void finalise(int numGates)
	{
		Query query = session.createQuery("update Node set taken = 'FALSE' ");
		query.executeUpdate();
		session.getTransaction().commit();
        session.beginTransaction();
        
		System.out.println("\nSucessfully sited " + numGates + " gates.");
	}
}