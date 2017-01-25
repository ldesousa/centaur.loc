package centaur.in;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.util.Map;
import java.util.Scanner;

import javax.persistence.EntityManager;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.hql.internal.ast.tree.Statement;


public class CreateDBSchema {

	public CreateDBSchema() {
		// TODO Auto-generated constructor stub
	}
	
	/**
	 * The main method.
	 *
	 * @param args the arguments
	 */
	public static void main(final String[] args) 
	{
		// => Postgres 9.3 is ignoring the PGPASSWORD variable
		ProcessBuilder pb = new ProcessBuilder("psql", "-d centaur", "-U desouslu", "-f db/0100_createSchema.sql");
		Map<String, String> env = pb.environment();
		env.put("PGPASSWORD", "desouslu#");
		env.put("PGPASSFILE", "/home/desouslu/.pgpass");
		pb.redirectErrorStream(true);
		try
		{
			 Process p = pb.start();
			 InputStream stdout = p.getInputStream ();
			 BufferedReader reader = new BufferedReader (new InputStreamReader(stdout));
			 
			 String line;
			 while ((line = reader.readLine ()) != null) 
			 {
				 System.out.println ("Stdout: " + line);
			}
		}
		catch (Exception ex)
		{
			System.out.println("Something went wrong: " + ex.getMessage());
		}
			
		System.out.println("Done!");
    }

}
