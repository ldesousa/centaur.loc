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
	static String db = "";
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
		checkArgs(args);
		user = args[0];
		pass = args[1];
		schema = args[2];
		db = args[3];
		envp = new String[]{"PGPASSWORD=" + pass};
		
		System.out.println("Creating Schema");
		execScript(createTempScript("db/0100_createSchema.sql"));
		System.out.println("Enabling spatial features");
		execScript(createTempScript("db/0300_spatial_enablement.sql"));
		System.out.println("Creating subgraph functions");
		execScript(createTempScript("db/0400_f_node_subgraph.sql"));
		System.out.println("Creating generic views");
		execScript(createTempScript("db/0501_views.sql"));
		System.out.println("Creating Conduit views");
		execScript(createTempScript("db/0502_v_conduit.sql"));
		System.out.println("Creating Junction views");
		execScript(createTempScript("db/0503_v_junction.sql"));
		System.out.println("Creating Candidate views");
		execScript(createTempScript("db/0504_v_candidate.sql"));
		System.out.println("Creating optimal location search functions");
		execScript(createTempScript("db/0701_f_optimal.sql"));
		System.out.println("Creating optimal flow functions");
		execScript(createTempScript("db/0702_f_flow.sql"));
		System.out.println("Done!");
    }
	
	protected static void checkArgs(String[] args)
	{
		if (args.length < 4)
		{
			System.out.println("ERROR: four parameters are required: user, password, schema and data-base.");
			System.exit(-1);
		}
	}
	
	protected static void execScript(String script)
	{
		try 
		{
			Process p = Runtime.getRuntime().exec
					("psql -U " + user + " -d " + db + " -f " + script, envp);
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
