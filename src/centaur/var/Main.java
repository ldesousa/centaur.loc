package centaur.var;

import java.io.BufferedWriter;
import java.io.FileWriter;
import java.io.IOException;
import java.util.LinkedList;
import java.util.List;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;
import org.rosuda.JRI.REXP;
import org.rosuda.JRI.Rengine;

import centaur.db.Node;
import centaur.db.Subcatchment;
import centaur.db.VCandidate;

public class Main {
	
	// Note that these coordinates are divided by 10 to speed computation
	static int minX = 66660;
	static int maxX = 66805;
	static int minY = 20930;
	static int maxY = 21056;
	
	static int numSims = 120/5 + 1;
	
	static String noiseSim = "noise";
	
	/** The database session factory. */
	protected static SessionFactory factory;
	
	/** The database session. */
	protected static Session session;
	
	/** The database transaction. */
	protected static Transaction tx;
	
	/** The subcatchment collection. */
	static LinkedList<Subcatchment> subcatchments;
	
	static String FILENAME = "/home/desouslu/Desktop/out.inp";
	
	static BufferedWriter writer;
	
	static FileWriter file;

	public Main() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		if (!OpenTextFile()) System.exit(-1);

        // Start Rengine.
        Rengine engine = new Rengine(new String[] { "--no-save" }, false, null);
        
        CreateNoiseFields(engine);
        
        String schema = "luzern";
		setUpConnection(schema);
		Query query =  session.createQuery("from Subcatchment s");
		subcatchments = new LinkedList<Subcatchment>(query.list());
		
		WriteRaingageHeader();
		
		// Write out raingages
		for(Subcatchment sub : subcatchments)
		{
			WriteContentToFile("Gage_" + sub.getName() + 
							   "            VOLUME    0:05   1.0    TIMESERIES TS_" + sub.getName() + "\n");
		}
		
		WriteTimeSeriesHeader();
		
		for(Subcatchment sub : subcatchments)
		{
			double[] coords = getNodeCoords(schema, sub.getNode().getId());
			
			System.out.println("\n### PRocessing subcatchment: " + sub.getName());
			
			// Note the division by 10.
	    	int vectorCoord = ((int) Math.round(coords[0] / 10) - minX) + 
	    					 (((int) Math.round(coords[1] / 10) - minY) * (maxY - minY));
			
	    	System.out.println("x coord: " + (Math.round(coords[0] / 10) - minX));
	    	System.out.println("y coord: " + ((Math.round(coords[1] / 10) - minY) * (maxY - minY)));
	    	
			double[] values = GenerateSeries(engine, vectorCoord);
			
			for(int i = 0; i < values.length; i++)
				WriteContentToFile("TS_" + sub.getName() + "\t\t" + 
								   (5 * i / 60) + ":" + (5 * i % 60) + "\t" + 
						           values[i] + "\n");
			
			//System.exit(0);
		}
		
		CloseTextFile();
	}
	
	static protected Boolean OpenTextFile()
	{
		try 
        {
			file = new FileWriter(FILENAME);
			writer = new BufferedWriter(file);
		} 
        catch (IOException e) 
        {
			e.printStackTrace();
			CloseTextFile();
			return false;
		} 
		return true;
	}
	
	static protected void WriteContentToFile(String content)
	{
		try 
        {
			writer.write(content);
		} 
        catch (IOException e) 
        {
			e.printStackTrace();
		} 
	}
	
	static protected void CloseTextFile()
	{
		try 
		{
			if (writer != null)
				writer.close();

			if (file != null)
				file.close();
		} 
		catch (IOException ex) 
		{
			ex.printStackTrace();
		}
	}
	
	static protected void CreateNoiseFields(Rengine engine)
	{
        engine.eval("library(gstat)");
        engine.eval("library(sp)");
        
        engine.eval("xy <- expand.grid(" + minX + ":" + maxX + ", " + minY + ":" + maxY + ")");
        engine.eval("names(xy) <- c('x','y')");
        engine.eval("g.dummy <- gstat(formula=z~1, locations=~x+y, dummy=T, "
        		  + "beta=0, model=vgm(psill=0.025, range=5, model='Exp'), nmax=20)");
        engine.eval(noiseSim + " <- predict(g.dummy, newdata=xy, nsim=" + numSims + ")");
        engine.eval("gridded(" + noiseSim + ") = ~x+y");
	}
	
	static public double[] GenerateSeries(Rengine engine, int vectorCoord)
    {
    	double[] values = new double[numSims];
    	double sum = 0;
    	double sumExpected = 480;
    	int numPositive = 0;
    	
    	for (int time = 0, sim=1; time <= 120; time += 5, sim++)
    	{
    		String simName = noiseSim + "[" + String.valueOf(sim) + "]$sim" + String.valueOf(sim);
    		values[sim-1] = Surge(time / 60.0, engine, simName, vectorCoord);
    		sum += values[sim-1];
    		if (values[sim-1] > 0) numPositive++;
    	}
    	
    	double corr = (sum - sumExpected) / numPositive;
    	
    	System.out.println("Sum: " + sum);
    	System.out.println("Corr: " + corr);
    	
    	for (int i = 0; i < values.length; i++)
    		if (values[i] > 0) values[i] -= corr;

    	return values;
    }
    
    static public double Surge(double time, Rengine engine, String simName, int vectorCoord)
    {
    	double A = 280.0;
    	double b = 2.6;
    	double maxVar = 32.0;
    	double value = A * time * Math.exp(-b * time);
    	String coord = String.valueOf(vectorCoord);
    	REXP noise = engine.eval(simName + "[" + coord + "]");
    	//System.out.println(simName + "[" + coord + "]");
    	value += noise.asDouble() * maxVar;
    	if(value > 0) return value;
    	else return 0;
    }
    
    /**
	 * Retrieves the cartographic coordinates of a node.
	 * 
	 * @param schema database schema containing the CENTAUR tables.
	 * @param nodeId identifier of the node.
	 * 
	 * @return vector with node coordinates [x, y].
	 */
	static double[] getNodeCoords(String schema, Integer nodeId)
	{	
		double[] coords = new double[2];
		
		// Set search_path
		String query = "SET search_path TO " + schema + " , public";
		session.createSQLQuery(query).executeUpdate();
		
		query = "SELECT ST_X(geom) FROM node WHERE id = " + nodeId;
		coords[0] = Double.parseDouble(session.createSQLQuery(query).list().get(0).toString());
		
		query = "SELECT ST_Y(geom) FROM node WHERE id = " + nodeId;
		coords[1] = Double.parseDouble(session.createSQLQuery(query).list().get(0).toString());
		
		return coords;
	}
	
	protected static void WriteRaingageHeader()
	{
		WriteContentToFile("\n[RAINGAGES]\n");
		WriteContentToFile(";;               Rain      Time   Snow   Data\n");
		WriteContentToFile(";;Name           Type      Intrvl Catch  Source\n");
		WriteContentToFile(";;-------------- --------- ------ ------ ----------\n");
	}
	
	protected static void WriteTimeSeriesHeader()
	{
		WriteContentToFile("\n[TIMESERIES]\n");
		WriteContentToFile(";;Name           Date       Time       Value\n");
		WriteContentToFile(";;-------------- ---------- ---------- ----------\n");
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
