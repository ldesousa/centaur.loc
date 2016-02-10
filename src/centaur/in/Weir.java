package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

import centaur.db.Link;
import centaur.db.Node;

public class Weir /*extends centaur.db.Weir*/ implements Importable
{
	centaur.db.Weir weir;
	String yes = "YES";

	public Weir() 
	{
		weir = new centaur.db.Weir();
	}

	public Weir(Link link) 
	{
		weir = new centaur.db.Weir(link);
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
		weir = new centaur.db.Weir(l);
		if (values.length > 3) weir.setType(values[3]);
		if (values.length > 4) weir.setCrestHeight(new BigDecimal(values[4]));
		if (values.length > 5) weir.setQCoeff(new BigDecimal(values[5]));
		if (values.length > 6) 
		{
			if(values[6].equals(yes)) weir.setGated(Boolean.TRUE);
			else weir.setGated(Boolean.FALSE);
		}
		if (values.length > 7) weir.setEndCon(new BigDecimal(values[7]));
		if (values.length > 8) weir.setEndCoeff(new BigDecimal(values[8]));
		if (values.length > 9) 
		{
			if(values[6].equals(yes)) weir.setSurcharge(Boolean.TRUE);
			else weir.setGated(Boolean.FALSE);
		}
		session.save(l);
		session.save(weir);
	}

}