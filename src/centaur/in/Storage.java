package centaur.in;

import java.math.BigDecimal;
import java.util.List;
import java.util.Random;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;

import centaur.db.Node;
import centaur.db.Curve;

public class Storage /*extends centaur.db.Storage*/ implements Importable
{
	centaur.db.Storage storage;

	public Storage() 
	{
		storage = new centaur.db.Storage();
	}

	public Storage(Node node) 
	{
		storage = new centaur.db.Storage(node);
	}
	
	protected void setCurveFromName(Session session, String curveName)
	{		
		List list = session.createCriteria(centaur.db.Curve.class)
			    .add(Restrictions.like("name", curveName))
			    .list();
		
		if(list.size() > 0) storage.setCurve((Curve) list.get(0));
	}
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator, int newIdFloor)
	{
		
		String[] values = lineSWMM.split("\\s+");

		Node n = new Node();
		n.setId(new Integer(values[0]));
		n.setElevation(new BigDecimal(values[1]));
		storage = new centaur.db.Storage(n);
		if (values.length > 2) storage.setMaxDepth(new BigDecimal(values[2]));
		if (values.length > 3) storage.setInitDepth(new BigDecimal(values[3]));
		if (values.length > 4) storage.setShape(values[4]);
		if (values.length > 5) this.setCurveFromName(session, values[5]);
		if (values.length > 6) storage.setNameParams(new Integer(values[6]));
		if (values.length > 7) storage.setFevap(new BigDecimal(values[7]));
		if (values.length > 8) storage.setPsi(new BigDecimal(values[8]));
		if (values.length > 9) storage.setKsat(new BigDecimal(values[9]));
		if (values.length > 10) storage.setImd(new BigDecimal(values[10]));
		session.save(n);
		session.save(storage);
	}

}
