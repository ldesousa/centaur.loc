package centaur.opt;

public class Main
{
	public Main() {}
	
	public static void main(final String[] args) 
	{
		ChartXYPlot chart = new ChartXYPlot(
				"CENTAUR", 
				"Candidates capacities", 
				"Volume", 
				"Served area", 
				"Candidate");
		chart.tryIt();
    }

}
