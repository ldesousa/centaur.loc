package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

import centaur.db.Node;

public class Outfall /*extends centaur.db.Outfall*/ implements Importable
{
	centaur.db.Outfall outfall;

	public Outfall() 
	{
		outfall = new centaur.db.Outfall();
	}

	public Outfall(Node node) 
	{
		outfall = new centaur.db.Outfall(node);
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{
		
		String[] values = lineSWMM.split("\\s+");

		Node n = new Node();
		try // Node ids can be strings
		{
			n.setId(Integer.parseInt(values[0]));
		}
		catch (NumberFormatException e) 
		{
			n.setId(generator.nextInt() + newIdFloor);
			n.setName(values[0]);
		}
		n.setElevation(new BigDecimal(values[1]));
		outfall.setNode(n);
		outfall.setType(values[2]);
		outfall.setGated(new Boolean(values[3]));
		session.save(n);
		session.save(outfall);
	}

}
