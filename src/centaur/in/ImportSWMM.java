package centaur.in;

import centaur.db.Node;
import centaur.db.Outfall;

import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.math.BigDecimal;
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
	
	static String commentFlag = ";";
	static String headNodeCoordinates = "[COORDINATES]";
	static String headOutfalls = "[OUTFALLS]";
	static String headJunctions = "[JUNCTIONS]";
	
	static Random generator = new Random();
	static int newIdFloor = 1000000;

	public static void main(String[] args) 
	{
		SessionFactory factory;
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
		
		clearDB(session);
		
		// Input Outfalls	
		if(advanceToMatchingString(headOutfalls) != null);
		{
			String line = scanner.nextLine();
			while(line.replaceAll("\\s+","").length() > 0)
			{
				System.out.println("Next line to process: " + line);
				
				if(!line.startsWith(commentFlag))
				{
					Node n = new Node();
					Outfall o = new Outfall();
					String[] values = line.split("\\s+");
					try // Node ids can be strings
					{
						n.setId(new Integer(values[0]));
					}
					catch (NumberFormatException e) 
					{
						n.setId(generator.nextInt() + newIdFloor);
						n.setName(values[0]);
					}
					o.setIdNode(new Integer(n.getId()));
					n.setElevation(new BigDecimal(values[1]));
					o.setType(values[2]);
					o.setGated(new Boolean(values[3]));
					o.setNode(n);
					session.save(n);
					session.save(o);
				}
				line = scanner.nextLine();
			}
		}
		System.out.println("=> Succesfully imported Outfalls");
		
		importObjects(Junction.class, headJunctions, session, tx);
		
		commitData(session, tx);
				
		// Close file and database session.
		scanner.close();
		session.close();
	}
	
	static void clearDB(Session session)
	{
		session.createQuery(String.format("delete from %s", Outfall.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Junction.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Node.class.getName())).executeUpdate();
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
						ob.importFromSWMMLine(line, session, generator);
					} 
					catch (InstantiationException | IllegalAccessException e) 
					{
						e.printStackTrace();
					}
					
				}
				line = scanner.nextLine();
			}
		}
		System.out.println("=> Succesfully imported Junctions");
	}
	
}
