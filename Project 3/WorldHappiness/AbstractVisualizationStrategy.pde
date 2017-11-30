/**
 *
 * An abstract class that encapsulates most of the common logic required to implement
 * VisualizationStrategy.
 *
 **/

abstract class AbstractVisualizationStrategy implements VisualizationStrategy {
  private static final int MIN_RADIUS = 2;
  
  private static final int MAX_RADIUS = 20;
  
  private float minValue;
  private float maxValue;
  
  public void initializeTable(Table table) {
    //sort the table by the relevant column. This allows us to assing each row's rank
    //in a sequential manner.
    table.sort(getStatisticColumnName());
        
    FloatList statisticColumn = table.getFloatList(getStatisticColumnName());
    minValue = statisticColumn.min();
    maxValue = statisticColumn.max(); //<>//
    int rank = 0;
    
    for (TableRow row : table.rows()) {
      int x = findX(row.getFloat("lon"));
      int y = findY(row.getFloat("lat"));
      
      float statisticValue = row.getFloat(getStatisticColumnName());
      int radius = (int) map(statisticValue, minValue, maxValue, MIN_RADIUS, MAX_RADIUS);
      int ellipseColor = getColorForRow(row);
      String label = getLabelForRow(row);
      
      row.setInt(X_POSITION_COLUMN, x);
      row.setInt(Y_POSITION_COLUMN, y);
      row.setInt(RADIUS_COLUMN, radius);
      row.setInt(COLOR_COLUMN, ellipseColor);
      row.setString(LABEL_COLUMN, label);
      row.setInt(RANK_COLUMN, rank++);
    }
    
    //sort the table by radius, largest to smallest. This prevents larger values from
    //completely obscuring smaller ones.
    table.sortReverse(RADIUS_COLUMN);
  }
  
  /**
   *
   * Uses a mercator projection to map a given latitude onto the current map's coordinate space.
   *
   * @param lat - the latitiude to be mapped
   * @return the given latitude's value mapped onto the map's coordinate space
   *
   **/
  private int findY(double lat) {
    double latRad = lat  * (PI / 180.0);
    double mercN = Math.log(Math.tan((PI / 4.0) + (latRad / 2.0)));
    return (int) Math.round(((MAP_HEIGHT / 2.0) - (MAP_WIDTH * mercN / (2 * PI))));
  }
  
  private int findX(double lon) {
    return (int) Math.round((lon + 180.0) * (MAP_WIDTH / 360.0));
  }
  
  private int getColorForRow(TableRow row) {
    float health = row.getFloat(getStatisticColumnName());
    float mappedHappiness = map(health, minValue, maxValue, 0, 1);
    return lerpColor(MINIMUM_COLOR, MAXIMUM_COLOR, mappedHappiness);
  }
  
  abstract String getLabelForRow(TableRow row);
  
  abstract String getStatisticColumnName();
}