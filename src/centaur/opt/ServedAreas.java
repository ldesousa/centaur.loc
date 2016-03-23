package centaur.opt;

import java.math.BigDecimal;
import java.util.LinkedList;
import java.util.Set;

import org.hibernate.Query;
import org.hibernate.Session;

import centaur.db.Node;
import centaur.db.Candidate;
import centaur.db.Subcatchment;
import centaur.db.Link;


public class ServedAreas {
	
	static LinkedList<Subcatchment> subcatchments;

	public static void compute(Session session) 
	{
		System.out.println("Starting up");
		
		clearAreas(session);
		
		Query query =  session.createQuery("from Subcatchment s");
		subcatchments = new LinkedList<Subcatchment>(query.list());
		
		System.out.println("Subcatchments: " + subcatchments.size());
		
		while(subcatchments.size() > 0)
		{
			Subcatchment s = subcatchments.pop();
			System.out.println("==== Processing subcatchment: " + s.getId());
			
			if(s.getNode() != null)
			{
				BigDecimal servedArea = BigDecimal.valueOf(
						s.getArea().doubleValue() * s.getImperv().doubleValue() / 100);
				
				Candidate c = s.getNode().getCandidate();
				// If there is no candidate this is a leaf node
				if (c != null)
				{					
					if (c.getServedArea() == null) c.setServedArea(servedArea);
					else c.setServedArea(c.getServedArea().add(servedArea));
				}	
				
				transportDownstream(
						servedArea, 
						s.getNode().getLinksForIdNodeFrom());
			}
		}
		System.out.println("\nSucessfully calculated served areas.");
	}
	
	static void clearAreas(Session session)
	{
		session.createQuery(String.format("UPDATE %s SET served_area = 0", Candidate.class.getName())).executeUpdate();
		session.flush();
	}
	
	static void transportDownstream(BigDecimal area, Set<Link> outwardLinks)
	{	
		for (Link l : outwardLinks)
		{
			// Pumps have to be ignored - they send water upstream creating loops
			if (l.getPump() == null) 
			{	
				Node n = l.getNodeByIdNodeTo();
				BigDecimal areaShare = new BigDecimal(area.doubleValue() / outwardLinks.size());
				
				if (n.getCandidate().getServedArea() == null)
					n.getCandidate().setServedArea(areaShare);
				else
					n.getCandidate().setServedArea(
						n.getCandidate().getServedArea().add(areaShare));
				
				if(n.getLinksForIdNodeFrom().size() > 0)
					transportDownstream(areaShare, n.getLinksForIdNodeFrom());
			}
		}
	}
}
