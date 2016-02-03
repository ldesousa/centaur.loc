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
	
	static int newIdFloor = 1000000;

	public static void main(String[] args) 
	{
		SessionFactory factory;
		Session session;
		Transaction tx;
		Random generator = new Random();
		
		// Open SWMM file
		try 
		{
			 //scanner = new Scanner(new File(filePath));
			 scanner = new Scanner(new FileInputStream(filePath), "UTF-8");
		}
		catch (FileNotFoundException e) 
		{
			System.out.println("Failed to open SWMM file.");
			e.printStackTrace();
			return;
		}
		
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
			
			try
			{
		         tx.commit();
		    }
			catch (HibernateException e) 
			{
		         if (tx!=null) tx.rollback();
		         System.err.println("Failed to commit Outfalls to database: " + e);
		         e.printStackTrace();
		         scanner.close();
		         session.close();  
		         return; 
		    }
		}
		System.out.println("=> Succesfully imported Outfalls");
		
		
		// Close file and database session.
		scanner.close();
		session.close();
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
	
}
