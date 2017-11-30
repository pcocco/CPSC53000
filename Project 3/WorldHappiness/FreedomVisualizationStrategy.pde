class FreedomVisualizationStrategy extends AbstractVisualizationStrategy implements VisualizationStrategy {
  private static final String FREEDOM_COLUMN = "freedom";
  private static final String TITLE = "Freedom";
  
  public String getLabelForRow(TableRow row) {
    return String.format("%1s\n  Freedom Rank - %2$,d\n  Freedom Score - %3$f", 
        row.getString(COUNTRY_COLUMN), 
        row.getInt(RANK_COLUMN),
        row.getFloat(FREEDOM_COLUMN));
  }
  
  public String getStatisticColumnName() {
    return FREEDOM_COLUMN;
  }
  
  public String getTitle() {
    return TITLE;
  }
}