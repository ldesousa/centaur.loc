package centaur.opt;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Set;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Flooded;
import centaur.db.Link;


public class ComputeFloodedSegments {

	static SessionFactory factory;
	
	static BigDecimal safetyMargin = new BigDecimal(0.9);
	static LinkedList<Node> prospects;
	static ArrayList<Node> candidates = new ArrayList<Node>();
	static ArrayList<Node> visited = new ArrayList<Node>();
	static ArrayList<Link> floodedLinks = new ArrayList<Link>();
	
	static BigDecimal currentOverflow = BigDecimal.valueOf(Double.MAX_VALUE);

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Session session;
		Transaction tx;
		
		// => This code is common to ImportSWMM - must be refactored
		// Initialise database session
		try
		{
	         factory = new Configuration()
	        		 .configure("centaur.cfg.xml").buildSessionFactory();
	         session = factory.openSession();
	         tx = session.beginTransaction();
	    }
		catch (Throwable e) 
		{ 
	         System.err.println("Failed to initialise database session: " + e);
	         e.printStackTrace();
	         return;
	    }
			
		System.out.println("Clearing database ...");
		clearDB(session);
		
		Query query =  session.createQuery("from Node n");
		prospects = new LinkedList<Node>(query.list());
		
		while(prospects.size() > 0)
		{
			System.out.println("Candidates: " + prospects.size());
			Node n = prospects.pop();
			if(!visited.contains(n))
			{
				visited.add(n);						
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
					System.out.println("Visited: " + visited.size());
				}
			}
		}
		
		System.out.println("\nProposed candidates: ");
		for (Node g : candidates) System.out.println(g.getId());
		
		commitData(session, tx);		
		session.close();
	}
	
	static void clearDB(Session session)
	{
		session.createQuery(String.format("delete from %s", Flooded.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Candidate.class.getName())).executeUpdate();
		session.flush();
	}

	protected static void analyseNode(Node n)
	{
		Set<Link> links = n.getLinksForIdNodeTo();
		
		// Search stops if:
		// 1. No links arrive at this node;
		// 2. This node is an outfall or a storage.
		if((links.size() <= 0) || (n.getOutfall() != null) || (n.getStorage() != null))
			updateCurrentOverflow(n.getElevation(), BigDecimal.ZERO);
		else
		{
			updateCurrentOverflow(n.getElevation(), n.getJunction().getMaxDepth());
			searchLinks(links);
		}
	}
	
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
	
	protected static void updateCurrentOverflow(BigDecimal newLevel, BigDecimal depth)
	{
		newLevel = newLevel.add(depth.multiply(safetyMargin));
		if(newLevel.compareTo(currentOverflow) < 0) 
			currentOverflow = newLevel;
	}
	
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
	
	protected static void save(Node n, Session session)
	{
		Candidate c = new Candidate(n, currentOverflow);
		session.save(c);
		for(Link l : floodedLinks)
		{
			Flooded f = new Flooded(c, l);
			session.save(f);
		}
	}
	
	protected static void commitData(Session session, Transaction tx)
	{
		try
		{
	         tx.commit();
	         tx = session.beginTransaction();
	    }
		catch (HibernateException e) 
		{
	         System.err.println("Failed to commit objects to database: " + e);
	         e.printStackTrace();
	         session.close();  
	         System.exit(-1); 
	    }
	}

}
