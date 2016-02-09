package centaur.in;

import java.util.List;

import org.hibernate.Session;
import org.hibernate.criterion.Restrictions;


public class Link
{
	centaur.db.Link link;

	public Link() 
	{
		link = new centaur.db.Link();
	}
	
	public centaur.db.Link getPersistentObject() {return link;}
	
	// Returns: true if it was able to find a corresponding record, false otherwise.
	protected Boolean loadFromName(Session session, String name)
	{		
		List list = session.createCriteria(centaur.db.Link.class)
			    .add(Restrictions.like("name", name))
			    .list();
		
		if(list.size() > 0)
		{	
			link = (centaur.db.Link) list.get(0);
			return true;
		}
		else return false;
	}
}
