package centaur.in;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

public class Subarea /*extends centaur.db.Subarea*/ implements Importable
{
	centaur.db.Subarea subarea;

	public Subarea() 
	{
		subarea = new centaur.db.Subarea();
	}
	
	public centaur.db.Subarea getPersistentObject() {return subarea;}
	
	// Returns: true if it was able to find a corresponding record, false otherwise.
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Subarea.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			subarea = (centaur.db.Subarea) list.get(0);
			return true;
		}
		else return false;
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");
		
		subarea = new centaur.db.Subarea();
		if (values.length > 0) 
		{
				Subcatchment s = new Subcatchment();
				if(s.loadFromName(session, values[0])) 
					subarea.setSubcatchment(s.getPersistentObject());
		}
		if (values.length > 1) subarea.setNImperv(new BigDecimal(values[1]));
		if (values.length > 2) subarea.setNPerv(new BigDecimal(values[2]));
		if (values.length > 3) subarea.setSImperv(new BigDecimal(values[3]));
		if (values.length > 4) subarea.setSPerv(new BigDecimal(values[4]));
		if (values.length > 5) subarea.setPctZero(new BigDecimal(values[5]));
		if (values.length > 6) subarea.setRouteTo(values[6]);
		if (values.length > 7) subarea.setPctRouted(new BigDecimal(values[7]));
		session.save(subarea);
	}

}
