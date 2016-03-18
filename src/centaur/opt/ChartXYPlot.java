package centaur.opt;

import java.awt.Color; 
import java.awt.BasicStroke; 
import org.jfree.chart.ChartPanel; 
import org.jfree.chart.JFreeChart; 
import org.jfree.data.xy.XYDataset; 
import org.jfree.data.xy.XYSeries; 
import org.jfree.ui.ApplicationFrame; 
import org.jfree.ui.RefineryUtilities; 
import org.jfree.chart.plot.XYPlot; 
import org.jfree.chart.ChartFactory; 
import org.jfree.chart.plot.PlotOrientation; 
import org.jfree.data.xy.XYSeriesCollection; 
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;

public class ChartXYPlot extends ApplicationFrame 
{
	private JFreeChart xyChart;
	private XYSeries series;
	private String title;
	private String xxLabel;
	private String yyLabel;
	
   public ChartXYPlot( String applicationTitle, String chartTitle, String xxLabel, String yyLabel, String seriesLabel)
   {
	   super(applicationTitle);
	   title = chartTitle;
	   this.xxLabel = xxLabel;
	   this.yyLabel = yyLabel;
	   series = new XYSeries(seriesLabel);
   }
   
   public void addDataPoint(double x, double y)
   {
	   series.add(x, y);
   }
   
   private void createSampleDataset( )
   {    
      for(int i = 0; i < 100; i++) series.add( i , i );               
   }
   
   public void tryIt()
   {
	   createSampleDataset();
	   display();
   }
   
   public void display()
   {
	   final XYSeriesCollection dataset = new XYSeriesCollection( );          
	   dataset.addSeries( series );          
	      
	   xyChart = ChartFactory.createScatterPlot(
	     title ,
	     xxLabel ,
	     yyLabel ,
	     dataset ,
	     PlotOrientation.VERTICAL ,
	     true , true , false);
	     
	  ChartPanel chartPanel = new ChartPanel( xyChart );
	  chartPanel.setPreferredSize( new java.awt.Dimension( 560 , 367 ) );
	  setContentPane( chartPanel ); 
	  this.pack();
	  RefineryUtilities.centerFrameOnScreen(this);
	  this.setVisible(true);
   }
}