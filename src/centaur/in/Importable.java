package centaur.in;

import java.util.Random;

import org.hibernate.Session;

public interface Importable 
{
	public void importFromSWMMLine(String lineSWMM, Session session, Random generator);
}
