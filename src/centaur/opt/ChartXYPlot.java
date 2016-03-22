package centaur.opt;

import java.awt.Color;
import java.awt.Shape;
import java.awt.geom.Ellipse2D;
import java.awt.BasicStroke; 
import org.jfree.chart.ChartPanel; 
import org.jfree.chart.JFreeChart; 
import org.jfree.data.xy.XYSeries; 
import org.jfree.ui.ApplicationFrame; 
import org.jfree.ui.RefineryUtilities; 
import org.jfree.chart.ChartFactory; 
import org.jfree.chart.plot.PlotOrientation;
import org.jfree.chart.plot.XYPlot;
import org.jfree.chart.renderer.xy.XYLineAndShapeRenderer;
import org.jfree.data.xy.XYSeriesCollection; 

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
   
   private void createSampleDataset()
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
	   final XYSeriesCollection dataset = new XYSeriesCollection();          
	   dataset.addSeries(series);          
	      
	   xyChart = ChartFactory.createScatterPlot(
	     title,
	     xxLabel, 
	     yyLabel,
	     dataset,
	     PlotOrientation.VERTICAL,
	     true, true, false);
	   
	   // Colours and shapes
	  Shape shape  = new Ellipse2D.Double(0,0,5,5);
	  XYPlot xyPlot = (XYPlot) xyChart.getPlot();
	  XYLineAndShapeRenderer renderer = (XYLineAndShapeRenderer) xyPlot.getRenderer();
	  renderer.setSeriesShape(0, shape);
	  renderer.setBasePaint(Color.red);
	  renderer.setUseOutlinePaint(true);
	  renderer.setSeriesOutlinePaint(0, Color.black);
	  renderer.setSeriesOutlineStroke(0, new BasicStroke(1));
	     
	  ChartPanel chartPanel = new ChartPanel(xyChart);
	  chartPanel.setPreferredSize( new java.awt.Dimension(600, 400));
	  setContentPane(chartPanel); 
	  this.pack();
	  RefineryUtilities.centerFrameOnScreen(this);
	  this.setVisible(true);
   }
}