/**
 *
 * Defines an interface that encapsulates the logic required to visualize a statistic. 
 *
 **/

interface VisualizationStrategy {
  //These columns are considered read-only
  static final String COUNTRY_COLUMN = "country";
  static final String LATITUDE_COLUMN = "lat";
  static final String LONGITUDE_COLUMN = "lon";
  static final int MAXIMUM_COLOR = #DDFF03;
  static final int MINIMUM_COLOR = #FF0318;
  
  //These columns are overwritten by classes that implement
  //this interface
  static final String COLOR_COLUMN = "color";
  static final String LABEL_COLUMN = "label";
  static final String RADIUS_COLUMN = "radius";
  static final String X_POSITION_COLUMN = "x_pos";
  static final String Y_POSITION_COLUMN = "y_pos";
  static final String RANK_COLUMN = "rank";

  /**
   *
   * This method is called on the implementing object each time it becomes active
   *
   * @param table - the Table object that contains the visualization data. That
   *                object must contain columns labeled according to the constants
   *                defined here.
   *
   **/
  void initializeTable(Table table);
  
  /**
   *
   * Returns a description of the topic that an implementing VisualizationStrategy encapsulates
   *
   **/
  String getTitle();
}