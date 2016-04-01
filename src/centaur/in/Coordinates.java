/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 15-02-2016
 * Description:
 * CENTAUR specific Coordinates Entity.
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
 * The Class Coordinates.
 */
public class Coordinates /*extends centaur.db.Coordinates*/ implements Importable
{
	
	/** The coordinates. */
	centaur.db.Coordinates coordinates;

	/**
	 * Instantiates a new coordinates.
	 */
	public Coordinates() 
	{
		coordinates = new centaur.db.Coordinates();
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Coordinates getPersistentObject() {return coordinates;}
	
	/* (non-Javadoc)
	 * @see centaur.in.Importable#importFromSWMMLine(java.lang.String, org.hibernate.Session, java.util.Random, int)
	 */
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");
		
		coordinates = new centaur.db.Coordinates();
		if (values.length > 0) 
		{
			try
			{
				coordinates.setNode(
						session.load(centaur.db.Node.class, new Integer(values[0])));
			}
			catch(NumberFormatException e)
			{
				Node n = new Node();
				if(n.loadFromName(session, values[0]))
					coordinates.setNode(n.getPersistentObject());
			}
		}
		if (values.length > 1) coordinates.setX(new BigDecimal(values[1]));
		if (values.length > 2) coordinates.setY(new BigDecimal(values[2]));
		session.save(coordinates);
	}

}
