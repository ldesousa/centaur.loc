package centaur.var;

import java.io.IOException;
import java.util.Scanner;
import org.apache.commons.math3.stat.descriptive.SummaryStatistics;

public class ReadOutput {
	
	protected static Scanner s;

	public ReadOutput() {
		// TODO Auto-generated constructor stub
	}

	public static void main(String[] args) {
		// TODO Auto-generated method stub
		
		String cmd = "swmmtoolbox extract data/Wartegg_Luzern_output.bin node,1,0"; 
		double[] series = new double[120/5 + 2];
		SummaryStatistics stats = new SummaryStatistics();
		
		openRuntime(cmd);
		
		// Ditch the first line, it is just the header
		if (s.hasNext()) s.next();
		
		double previous = 0;
		while (s.hasNext())
		{
			System.out.println(s.next().split(",")[1]);
			double val = new Double(s.next().split(",")[1]);
			stats.addValue(Math.abs(val - previous));
			previous = val;
		}
		
		closeRuntime();
		
		System.out.println("Average: " + stats.getMean());
		System.out.println("StdDev : " + stats.getStandardDeviation());
		System.out.println("Max    : " + stats.getMax());
	}
	
	public static void openRuntime(String cmd)
	{
		try
		{
	        Process proc = Runtime.getRuntime().exec(cmd);
	        java.io.InputStream is = proc.getInputStream();
	        s = new java.util.Scanner(is).useDelimiter("\n");
		}
        catch (IOException e) 
        {
			e.printStackTrace();
		}
	}
	
	public static void closeRuntime()
	{
		try
		{
	        if(s != null) s.close();
		}
        catch (Exception e) 
        {
			e.printStackTrace();
		}
	}

}
