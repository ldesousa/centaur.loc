package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

import centaur.db.Link;
import centaur.db.Node;

public class Pump /*extends centaur.db.Pump*/ implements Importable
{
	centaur.db.Pump pump;

	public Pump() 
	{
		pump = new centaur.db.Pump();
	}

	public Pump(Link link) 
	{
		pump = new centaur.db.Pump(link);
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
			l.setNodeByIdNodeFrom((Node) session.load(
					Node.class, new Integer(values[1])));
		if (values.length > 2) 
			l.setNodeByIdNodeTo((Node) session.load(
					Node.class, new Integer(values[2])));
		pump = new centaur.db.Pump(l);
		if (values.length > 3)
		{
			Curve c = new Curve();
			if(c.loadFromName(session, values[3])) 
				pump.setCurve(c.getPersistentObject());
		}
		if (values.length > 4) pump.setStatus(values[4]);
		if (values.length > 5) pump.setStartup(new BigDecimal(values[5]));
		if (values.length > 6) pump.setShutoff(new BigDecimal(values[6]));
		session.save(l);
		session.save(pump);
	}

}
