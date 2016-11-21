/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 04-02-2016
 * Description:
 * CENTAUR specific Outfall Entity.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

import centaur.db.Node;

// TODO: Auto-generated Javadoc
/**
 * The Class Outfall.
 */
public class Outfall /*extends centaur.db.Outfall*/ implements Importable
{
	
	/** The outfall. */
	centaur.db.Outfall outfall;

	/**
	 * Instantiates a new outfall.
	 */
	public Outfall() 
	{
		outfall = new centaur.db.Outfall();
	}

	/**
	 * Instantiates a new outfall.
	 *
	 * @param node the node
	 */
	public Outfall(Node node) 
	{
		outfall = new centaur.db.Outfall(node);
	}
	
	/* (non-Javadoc)
	 * @see centaur.in.Importable#importFromSWMMLine(java.lang.String, org.hibernate.Session, java.util.Random, int)
	 */
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{
		
		String[] values = lineSWMM.split("\\s+");

		Node n = new Node();
		n.setId(generator.nextInt() + newIdFloor);
		n.setName(values[0]);
		n.setElevation(new BigDecimal(values[1]));
		outfall.setNode(n);
		outfall.setType(values[2]);
		outfall.setGated(new Boolean(values[3]));
		session.save(n);
		session.save(outfall);
	}

}
