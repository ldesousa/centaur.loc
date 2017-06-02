package centaur.in;

import java.io.IOException;
import java.nio.charset.Charset;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;

public class CreateHibernateConfig 
{
	static String user = "";
	static String pass = "";
	static String schema = "";
	static String db = "centaur";
	static String port = "5432";
	static String templateCfg = "centaur.cfg.xml";
	static String templateReveng = "centaur.reveng.xml";
	static String pathToConfig = "src/";
	
	public CreateHibernateConfig() 
	{
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) 
	{
		// TODO Auto-generated method stub
		
		checkArgs(args);
		user = args[0];
		pass = args[1];
		schema = args[2];
		if (args.length > 3) db = args[3];
		if (args.length > 4) port = args[4];
		createCfg();
		createReveng();
		System.out.println("New Hibernate configuration for schema " + schema + " created sucessfully.");
	}
	
	protected static void checkArgs(String[] args)
	{
		if (args.length < 4)
		{
			System.out.println("ERROR: at least three parameters are required: user, password and schema.");
			System.exit(-1);
		}
	}
	
	protected static void createCfg()
	{
		Path path = Paths.get(pathToConfig + templateCfg); 
		Charset charset = StandardCharsets.UTF_8;
		Path newFile = Paths.get(pathToConfig + schema + ".cfg.xml");
		try 
		{
			String content = new String(Files.readAllBytes(path), charset);
			content = content.replaceAll(">user<", ">" + user + "<");
			content = content.replaceAll(">pass<", ">" + pass + "<");
			content = content.replaceAll(">schema<", ">" + schema + "<");
			content = content.replaceAll(":5432/centaur<", ":" + port + "/" + db + "<");
			Files.write(newFile, content.getBytes(charset));
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
			System.out.println("ERROR: failed to create .cfg file.");
			System.exit(-1);
		}
	}
	
	protected static void createReveng()
	{
		Path path = Paths.get(pathToConfig + templateReveng); 
		Charset charset = StandardCharsets.UTF_8;
		Path newFile = Paths.get(pathToConfig + schema + ".reveng.xml");
		try 
		{
			String content = new String(Files.readAllBytes(path), charset);
			Files.write(newFile, content.getBytes(charset));
		} 
		catch (IOException e) 
		{
			e.printStackTrace();
			System.out.println("ERROR: failed to create .reveng file.");
			System.exit(-1);
		}
	}
}
