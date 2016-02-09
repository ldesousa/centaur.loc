package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

import centaur.db.Link;

public class Conduit /*extends centaur.db.Conduit*/ implements Importable
{
	centaur.db.Conduit conduit;

	public Conduit() 
	{
		conduit = new centaur.db.Conduit();
	}

	public Conduit(Link link) 
	{
		conduit = new centaur.db.Conduit(link);
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{
		String[] values = lineSWMM.split("\\s+");

		Link l = new Link();
		try // Node ids can be strings
		{
			l.setId(Integer.parseInt(values[0]));
		}
		catch (NumberFormatException e) 
		{
			l.setId(generator.nextInt() + newIdFloor);
			l.setName(values[0]);
		}
		if (values.length > 1) 
			l.setNodeByIdNodeFrom((centaur.db.Node) session.load(
					centaur.db.Node.class, new Integer(values[1])));
		if (values.length > 2) 
		{
			try // Node ids can be strings
			{
				l.setNodeByIdNodeTo((centaur.db.Node) session.load(
						centaur.db.Node.class, new Integer(values[2])));
			}
			catch (NumberFormatException e) 
			{
				Node n = new Node();
				if(n.loadFromName(session, values[2])) 
					l.setNodeByIdNodeTo(n.getPersistentObject());
			}
		}
		conduit = new centaur.db.Conduit(l);
		if (values.length > 3) conduit.setLength(new BigDecimal(values[3]));
		if (values.length > 4) conduit.setRoughness(new BigDecimal(values[4]));
		if (values.length > 5) conduit.setInOffset(new BigDecimal(values[5]));
		if (values.length > 6) conduit.setOutOffset(new BigDecimal(values[6]));
		if (values.length > 7) conduit.setInitFlow(new BigDecimal(values[7]));
		if (values.length > 8) conduit.setMaxFlow(new BigDecimal(values[8]));		
		session.save(l);
		session.save(conduit);
	}

}
