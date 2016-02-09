package centaur.in;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;


public class Node
{
	centaur.db.Node node;

	public Node() 
	{
		node = new centaur.db.Node();
	}
	
	public centaur.db.Node getPersistentObject() {return node;}
	
	// Returns: true if it was able to find a corresponding record, false otherwise.
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Node.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			node = (centaur.db.Node) list.get(0);
			return true;
		}
		else return false;
	}
}
