package centaur.in;

import java.math.BigDecimal;
import java.util.Random;

import org.hibernate.Session;

import centaur.db.Node;
import centaur.db.Outfall;

public class Junction extends centaur.db.Junction 
{
	static int newIdFloor = 1000000;

	public Junction() 
	{
		// TODO Auto-generated constructor stub
		super();
	}

	public Junction(Node node) 
	{
		super(node);
		// TODO Auto-generated constructor stub
	}

	public Junction(Node node, BigDecimal maxDepth, BigDecimal initDepth, BigDecimal surDepth, BigDecimal aponded) {
		super(node, maxDepth, initDepth, surDepth, aponded);
		// TODO Auto-generated constructor stub
	}
	
	public Junction(String lineSWMM, Session session, Random generator)
	{
		Node n = new Node();
		String[] values = lineSWMM.split("\\s+");
		/*try // Node ids can be strings
		{
			n.setId(new Integer(values[0]));
		}
		catch (NumberFormatException e) 
		{
			n.setId(generator.nextInt() + newIdFloor);
			n.setName(values[0]);
		}*/
		this.setIdNode(new Integer(n.getId()));
		n.setElevation(new BigDecimal(values[1]));
		n.setId(new Integer(values[0]));
		this.setMaxDepth(new BigDecimal(values[2]));
		this.setInitDepth(new BigDecimal(values[3]));
		this.setSurDepth(new BigDecimal(values[4]));
		this.setAponded(new BigDecimal(values[5]));
		this.setNode(n);
	}

}
