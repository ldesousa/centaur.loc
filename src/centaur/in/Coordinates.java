package centaur.in;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

public class Coordinates /*extends centaur.db.Coordinates*/ implements Importable
{
	centaur.db.Coordinates coordinates;

	public Coordinates() 
	{
		coordinates = new centaur.db.Coordinates();
	}
	
	public centaur.db.Coordinates getPersistentObject() {return coordinates;}
	
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
