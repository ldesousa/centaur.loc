/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 04-02-2016
 * Description:
 * Interface for the CENTAUR specific Entities.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
package centaur.in;

import java.util.Random;

import org.hibernate.Session;
import org.hibernate.Transaction;

// TODO: Auto-generated Javadoc
/**
 * The Interface Importable.
 */
public interface Importable 
{
	
	/**
	 * Import an instance of this Entity to the database from a SWMM file line.
	 *
	 * @param lineSWMM the line in the SWMM file.
	 * @param session the database session.
	 * @param generator the random number generator.
	 * @param newIdFLoor the new id floor.
	 */
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFLoor);
}
