package centaur.in;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

import org.postgresql.util.PGInterval;


public class Raingage implements Importable
{
	centaur.db.Raingage raingage;

	public Raingage() 
	{
		raingage = new centaur.db.Raingage();
	}
	
	public centaur.db.Raingage getPersistentObject() {return raingage;}
	
	// Returns: true if it was able to find a corresponding record, false otherwise.
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Raingage.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			raingage = (centaur.db.Raingage) list.get(0);
			return true;
		}
		else return false;
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");
		String source = "";
		
		raingage = new centaur.db.Raingage();
		if (values.length > 0) raingage.setId(new Integer(values[0]));
		if (values.length > 1) raingage.setFormat(values[1]);
		if (values.length > 2) raingage.setInterval(values[2]);
		if (values.length > 3) raingage.setScf(new BigDecimal(values[3]));
		// The source field is composed by several strings
		for (int i = 4; i < values.length; i++) source += values[i] + "\t"; 
		raingage.setSource(source);
		session.save(raingage);
	}
}
