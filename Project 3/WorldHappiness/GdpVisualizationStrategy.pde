class GdpVisualizationStrategy extends AbstractVisualizationStrategy implements VisualizationStrategy {
  private static final String GDP_COLUMN = "gdp-per-capita";
  
  private static final String TITLE = "GDP Per Capita";
  
  public String getLabelForRow(TableRow row) {
    return String.format("%1s\n  GDP Per Capita Rank - %2$,d\n  GDP Per Capita Score - %3$f", 
        row.getString(COUNTRY_COLUMN), 
        row.getInt(RANK_COLUMN),
        row.getFloat(GDP_COLUMN));
  }
  
  public String getStatisticColumnName() {
    return GDP_COLUMN;
  }
  
  public String getTitle() {
    return TITLE;
  }
}