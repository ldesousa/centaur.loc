package centaur.opt;

import java.util.LinkedList;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

import centaur.db.Candidate;

public class Main
{
	protected static SessionFactory factory;
	protected static Session session;
	protected static Transaction tx;
	
	public Main() {}
	
	protected static void setUpConnection()
	{
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
	
	public static void plotData(Session session)
	{
		ChartXYPlot chart = new ChartXYPlot(
				"CENTAUR", 
				"Candidates capacities", 
				"Served area (?)", 
				"Volume (m³)", 
				"Candidate");
		
		Query query =  session.createQuery("from Candidate s");
		LinkedList<Candidate> candidates = new LinkedList<Candidate>(query.list());
		
		for (Candidate c : candidates)
		{
			if (c.getFloodedVolume() != null)
				chart.addDataPoint(c.getServedArea().doubleValue(),
						c.getFloodedVolume().doubleValue());
		}
		
		chart.display();
	}
	
	
	public static void main(final String[] args) 
	{
		setUpConnection();
		
		/*FloodedSegments.compute(session);
		commitData(session, tx);*/
		
		ServedAreas.compute(session);
		commitData(session, tx);			
		
		plotData(session);
		
		session.close();
    }

}
