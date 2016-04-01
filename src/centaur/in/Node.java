/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 09-02-2016
 * Description:
 * CENTAUR specific Node Entity.
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
 * The Class Node.
 */
public class Node
{
	
	/** The node. */
	centaur.db.Node node;

	/**
	 * Instantiates a new node.
	 */
	public Node() 
	{
		node = new centaur.db.Node();
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Node getPersistentObject() {return node;}
	
	/**
	 * Loads the Node instance from a given name.
	 *
	 * @param session the database session.
	 * @param name the instance name to match. 
	 * @return true if an instance with a matching name was found, false 
	 * otherwise.
	 */
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Node.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			node = (centaur.db.Node) list.get(0);
			return true;
		}
		else return false;
	}
}
