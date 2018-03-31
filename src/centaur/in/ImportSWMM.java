/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 01-02-2016 
 * Description:
 * Imports a SWMM file into a CENTAUR schema in a PostgreSQL database. 
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.in;

import centaur.db.CurveParameter;
import centaur.db.Link;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.util.List;
import java.util.Random;
import java.util.Scanner;

import org.hibernate.HibernateException;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

// TODO: Auto-generated Javadoc
/**
 * The Class ImportSWMM.
 */
public class ImportSWMM 
{
	
	/** The input file path. */
	static String filePath = "data/Wartegg_Luzern.INP";
	
	/** The file scanner. */
	static Scanner scanner;
	
	/** The database session factory. */
	static SessionFactory factory;
	
	/** The SWMM comment flag. */
	static String commentFlag = ";";
	
	/** The header for Node coordinates. */
	static String headNodeCoordinates = "[COORDINATES]";
	
	/** The header for Outfalls. */
	static String headOutfalls = "[OUTFALLS]";
	
	/** The header for Junctions. */
	static String headJunctions = "[JUNCTIONS]";
	
	/** The header for Curves. */
	static String headCurves = "[CURVES]";
	
	/** The header for Storages. */
	static String headStorages = "[STORAGE]";
	
	/** The header for Pumps. */
	static String headPumps = "[PUMPS]";
	
	/** The header for Weirs. */
	static String headWeirs = "[WEIRS]";
	
	/** The header for Conduits. */
	static String headConduits = "[CONDUITS]";
	
	/** The header for XSections. */
	static String headXSections = "[XSECTIONS]";
	
	/** The head for Subcatchments. */
	static String headSubcatchments = "[SUBCATCHMENTS]";
	
	/** The header for Subareas. */
	static String headSubareas = "[SUBAREAS]";
	
	/** The header for Raingages. */
	static String headRaingages = "[RAINGAGES]";
	
	/** The header for Coordinates. */
	static String headCoordinates = "[COORDINATES]";
	
	/** The header for Polygons. */
	static String headPolygons = "[Polygons]";
	static String headPolygonsAlternative = "[POLYGONS]";
	
	/** The random generator. */
	static Random generator = new Random();
	
	/** The new id floor, to distinguish from SWMM ids. */
	static int newIdFloor = 1000000;

	/**
	 * The main method.
	 *
	 * @param args the arguments
	 */
	public static void main(String[] args) 
	{
		Session session;
		Transaction tx;
		String schema = args[0];
		filePath = args[1];
		
		initScanner();
		
		// Initialise database session
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
	         scanner.close();
	         return;
	    }
		
		clearDB(session);
		commitData(session, tx);	
		
		importObjects(Outfall.class, headOutfalls, session, tx);
		importObjects(Junction.class, headJunctions, session, tx);
		importObjects(Curve.class, headCurves, session, tx);
		importObjects(Storage.class, headStorages, session, tx);
		importObjects(Pump.class, headPumps, session, tx);
		importObjects(Weir.class, headWeirs, session, tx);
		importObjects(Conduit.class, headConduits, session, tx);
		importObjects(Xsection.class, headXSections, session, tx);
		importObjects(Raingage.class, headRaingages, session, tx);
		importObjects(Subcatchment.class, headSubcatchments, session, tx);
		importObjects(Subarea.class, headSubareas, session, tx);
		
		//Geometries
		importObjects(Coordinates.class, headCoordinates, session, tx);
		if(!importObjects(Polygon.class, headPolygons, session, tx))
			importObjects(Polygon.class, headPolygonsAlternative, session, tx);
		
		createSpatialObjects(session, schema);
				
		// Close file and database session.
		scanner.close();
		session.close();
		
		System.out.println();
		System.out.println("##############################################");
		System.out.println("# Finished importing relations from INP file #");
		System.out.println("##############################################");
		System.out.println();
	}
	
	/**
	 * Clears all the database tables.
	 *
	 * @param session the database session.
	 */
	static void clearDB(Session session)
	{
		session.createQuery(String.format("delete from %s", Outfall.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Junction.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Storage.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Subarea.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Subcatchment.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Raingage.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Node.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Pump.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Weir.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Conduit.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Xsection.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Link.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", CurveParameter.class.getName())).executeUpdate();
		session.createQuery(String.format("delete from %s", Curve.class.getName())).executeUpdate();
		session.flush();
	}

	/**
	 * Advances the file scanner to the line matching a given string.
	 *
	 * @param match the string to match
	 * @return the line containing the string to match, or null if the string 
	 * is not found.
	 */
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
	
	/**
	 * Commits new and updated data to the database.
	 *
	 * @param session the database session
	 * @param tx the database transaction
	 */
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
	
	/**
	 * Initialises the file scanner.
	 */
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
	
	/**
	 * Imports all the objects of a given Entity into the CENTAUR schema.
	 *
	 * @param dbClass the Entity to import.
	 * @param head the header string identifying the Entity section in the input SWMM file.
	 * @param session the database session.
	 * @param tx the database transaction.
	 * @return true if the section found was found, false otherwise.
	 */
	static boolean importObjects(Class dbClass, String head, Session session, Transaction tx)
	{
		initScanner();
			
		if(advanceToMatchingString(head) != null)
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
			commitData(session, tx);
			System.out.println("=> Succesfully imported " + dbClass.getName());
			return true;
		}
		else return false;
	}
	
	/**
	 * Creates the appropriate database spatial objects from the raw 
	 * coordinates in the .inp file. Uses special database functions.
	 * 
	 * @param session database session object
	 * @param schema database schema containing the CENTAUR tables
	 */
	static void createSpatialObjects(Session session, String schema)
	{
		System.out.println("\nCreating spatial objects... ");
		// Set search_path
		String query = "SET search_path TO " + schema + " , public";
		session.createSQLQuery(query).executeUpdate();

		query = "SELECT create_nodes();";
		Integer num = new Integer(session.createSQLQuery(query).list().get(0).toString());
		if (num == 0)
			System.out.println("All spatial node objects created correctly.");
		else
			System.out.println("Failed to create " + num.toString() + " spatial nodes.");
		
		query = "SELECT create_polygons();";
		num = new Integer(session.createSQLQuery(query).list().get(0).toString());
		if (num == 0)
			System.out.println("All spatial polygon objects created correctly.");
		else
			System.out.println("Failed to create " + num.toString() + " spatial polygons.");
		
		query = "SELECT create_links();";
		num = new Integer(session.createSQLQuery(query).list().get(0).toString());
		if (num == 0)
			System.out.println("All spatial link objects created correctly.");
		else
			System.out.println("Failed to create " + num.toString() + " spatial links.");
	}
	
}
