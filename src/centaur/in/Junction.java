package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

import centaur.db.Node;

public class Junction /*extends centaur.db.Junction*/ implements Importable
{
	centaur.db.Junction junction;
	static int newIdFloor = 1000000;

	public Junction() 
	{
		// TODO Auto-generated constructor stub
		junction = new centaur.db.Junction();
	}

	public Junction(Node node) 
	{
		junction = new centaur.db.Junction(node);
		// TODO Auto-generated constructor stub
	}

	/*public Junction(Node node, BigDecimal maxDepth, BigDecimal initDepth, BigDecimal surDepth, BigDecimal aponded) {
		super(node, maxDepth, initDepth, surDepth, aponded);
		// TODO Auto-generated constructor stub
	}*/
	
	@Override
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator)
	{
		
		String[] values = lineSWMM.split("\\s+");

		Node n = new Node();
		n.setId(new Integer(values[0]));
		n.setElevation(new BigDecimal(values[1]));
		junction = new centaur.db.Junction(n);
		junction.setMaxDepth(new BigDecimal(values[2]));
		junction.setInitDepth(new BigDecimal(values[3]));
		junction.setSurDepth(new BigDecimal(values[4]));
		junction.setAponded(new BigDecimal(values[5]));
		junction.setNode(n);
		session.save(n);
		/*centaur.db.Junction parent = (centaur.db.Junction) this;
		session.save(parent);*/
		session.save(junction);
	}

}
