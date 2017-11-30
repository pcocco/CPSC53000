class HealthVisualizationStrategy extends AbstractVisualizationStrategy implements VisualizationStrategy {
  private static final String HEALTH_COLUMN = "health-life-expectancy";
  
  private static final String TITLE = "Health/Life Expectancy";
  
  public String getLabelForRow(TableRow row) {
    return String.format("%1s\n  Health/Life Expectancy Rank - %2$,d\n  Health/Life Expectancy Score - %3$f", 
        row.getString(COUNTRY_COLUMN), 
        row.getInt(RANK_COLUMN),
        row.getFloat(HEALTH_COLUMN));
  }
  
  public String getStatisticColumnName() {
    return HEALTH_COLUMN;
  }
  
  public String getTitle() {
    return TITLE;
  }
}