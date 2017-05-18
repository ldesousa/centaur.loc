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
		try 
		{
			String line;
			String[] envp = {"PGPASSWORD=toto1"};
			Process p = Runtime.getRuntime().exec
					("psql -U centaur -d centaur -f db/0100_createSchema.sql", envp);
			BufferedReader input =
					new BufferedReader(new InputStreamReader(p.getInputStream()));
			
			while ((line = input.readLine()) != null) 
			{
				System.out.println(line);
			}
			input.close();
		}
		catch (Exception err) 
		{
			err.printStackTrace();
		}
		
		System.out.println("Done!");
    }

}
