package centaur.in;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.Map;
import java.util.Scanner;
import java.util.concurrent.ThreadLocalRandom;

import javax.persistence.EntityManager;

import org.hibernate.Query;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.hibernate.cfg.Configuration;
import org.hibernate.hql.internal.ast.tree.Statement;


public class CreateDBSchema 
{
	static String user = "";
	static String pass = "";
	static String schema = "";
	static String[] envp = {};

	public CreateDBSchema() 
	{
		// TODO Auto-generated constructor stub
	}
	
	/**
	 * The main method.
	 *
	 * @param args the arguments
	 */
	public static void main(final String[] args) 
	{	
		user = "centaur";
		pass = "toto1";
		schema = "test02";
		envp = new String[]{"PGPASSWORD=" + pass};
		
		execScript(createTempScript("db/0100_createSchema.sql"));
		
		System.out.println("Done!");
    }
	
	protected static void execScript(String script)
	{
		try 
		{
			Process p = Runtime.getRuntime().exec
					("psql -U " + user + " -d centaur -f " + script, envp);
			BufferedReader input =
					new BufferedReader(new InputStreamReader(p.getInputStream()));
			
			String line;
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
	}
	
	protected static String createTempScript(String script)
	{
		Path path = Paths.get(script); 
		Charset charset = StandardCharsets.UTF_8;
		Path tempPath = Paths.get("/tmp/" + 
				String.valueOf(ThreadLocalRandom.current().nextInt(0, 10000)));
		try 
		{
			String content = new String(Files.readAllBytes(path), charset);
			content = content.replaceAll("<user>", user);
			content = content.replaceAll("<schema>", schema);
			Files.write(tempPath, content.getBytes(charset));
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
		}
		return tempPath.toString();
	}

}
