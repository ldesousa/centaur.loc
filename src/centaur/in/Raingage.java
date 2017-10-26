/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 10-02-2016
 * Description:
 * CENTAUR specific Raingage Entity.
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

// TODO: Auto-generated Javadoc
/**
 * The Class Raingage.
 */
public class Raingage implements Importable
{
	
	/** The raingage. */
	centaur.db.Raingage raingage;

	/**
	 * Instantiates a new raingage.
	 */
	public Raingage() 
	{
		raingage = new centaur.db.Raingage();
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Raingage getPersistentObject() {return raingage;}
	
	/**
	 * Loads the Raingage instance from a given name.
	 *
	 * @param session the database session.
	 * @param name the instance name to match. 
	 * @return true if an instance with a matching name was found, false 
	 * otherwise.
	 */
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Raingage.class)
			    .add(Restrictions.like("name", name.replace("_", "\\_")))
			    .list();
		
		if(list.size() > 0)
		{	
			raingage = (centaur.db.Raingage) list.get(0);
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
		String source = "";
		
		raingage = new centaur.db.Raingage();
		if (values.length > 0) raingage.setId(new Integer(values[0]));
		if (values.length > 1) raingage.setFormat(values[1]);
		if (values.length > 2) raingage.setInterval(values[2]);
		if (values.length > 3) raingage.setScf(new BigDecimal(values[3]));
		// The source field is composed by several strings
		for (int i = 4; i < values.length; i++) source += values[i] + "\t"; 
		raingage.setSource(source);
		session.save(raingage);
	}
}
