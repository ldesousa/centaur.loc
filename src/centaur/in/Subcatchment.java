/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 10-02-2016
 * Description:
 * CENTAUR specific Subcatchment Entity.
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
 * The Class Subcatchment.
 */
public class Subcatchment /*extends centaur.db.Subcatchment*/ implements Importable
{
	
	/** The subcatchment. */
	centaur.db.Subcatchment subcatchment;

	/**
	 * Instantiates a new subcatchment.
	 */
	public Subcatchment() 
	{
		subcatchment = new centaur.db.Subcatchment();
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Subcatchment getPersistentObject() {return subcatchment;}
	
	/**
	 * Loads the Subcatchment instance from a given name.
	 *
	 * @param session the database session.
	 * @param name the instance name to match. 
	 * @return true if an instance with a matching name was found, false 
	 * otherwise.
	 */
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Subcatchment.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			subcatchment = (centaur.db.Subcatchment) list.get(0);
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
		
		subcatchment = new centaur.db.Subcatchment();
		subcatchment.setId(generator.nextInt() + newIdFloor);
		if (values.length > 0) subcatchment.setName(values[0]);
		if (values.length > 1) 
		{
				subcatchment.setRaingage(
						session.load(centaur.db.Raingage.class, new Integer(values[1])));
		}
		if (values.length > 2) 
		{
				Node n = new Node();
				if(n.loadFromName(session, values[2])) 
					subcatchment.setNode(n.getPersistentObject());
		}
		if (values.length > 3) subcatchment.setArea(new BigDecimal(values[3]));
		if (values.length > 4) subcatchment.setImperv(new BigDecimal(values[4]));
		if (values.length > 5) subcatchment.setWidth(new BigDecimal(values[5]));
		if (values.length > 6) subcatchment.setSlope(new BigDecimal(values[6]));
		if (values.length > 7) subcatchment.setCurbLen(new BigDecimal(values[7]));
		if (values.length > 8) subcatchment.setSnowPack(values[8]);
		session.save(subcatchment);
	}

}
