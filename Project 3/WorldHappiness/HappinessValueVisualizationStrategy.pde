class HappinessValueVisualizationStrategy extends AbstractVisualizationStrategy implements VisualizationStrategy {
  private static final String HAPPINESS_SCORE_COLUMN = "happiness-score";
  
  private static final String HAPPINESS_RANK_COLUMN = "happiness-rank";
  
  private static final String TITLE = "Happiness";
    
  public String getLabelForRow(TableRow row) {
    return String.format("%1s\n  Happiness Rank - %2$,d\n  Happiness Score - %3$f", 
        row.getString(COUNTRY_COLUMN), 
        row.getInt(HAPPINESS_RANK_COLUMN),
        row.getFloat(HAPPINESS_SCORE_COLUMN));
  }
  
  public String getStatisticColumnName() {
    return HAPPINESS_SCORE_COLUMN;
  }
  
  public String getTitle() {
    return TITLE;
  }
}