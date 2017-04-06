package centaur.var;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.LinkedList;
import java.util.Scanner;
import org.apache.commons.math3.stat.descriptive.SummaryStatistics;
import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

import centaur.db.Node;
import centaur.db.SimNode;
import centaur.db.SimNodeId;
import centaur.db.Simulation;


public class ReadOutput {
	
	/** The database session factory. */
	protected static SessionFactory factory;
	
	/** The database session. */
	protected static Session session;
	
	/** The database transaction. */
	protected static Transaction tx;
	
	/** The subcatchment collection. */
	static LinkedList<Node> nodes;
	
	/** Scanner to read command line output */
	protected static Scanner s;

	public ReadOutput() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		//,1,0"; 
		double[] series = new double[120/5 + 2];
		SummaryStatistics stats = new SummaryStatistics();
		
        String schema = "luzern";
		setUpConnection(schema);
		
		Simulation sim = new Simulation("No Variability 2 minutes");
		sim.setDetails("Rainfall event: 40 mm in 2 hours following a Gompertz curve.\n"
				     + "No noise - same input for all subcatchments.");
		session.save(sim);
		
		Query query =  session.createQuery("from Node n");
		nodes = new LinkedList<Node>(query.list());
		
		for(Node n : nodes)
		{	
			if(n.getName() == null) n.setName(String.valueOf(n.getId()));
			System.out.println("\n### PRocessing node: " + n.getId() + " | " + n.getName());
		
			String cmd = "swmmtoolbox extract data/Wartegg_Luzern_Sim_NoVar_output.bin node,";
			cmd += n.getName() + ",0";
			openRuntime(cmd);			
			// Ditch the first line, it is just the header
			if (s.hasNext()) s.next();
			
			stats.clear();
			double previous = 0;
			while (s.hasNext())
			{
				//System.out.println(s.next().split(",")[1]);
				double val = new Double(s.next().split(",")[1]);
				stats.addValue(Math.abs(val - previous));
				previous = val;
			}
			
			closeRuntime();
			System.out.println("SAmples: " + stats.getN());
			System.out.println("Average: " + stats.getMean());
			System.out.println("StdDev : " + stats.getStandardDeviation());
			System.out.println("Max    : " + stats.getMax());
			
			if(stats.getN() > 0)
			{
				SimNode sn = new SimNode();
				sn.setId(new SimNodeId(n.getId(),sim.getId()));
				sn.setNode(n);
				sn.setSimulation(sim);
				sn.setAverage(new BigDecimal(stats.getMean()));
				sn.setStddev(new BigDecimal(stats.getStandardDeviation()));
				sn.setMax(new BigDecimal(stats.getMean()));
				sn.setMin(new BigDecimal(stats.getMean()));
				session.save(sn);
			}
		}
		
		tx.commit();
		session.close();
		System.out.println("\nAll done!");
	}
	
	public static void openRuntime(String cmd)
	{
		try
		{
	        Process proc = Runtime.getRuntime().exec(cmd);
	        java.io.InputStream is = proc.getInputStream();
	        s = new java.util.Scanner(is).useDelimiter("\n");
		}
        catch (IOException e) 
        {
			e.printStackTrace();
		}
	}
	
	public static void closeRuntime()
	{
		try
		{
	        if(s != null) s.close();
		}
        catch (Exception e) 
        {
			e.printStackTrace();
		}
	}
	
	/**
	 * Sets the up the connection to the database, creating a new session and 
	 * initiating a transaction.
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

}
