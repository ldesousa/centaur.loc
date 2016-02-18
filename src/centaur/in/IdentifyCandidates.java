package centaur.in;

import java.math.BigDecimal;
import java.util.Iterator;
import java.util.List;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.Transaction;
import org.hibernate.cfg.Configuration;

import centaur.db.Node;
import centaur.db.Link;


public class IdentifyCandidates {

	static SessionFactory factory;
	
	static BigDecimal currentOverflow = BigDecimal.valueOf(Double.MAX_VALUE);
	static int linkNum = 0;

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		Session session;
		Transaction tx;
		
		// => This code is common to ImportSWMM - must be refactored
		// Initialise database session
		try
		{
	         factory = new Configuration()
	        		 .configure("centaur.cfg.xml").buildSessionFactory();
	         session = factory.openSession();
	         tx = session.beginTransaction();
	    }
		catch (Throwable e) 
		{ 
	         System.err.println("Failed to initialise database session: " + e);
	         e.printStackTrace();
	         return;
	    }
			
		Query query = session.createSQLQuery(String.format(
				"SELECT id, elevation, name" +
				"  FROM centaur.node " +
				" WHERE id NOT IN (" +
				"       SELECT id_node_from" +
                "         FROM centaur.link)")).addEntity(Node.class);
	
		List<Node> outlets = query.list();
		for (Node n : outlets)
		{
			currentOverflow = BigDecimal.valueOf(Double.MAX_VALUE);
			linkNum = 0;
			System.out.println("--------\nId: " + n.getId() + " arrivals: " + n.getLinksForIdNodeTo().size());
			
			analyseNode(n);
			System.out.println("Calculated overflow: " + currentOverflow);
			System.out.println("Number of links: " + linkNum);
		}
		
	}

	protected static void analyseNode(Node n)
	{
		Set<Link> links = n.getLinksForIdNodeTo();
		
		if(links.size() <= 0)
		{
			updateCurrentOverflow(n.getElevation());
			return;
		}
		
		for (centaur.db.Link l : links)
		{
			//if it is a weir
			if (l.getWeir() != null) 
			{
				updateCurrentOverflow(l.getWeir().getCrestHeight());
				// Keep searching if the previous node is below the crest height.
				if (l.getNodeByIdNodeFrom().getElevation().compareTo(currentOverflow) < 0)
				{
					linkNum++;
					analyseNode(l.getNodeByIdNodeFrom());
				}
			}
			//if it is a pump
			else if (l.getPump() != null) 
			{
				updateCurrentOverflow(n.getElevation());
				return;
			}
			//if it is conduit
			else
			{
				analyseNode(l.getNodeByIdNodeFrom());
				linkNum++;
			}
		}
	}
	
	protected static void updateCurrentOverflow(BigDecimal newLevel)
	{
		if(newLevel.compareTo(currentOverflow) < 0) currentOverflow = newLevel;
	}

}
