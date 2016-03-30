/* ****************************************************************************
 * Copyright (c) 2016 EAWAG - Swiss Federal Institute for Aquatic Research 
 *                            and Technology
 *
 * Author: Luís de Sousa [luis.desousa@eawag.ch]
 * Date: 18-03-2016
 * Description:
 * An XY chart based on the JFreeChart library. Provides methods to display the
 * plot and add data points.
 * 
 * This software is licenced under the European Union Public Licence V. 1.1,
 * please check the LICENCE file for details or the web page:
 * https://joinup.ec.europa.eu/community/eupl/og_page/eupl
 * ***************************************************************************/
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

// TODO: Auto-generated Javadoc
/**
 * The Class ChartXYPlot.
 */
public class ChartXYPlot extends ApplicationFrame 
{
	
	/** The JFreeChart instance. */
	private JFreeChart xyChart;
	
	/** The data series. */
	private XYSeries series;
	
	/** The title. */
	private String title;
	
	/** The xx label. */
	private String xxLabel;
	
	/** The yy label. */
	private String yyLabel;
	
   /**
    * Instantiates a new xy plot.
    *
    * @param applicationTitle the application window title.
    * @param chartTitle the chart title.
    * @param xxLabel the xx label.
    * @param yyLabel the yy label.
    * @param seriesLabel the series label.
    */
   public ChartXYPlot( String applicationTitle, String chartTitle, String xxLabel, String yyLabel, String seriesLabel)
   {
	   super(applicationTitle);
	   title = chartTitle;
	   this.xxLabel = xxLabel;
	   this.yyLabel = yyLabel;
	   series = new XYSeries(seriesLabel);
   }
   
   /**
    * Adds a new xy data point to chart series.
    *
    * @param x the x value.
    * @param y the y value.
    */
   public void addDataPoint(double x, double y)
   {
	   series.add(x, y);
   }
   
   /**
    * Creates a sample data series with 100 data points to test the display.
    */
   private void createSampleSeries()
   {    
      for(int i = 0; i < 100; i++) series.add( i , i );               
   }
   
   /**
    * Displays the xy plot using a sample data series.
    */
   public void tryIt()
   {
	   createSampleSeries();
	   display();
   }
   
   /**
    * Displays the xy plot in a new window, portraying all the data points 
    * presently in the series.
    */
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