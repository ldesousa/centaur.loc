/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 15-02-2016
 * Description:
 * CENTAUR specific Polygon Entity.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

// TODO: Auto-generated Javadoc
/**
 * The Class Polygon.
 */
public class Polygon /*extends centaur.db.Polygon*/ implements Importable
{
	
	/** The polygon. */
	centaur.db.Polygon polygon;

	/**
	 * Instantiates a new polygon.
	 */
	public Polygon() 
	{
		polygon = new centaur.db.Polygon();
	}
	
	/**
	 * Gets the persistent object.
	 *
	 * @return the persistent object
	 */
	public centaur.db.Polygon getPersistentObject() {return polygon;}
	
	/* (non-Javadoc)
	 * @see centaur.in.Importable#importFromSWMMLine(java.lang.String, org.hibernate.Session, java.util.Random, int)
	 */
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");
		
		polygon = new centaur.db.Polygon();
		//centaur.db.PolygonId polygonId = new centaur.db.PolygonId();
		polygon.setId(generator.nextInt(Integer.MAX_VALUE) + newIdFloor);
		if (values.length > 0) 
		{
				Subcatchment s = new Subcatchment();
				if(s.loadFromName(session, values[0])) 
					polygon.setSubcatchment(s.getPersistentObject());
		}
		if (values.length > 1) polygon.setX(new BigDecimal(values[1]));
		if (values.length > 2) polygon.setY(new BigDecimal(values[2]));
		//polygon.setId(polygonId);
		session.save(polygon);
	}

}
