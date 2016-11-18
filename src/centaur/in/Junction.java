/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 04-02-2016
 * Description: 
 * CENTAUR specific Junction Entity.
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
 * The Class Junction.
 */
public class Junction /*extends centaur.db.Junction*/ implements Importable
{
	
	/** The junction. */
	centaur.db.Junction junction;

	/**
	 * Instantiates a new junction.
	 */
	public Junction() 
	{
		junction = new centaur.db.Junction();
	}

	/**
	 * Instantiates a new junction.
	 *
	 * @param node the node
	 */
	public Junction(Node node) 
	{
		junction = new centaur.db.Junction(node);
	}
	
	/* (non-Javadoc)
	 * @see centaur.in.Importable#importFromSWMMLine(java.lang.String, org.hibernate.Session, java.util.Random, int)
	 */
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{
		
		String[] values = lineSWMM.split("\\s+");

		Node n = new Node();
		try // Junction ids can be strings
		{
			n.setId(Integer.parseInt(values[0]));
		}
		catch (NumberFormatException e) 
		{
			n.setId(generator.nextInt() + newIdFloor);
			n.setName(values[0]);
		}
		n.setElevation(new BigDecimal(values[1]));
		junction = new centaur.db.Junction(n);
		junction.setMaxDepth(new BigDecimal(values[2]));
		junction.setInitDepth(new BigDecimal(values[3]));
		junction.setSurDepth(new BigDecimal(values[4]));
		junction.setAponded(new BigDecimal(values[5]));
		junction.setNode(n);
		session.save(n);
		session.save(junction);
	}

}
