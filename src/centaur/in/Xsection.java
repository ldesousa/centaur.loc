package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

public class Xsection /*extends centaur.db.Xsection*/ implements Importable
{
	centaur.db.Xsection xsection;

	public Xsection() 
	{
		xsection = new centaur.db.Xsection();
	}

	public Xsection(Link link) 
	{
		xsection = new centaur.db.Xsection(link.getPersistentObject());
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{		
		String[] values = lineSWMM.split("\\s+");

		xsection = new centaur.db.Xsection();
		try // Link ids can be strings
		{	
			xsection.setLink(
					session.load(centaur.db.Link.class, new Integer(values[0])));
		}
		catch (NumberFormatException e) 
		{
			Link l = new Link();
			if(l.loadFromName(session, values[0])) 
				xsection.setLink(l.getPersistentObject());
		}
		if (values.length > 1) xsection.setShape(values[1]);
		if (values.length > 2) xsection.setGeom1(new BigDecimal(values[2]));
		if (values.length > 3) xsection.setGeom2(new BigDecimal(values[3]));
		if (values.length > 4) xsection.setGeom3(new BigDecimal(values[4]));
		if (values.length > 5) xsection.setGeom4(new BigDecimal(values[5]));
		if (values.length > 6) xsection.setBarrels(new BigDecimal(values[6]));
		if (values.length > 7) xsection.setCulvert(new BigDecimal(values[7]));
		session.save(xsection);
	}

}
