package centaur.opt;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.Scanner;
import java.util.Set;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Subcatchment;
import centaur.db.Flooded;
import centaur.db.Link;


public class ComputeServedAreas {

	static SessionFactory factory;
	
	static LinkedList<Subcatchment> subcatchments;

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
		
		System.out.println("Starting up");
		
		Query query =  session.createQuery("from Subcatchment s");
		subcatchments = new LinkedList<Subcatchment>(query.list());
		
		System.out.println("Subcatchments: " + subcatchments.size());
		
		while(subcatchments.size() > 0)
		{
			Subcatchment s = subcatchments.pop();
			System.out.println("==== Processing subcatchment: " + s.getId());
			
			if(s.getNode() != null)
			{
				Candidate c = s.getNode().getCandidate();
				
				if (c != null)
				{
					if (c.getServedArea() == null) c.setServedArea(s.getArea());
					else c.setServedArea(c.getServedArea().add(s.getArea()));
					
					System.out.println("Processing node: " + c.getIdNode());
					transportDownstream(
							c.getServedArea(), 
							s.getNode().getLinksForIdNodeFrom());
				}
			}
		}
		
		commitData(session, tx);		
		session.close();
		
		System.out.println("\nSucessfully calculated served areas.");
	}
	
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
				
				System.out.println("Processing node: " + n.getCandidate().getIdNode() + 
						" sub-nodes: " + n.getLinksForIdNodeFrom().size());
				
				if(n.getLinksForIdNodeFrom().size() > 0)
					transportDownstream(n.getCandidate().getServedArea(), n.getLinksForIdNodeFrom());
			}
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
