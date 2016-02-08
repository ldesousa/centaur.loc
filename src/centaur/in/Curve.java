package centaur.in;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

import centaur.db.CurveParameter;

public class Curve /*extends centaur.db.Curve*/ implements Importable
{
	centaur.db.Curve curve;

	public Curve() 
	{
		curve = new centaur.db.Curve();
	}
	
	public centaur.db.Curve getPersistentObject() {return curve;}
	
	// Returns: true if it was able to find a corresponding record, false otherwise.
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Curve.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			curve = (centaur.db.Curve) list.get(0);
			return true;
		}
		else return false;
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{
		String[] values = lineSWMM.split("\\s+");
		String x = null, y = null;
			
		if (values.length > 0)
		{
			if (!loadFromName(session, values[0]))
			{
				curve = new centaur.db.Curve();
				curve.setId(generator.nextInt(Integer.MAX_VALUE) + newIdFloor);
				curve.setName(values[0]);
				if (values.length > 1) curve.setType(values[1]);
				if (values.length > 2) x = values[2];
				if (values.length > 3) y = values[3];
				System.out.println("New curve: " + curve.getId() + " " + curve.getName() + " " + curve.getType());
				session.save(curve);
			}
			else
			{
				if (values.length > 1) x = values[1];
				if (values.length > 2) y = values[2];
			}
		}
		
		CurveParameter cp = new CurveParameter();
		cp.setId(generator.nextInt(Integer.MAX_VALUE) + newIdFloor);
		cp.setX(new BigDecimal(x));
		cp.setY(new BigDecimal(y));
		cp.setCurve(curve);
		System.out.println("The new parameter: " + cp.getId() + " " + cp.getX() + " " + cp.getY() + " " + cp.getCurve().getId());
		session.save(cp);
	}

}
