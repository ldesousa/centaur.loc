/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 18-03-2016
 * Description: 
 * Main class for the optimisation package. Contains utilitary methods managing
 * the database connection.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.opt;

import java.util.LinkedList;

import org.hibernate.HibernateException;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

import centaur.db.VCandidate;

// TODO: Auto-generated Javadoc
/**
 * The Class Main.
 */
public class Main
{
	
	/** The database session factory. */
	protected static SessionFactory factory;
	
	/** The database session. */
	protected static Session session;
	
	/** The database transaction. */
	protected static Transaction tx;
	
	/**
	 * Sets the up the connection to the database, creating a new session and 
	 * initiating a transaction.
	 */
	protected static void setUpConnection()
	{
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
	
	/**
	 * Commits to the database any data modified or created during the present 
	 * session. If successful, initiates a new transaction.
	 *
	 * @param session the database session.
	 * @param tx the database transaction.
	 */
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
	
	/**
	 * Plots in a system window served areas against storage volume for each
	 * gate Candidate.
	 *
	 * @param session the database session.
	 */
	public static void plotData(Session session)
	{
		ChartXYPlot chart = new ChartXYPlot(
				"CENTAUR", 
				"Candidates capacities", 
				"Served area (?)", 
				"Volume (m³)", 
				"Candidate");
		
		Query query =  session.createQuery("from VCandidate");
		LinkedList<VCandidate> candidates = new LinkedList<VCandidate>(query.list());
		
		for (VCandidate c : candidates)
		{
			if (c.getFloodedVolume() != null)
				chart.addDataPoint(c.getServedArea().doubleValue(),
						c.getFloodedVolume().doubleValue());
		}
		
		chart.display();
	}
	
	
	/**
	 * The main method.
	 *
	 * @param args the arguments
	 */
	public static void main(final String[] args) 
	{
		setUpConnection();
		
		FloodedSegments.compute(session);
		commitData(session, tx);
		
		ServedAreas.compute(session);
		commitData(session, tx); 		
		
		plotData(session);
		
		session.close();
    }

}
