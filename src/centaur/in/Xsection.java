/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 09-02-2016
 * Description:
 * CENTAUR specific XSection Entity.
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
 * The Class Xsection.
 */
public class Xsection /*extends centaur.db.Xsection*/ implements Importable
{
	
	/** The xsection. */
	centaur.db.Xsection xsection;

	/**
	 * Instantiates a new xsection.
	 */
	public Xsection() 
	{
		xsection = new centaur.db.Xsection();
	}

	/**
	 * Instantiates a new xsection.
	 *
	 * @param link the link
	 */
	public Xsection(Link link) 
	{
		xsection = new centaur.db.Xsection(link.getPersistentObject());
	}
	
	/* (non-Javadoc)
	 * @see centaur.in.Importable#importFromSWMMLine(java.lang.String, org.hibernate.Session, java.util.Random, int)
	 */
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");

		xsection = new centaur.db.Xsection();
		Link l = new Link();
		if(l.loadFromName(session, values[0])) 
				xsection.setLink(l.getPersistentObject());
		if (values.length > 1) xsection.setShape(values[1]);
		if (values.length > 2) xsection.setGeom1(new BigDecimal(values[2]));
		if (values.length > 3) xsection.setGeom2(new BigDecimal(values[3]));
		if (values.length > 4) xsection.setGeom3(new BigDecimal(values[4]));
		if (values.length > 5) xsection.setGeom4(new BigDecimal(values[5]));
		if (values.length > 6) xsection.setBarrels(new BigDecimal(values[6]));
		if (values.length > 7) xsection.setCulvert(new BigDecimal(values[7]));
		session.save(xsection);
	}

}
