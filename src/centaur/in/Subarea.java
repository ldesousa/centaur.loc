/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 10-02-2016
 * Description:
 * CENTAUR specific Subarea Entity.
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
 * The Class Subarea.
 */
public class Subarea /*extends centaur.db.Subarea*/ implements Importable
{
	
	/** The subarea. */
	centaur.db.Subarea subarea;

	/**
	 * Instantiates a new subarea.
	 */
	public Subarea() 
	{
		subarea = new centaur.db.Subarea();
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Subarea getPersistentObject() {return subarea;}
	
	/**
	 * Loads the Subarea instance from a given name.
	 *
	 * @param session the database session.
	 * @param name the instance name to match. 
	 * @return true if an instance with a matching name was found, false 
	 * otherwise.
	 */
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Subarea.class)
			    .add(Restrictions.like("name", name.replace("_", "\\_")))
			    .list();
		
		if(list.size() > 0)
		{	
			subarea = (centaur.db.Subarea) list.get(0);
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
		
		subarea = new centaur.db.Subarea();
		if (values.length > 0) 
		{
				Subcatchment s = new Subcatchment();
				if(s.loadFromName(session, values[0])) 
					subarea.setSubcatchment(s.getPersistentObject());
		}
		if (values.length > 1) subarea.setNImperv(new BigDecimal(values[1]));
		if (values.length > 2) subarea.setNPerv(new BigDecimal(values[2]));
		if (values.length > 3) subarea.setSImperv(new BigDecimal(values[3]));
		if (values.length > 4) subarea.setSPerv(new BigDecimal(values[4]));
		if (values.length > 5) subarea.setPctZero(new BigDecimal(values[5]));
		if (values.length > 6) subarea.setRouteTo(values[6]);
		if (values.length > 7) subarea.setPctRouted(new BigDecimal(values[7]));
		session.save(subarea);
	}

}
