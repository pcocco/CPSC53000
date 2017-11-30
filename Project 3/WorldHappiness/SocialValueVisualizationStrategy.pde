class SocialValueVisualizationStrategy extends AbstractVisualizationStrategy implements VisualizationStrategy {
  private static final String SOCIAL_COLUMN = "family";
  
  private static final String TITLE = "Family/Social Support";
  
  public String getLabelForRow(TableRow row) {
    return String.format("%1s\n  Social/Family Rank - %2$,d\n  Social/Family Score - %3$f", 
        row.getString(COUNTRY_COLUMN), 
        row.getInt(RANK_COLUMN),
        row.getFloat(SOCIAL_COLUMN));
  }
  
  public String getStatisticColumnName() {
    return SOCIAL_COLUMN;
  }
  
  public String getTitle() {
    return TITLE;
  }
}