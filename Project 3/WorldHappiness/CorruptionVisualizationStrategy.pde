class CorruptionVisualizationStrategy extends AbstractVisualizationStrategy implements VisualizationStrategy {
  private static final String CORRUPTION_COLUMN = "corruption";
  
  private static final String TITLE = "Corruption/Gov't Trust";
  
  public String getLabelForRow(TableRow row) {
    return String.format("%1s\n  Corruption/Gov't Trust Rank - %2$,d\n  Corruption/Gov't Trust Score - %3$f", 
        row.getString(COUNTRY_COLUMN), 
        row.getInt(RANK_COLUMN),
        row.getFloat(CORRUPTION_COLUMN));
  }
  
  public String getStatisticColumnName() {
    return CORRUPTION_COLUMN;
  }
  
  public String getTitle() {
    return TITLE;
  }
}