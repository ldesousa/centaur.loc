package centaur.opt;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

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
	
	public static void main(final String[] args) 
	{
		setUpConnection();
		
		FloodedSegments.compute(session);
		commitData(session, tx);
		
		ServedAreas.compute(session);
		commitData(session, tx);			
		ServedAreas.plotData(session);
		
		session.close();
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
