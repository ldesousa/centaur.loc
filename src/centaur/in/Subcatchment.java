package centaur.in;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

public class Subcatchment /*extends centaur.db.Subcatchment*/ implements Importable
{
	centaur.db.Subcatchment subcatchment;

	public Subcatchment() 
	{
		subcatchment = new centaur.db.Subcatchment();
	}
	
	public centaur.db.Subcatchment getPersistentObject() {return subcatchment;}
	
	// Returns: true if it was able to find a corresponding record, false otherwise.
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Subcatchment.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			subcatchment = (centaur.db.Subcatchment) list.get(0);
			return true;
		}
		else return false;
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");
		
		subcatchment = new centaur.db.Subcatchment();
		subcatchment.setId(generator.nextInt() + newIdFloor);
		if (values.length > 0) subcatchment.setName(values[0]);
		if (values.length > 1) 
		{
				subcatchment.setRaingage(
						session.load(centaur.db.Raingage.class, new Integer(values[1])));
		}
		if (values.length > 2) 
		{
			try // Node ids can be strings
			{
				subcatchment.setNode((centaur.db.Node) session.load(
						centaur.db.Node.class, new Integer(values[2])));
			}
			catch (NumberFormatException e) 
			{
				Node n = new Node();
				if(n.loadFromName(session, values[2])) 
					subcatchment.setNode(n.getPersistentObject());
			}
		}
		if (values.length > 3) subcatchment.setArea(new BigDecimal(values[3]));
		if (values.length > 4) subcatchment.setImperv(new BigDecimal(values[4]));
		if (values.length > 5) subcatchment.setWidth(new BigDecimal(values[5]));
		if (values.length > 6) subcatchment.setSlope(new BigDecimal(values[6]));
		if (values.length > 7) subcatchment.setCurbLen(new BigDecimal(values[7]));
		if (values.length > 8) subcatchment.setSnowPack(values[8]);
		session.save(subcatchment);
	}

}
