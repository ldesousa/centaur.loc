package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

public class Polygon /*extends centaur.db.Polygon*/ implements Importable
{
	centaur.db.Polygon polygon;

	public Polygon() 
	{
		polygon = new centaur.db.Polygon();
	}
	
	public centaur.db.Polygon getPersistentObject() {return polygon;}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");
		
		polygon = new centaur.db.Polygon();
		//centaur.db.PolygonId polygonId = new centaur.db.PolygonId();
		//polygon.setId(generator.nextInt(Integer.MAX_VALUE) + newIdFloor);
		/*if (values.length > 0) 
		{
				Subcatchment s = new Subcatchment();
				if(s.loadFromName(session, values[0])) 
					polygon.setSubcatchment(s.getPersistentObject());
		}*/
		if (values.length > 1) polygon.setX(new BigDecimal(values[1]));
		if (values.length > 2) polygon.setY(new BigDecimal(values[2]));
		//polygon.setId(polygonId);
		session.save(polygon);
	}

}
