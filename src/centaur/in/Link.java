/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 09-02-2016
 * Description:
 * CENTAUR specific Link Entity.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.in;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;


// TODO: Auto-generated Javadoc
/**
 * The Class Link.
 */
public class Link
{
	
	/** The link. */
	centaur.db.Link link;

	/**
	 * Instantiates a new link.
	 */
	public Link() 
	{
		link = new centaur.db.Link();
	}
	
	public Link(String[] values, Integer newId, Session session)
	{
		link = new centaur.db.Link();
		link.setId(newId);
		link.setName(values[0]);
		if (values.length > 1) 
		{
			centaur.in.Node from = new centaur.in.Node();
			if(from.loadFromName(session, values[1]))
				link.setNodeByIdNodeFrom(from.getPersistentObject());
			else 
				System.out.println("[Warning]: Could not find FROM node for Conduit " + values[0]);
		}
		if (values.length > 2) 
		{
			centaur.in.Node n = new centaur.in.Node();
			if(n.loadFromName(session, values[2])) 
				link.setNodeByIdNodeTo(n.getPersistentObject());
			else 
				System.out.println("[Warning]: Could not find TO node for Conduit " + values[0]);
		}
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Link getPersistentObject() {return link;}
	
	/**
	 * Loads the Link instance from a given name.
	 *
	 * @param session the database session.
	 * @param name the instance name to match. 
	 * @return true if an instance with a matching name was found, false 
	 * otherwise.
	 */
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Link.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			link = (centaur.db.Link) list.get(0);
			return true;
		}
		else return false;
	}
}
