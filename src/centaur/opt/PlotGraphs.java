/* ****************************************************************************
 * Copyright (c) 2017 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 27-07-2016
 * Description: 
 * Main class for the optimisation package. Contains utilitary methods managing
 * the database connection.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.opt;

import java.awt.BorderLayout;
import java.util.LinkedList;

import javax.swing.JFrame;

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
public class PlotGraphs
{
	
	/** The database session factory. */
	protected static SessionFactory factory;
	
	/** The database session. */
	protected static Session session;
	
	/** The database transaction. */
	protected static Transaction tx;
	
	/** The XY plot of Volume vs Area */
	protected static ChartXYPlot chartXYVolArea;
	
	/** The plot of Volume ranking */
	protected static ChartXYPlot chartRankVolume;
	
	/** The plot of Area ranking */
	protected static ChartXYPlot chartRankArea;
	
	/**
	 * Sets the up the connection to the database, creating a new session and 
	 * initiating a transaction.
	 * 
	 * @param schema the databse schema.
	 */
	protected static void setUpConnection(String schema)
	{
		try
		{
	         factory = new Configuration()
	        		 .configure(schema + ".cfg.xml").buildSessionFactory();	         
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
	 * Plots in a system window served areas against storage volume for each
	 * gate Candidate.
	 *
	 * @param session the database session.
	 */
	public static void plotData(Session session)
	{
		chartXYVolArea = new ChartXYPlot(
				"CENTAUR", 
				"Candidates capacities", 
				"Served area (ha)", 
				"Storage volume (m³)", 
				"Candidate");
		
		Query query =  session.createQuery("from VCandidate");
		LinkedList<VCandidate> candidates = new LinkedList<VCandidate>(query.list());
		
		for (VCandidate c : candidates)
		{
			if (c.getFloodedVolume() != null)
				chartXYVolArea.addDataPoint(c.getServedArea().doubleValue(),
						c.getFloodedVolume().doubleValue());
		}
	}
	
	/**
	 * Plots in a system window gate Candidates ranked by floodable volume.
	 *
	 * @param session the database session.
	 */
	public static void plotVolumeRank(Session session)
	{
		chartRankVolume = new ChartXYPlot(
				"CENTAUR", 
				"Candidates ranked by storage Volume", 
				"Rank", 
				"Volume (m³)", 
				"Candidate");
		
		Query query =  session.createQuery("FROM VCandidate ORDER BY flooded_volume DESC");
		LinkedList<VCandidate> candidates = new LinkedList<VCandidate>(query.list());
		
		int i = 1;
		for (VCandidate c : candidates)
			if (c.getFloodedVolume() != null)
				chartRankVolume.addDataPoint(i++, c.getFloodedVolume().doubleValue());
	}
	
	/**
	 * Plots in a system window gate Candidates ranked by served area.
	 *
	 * @param session the database session.
	 */
	public static void plotAreaRank(Session session)
	{
		chartRankArea = new ChartXYPlot(
				"CENTAUR", 
				"Candidates ranked by served Area", 
				"Rank", 
				"Area (ha)", 
				"Candidate");
		
		Query query =  session.createQuery("FROM VCandidate ORDER BY served_area DESC");
		LinkedList<VCandidate> candidates = new LinkedList<VCandidate>(query.list());
		
		int i = 1;
		for (VCandidate c : candidates)
			if (c.getServedArea() != null)
				chartRankArea.addDataPoint(i++, c.getServedArea().doubleValue());
	}
	
	public static void plotAllGraphs(Session session)
	{		
		plotData(session);
		plotVolumeRank(session);
		plotAreaRank(session);
		
		JFrame frame = new JFrame("CENTAUR");
		frame.getContentPane().add(chartXYVolArea.getChartPanel(), BorderLayout.NORTH);
		frame.getContentPane().add(chartRankArea.getChartPanel(), BorderLayout.WEST);
		frame.getContentPane().add(chartRankVolume.getChartPanel(), BorderLayout.EAST);
		frame.pack();
		frame.setVisible(true);
	}
	
	
	/**
	 * The main method.
	 *
	 * @param args the arguments
	 */
	public static void main(final String[] args) 
	{
		if(args.length < 1)
		{
			System.out.println("Please provide the database schema.");
			System.exit(-1);
		}
		String schema = args[0];
		setUpConnection(schema);
			
		plotAllGraphs(session);
		
		session.close();
    }

}
