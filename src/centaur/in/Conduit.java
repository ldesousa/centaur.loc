/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 09-03-2016
 * Description:
 * CENTAUR specific Conduit Entity.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.in;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

import centaur.db.Link;
import centaur.db.Node;

// TODO: Auto-generated Javadoc
/**
 * The Class Conduit.
 */
public class Conduit /*extends centaur.db.Conduit*/ implements Importable
{
	
	/** The conduit. */
	centaur.db.Conduit conduit;

	/**
	 * Instantiates a new conduit.
	 */
	public Conduit() 
	{
		conduit = new centaur.db.Conduit();
	}

	/**
	 * Instantiates a new conduit.
	 *
	 * @param link the link
	 */
	public Conduit(Link link) 
	{
		conduit = new centaur.db.Conduit(link);
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Conduit getPersistentObject() {return conduit;}
	
	/**
	 * Loads the database Conduit instance from a given name.
	 *
	 * @param session the database session.
	 * @param name the instance name to match. 
	 * @return true if an instance with a matching name was found, false 
	 * otherwise.
	 */
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Conduit.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			conduit = (centaur.db.Conduit) list.get(0);
			return true;
		}
		else return false;
	}
	
	/* (non-Javadoc)
	 * @see centaur.in.Importable#importFromSWMMLine(java.lang.String, org.hibernate.Session, java.util.Random, int)
	 */
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{
		String[] values = lineSWMM.split("\\s+");

		Link l = new Link();
		try // Node ids can be strings
		{
			l.setId(Integer.parseInt(values[0]));
		}
		catch (NumberFormatException e) 
		{
			l.setId(generator.nextInt() + newIdFloor);
			l.setName(values[0]);
		}
		if (values.length > 1) 
		{
			try // Node ids can be strings
			{
				l.setNodeByIdNodeTo((Node) session.load(
						Node.class, new Integer(values[1])));
			}
			catch (NumberFormatException e) 
			{
				centaur.in.Node from = new centaur.in.Node();
				if(from.loadFromName(session, values[1]))
					l.setNodeByIdNodeTo(from.getPersistentObject());
				else 
					System.out.println("[Warning]: Could not find from node for Conduit " + values[0]);
			}
		}
		if (values.length > 2) 
		{
			try // Node ids can be strings
			{
				l.setNodeByIdNodeTo((centaur.db.Node) session.load(
						centaur.db.Node.class, new Integer(values[2])));
			}
			catch (NumberFormatException e) 
			{
				centaur.in.Node n = new centaur.in.Node();
				if(n.loadFromName(session, values[2])) 
					l.setNodeByIdNodeTo(n.getPersistentObject());
			}
		}
		conduit = new centaur.db.Conduit(l);
		if (values.length > 3) conduit.setLength(new BigDecimal(values[3]));
		if (values.length > 4) conduit.setRoughness(new BigDecimal(values[4]));
		if (values.length > 5) conduit.setInOffset(new BigDecimal(values[5]));
		if (values.length > 6) conduit.setOutOffset(new BigDecimal(values[6]));
		if (values.length > 7) conduit.setInitFlow(new BigDecimal(values[7]));
		if (values.length > 8) conduit.setMaxFlow(new BigDecimal(values[8]));		
		session.save(l);
		session.save(conduit);
	}

}
