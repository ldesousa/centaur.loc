package centaur.in;

import centaur.db.CurveParameter;
import centaur.db.Link;
import centaur.db.Node;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.Random;
import java.util.Scanner;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

public class ImportSWMM 
{
	static String filePath = "data/Wartegg_Luzern.INP";
	static Scanner scanner;
	static SessionFactory factory;
	
	static String commentFlag = ";";
	static String headNodeCoordinates = "[COORDINATES]";
	static String headOutfalls = "[OUTFALLS]";
	static String headJunctions = "[JUNCTIONS]";
	static String headCurves = "[CURVES]";
	static String headStorages = "[STORAGE]";
	static String headPumps = "[PUMPS]";
	
	static Random generator = new Random();
	static int newIdFloor = 1000000;

	public static void main(String[] args) 
	{
		Session session;
		Transaction tx;
		
		initScanner();
		
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
	         scanner.close();
	         return;
	    }
					
		//clearDB(session);
		//commitData(session, tx);	
		
		importObjects(Outfall.class, headOutfalls, session, tx);
		importObjects(Junction.class, headJunctions, session, tx);
		importObjects(Curve.class, headCurves, session, tx);
		importObjects(Storage.class, headStorages, session, tx);
		importObjects(Pump.class, headPumps, session, tx);
				
		// Close file and database session.
		scanner.close();
		session.close();
	}
	
	static void clearDB(Session session)
	{
		session.createQuery(String.format("delete from %s", Outfall.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Junction.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Storage.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Node.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Pump.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Link.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", CurveParameter.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Curve.class.getName())).executeUpdate();
		session.flush();
	}

	static String advanceToMatchingString(String match)
	{
		scanner.reset();
		while (scanner.hasNextLine()) 
		{
	        String line = scanner.nextLine();
	        if(line.contains(match)) { return line; }
	    }
		return null;
	}
	
	static void commitData(Session session, Transaction tx)
	{
		try
		{
	         tx.commit();
	         tx = session.beginTransaction();
	    }
		catch (HibernateException e) 
		{
	         //if (tx!=null) tx.rollback();
	         System.err.println("Failed to commit objects to database: " + e);
	         e.printStackTrace();
	         scanner.close();
	         session.close();  
	         System.exit(-1); 
	    }
	}
	
	static void initScanner()
	{
		if(scanner != null)
		{
			scanner.close();
			scanner=null;
		}
		try 
		{
			 scanner = new Scanner(new FileInputStream(filePath), "UTF-8");
		}
		catch (FileNotFoundException e) 
		{
			System.out.println("Failed to open SWMM file.");
			e.printStackTrace();
			System.exit(-1);
		}
	}
	
	static void importObjects(Class dbClass, String head, Session session, Transaction tx)
	{
		initScanner();
			
		if(advanceToMatchingString(head) != null);
		{
			String line = scanner.nextLine();
			while(line.replaceAll("\\s+","").length() > 0)
			{
				System.out.println("Next line to process: " + line);
				
				if(!line.startsWith(commentFlag)) 
				{
					try 
					{
						Importable ob = (Importable) dbClass.newInstance();
						ob.importFromSWMMLine(line, session, generator, newIdFloor);
					} 
					catch (InstantiationException | IllegalAccessException e) 
					{
						e.printStackTrace();
					}
				}
				line = scanner.nextLine();
			}
		}
		commitData(session, tx);
		System.out.println("=> Succesfully imported " + dbClass.getName());
	}
	
}
