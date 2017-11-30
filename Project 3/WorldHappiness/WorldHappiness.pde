import java.util.LinkedList;
import java.util.Queue;
import java.util.Stack;

private static final int MAP_WIDTH = 1000;
private static final int MAP_HEIGHT = 600;
private static final String LOCATION_FILE_NAME = "City-Capital-Lat-Lon-Happiness.csv";
private static final String[] IMAGE_FILE_NAMES = {"earth-earth-at-night-night-lights-41949-2.jpeg", "WorldHappinessReportSplash2.jpeg", "WorldHappinessReportSplash1.jpeg"};
private static final int LABEL_COLOR = #FFF308;
private static final char SPACE_BAR_KEYCODE = ' ';
private static final String TITLE_FONT_NAME = "NotoSansUI-Bold-16.vlw";
private static final String SUBTITLE_FONT_NAME = "NotoSansUI-Bold-14.vlw";
private static final String LABEL_FONT_NAME = "NotoSansUI-Bold-12.vlw";
private static final String LEGEND_FONT_NAME = "NotoSansUI-Bold-9.vlw";
  
//The map background
private PImage mapImage;

//The Table object that contains our data
private Table visualizationDataTable;

//The Queue used to cycle between VisualizationStrategies. The VisualizationStrategy on the
//front of the Queue is considered the 'active' strategy.
private Queue<VisualizationStrategy> visualizationStrategyQueue;

private Stack<PImage> imageStack;

//The Integrator objects for the currently active VisualizationStrategy
private Integrator[] radiusInterpolators;

private PFont titleFont;

private PFont subTitleFont;

private PFont labelFont;

private PFont legendFont;

private int zoomLevel;

@Override
void setup() {
  //Processing doesn't allow the use of the constants for the size() method, so changing
  //the size of the map requires a change here as well as changing MAP_WIDTH and MAP_HEIGHT
  size(1000, 600, JAVA2D);
  initializeImageStack();
  initializeVisualizationTable();
  initializeVisualizationQueue();
  initializeInterpolators();
  initializeFonts();
}

private void initializeFonts() {
  titleFont = loadFont(TITLE_FONT_NAME);
  subTitleFont = loadFont(SUBTITLE_FONT_NAME);
  labelFont = loadFont(LABEL_FONT_NAME);
  legendFont = loadFont(LEGEND_FONT_NAME);
}

private void initializeVisualizationTable() {
  visualizationDataTable = loadTable(LOCATION_FILE_NAME, "header");
  //These columns are added to maintain state for the current VisualizationStrategy
  visualizationDataTable.addColumn(VisualizationStrategy.X_POSITION_COLUMN, Table.INT);
  visualizationDataTable.addColumn(VisualizationStrategy.Y_POSITION_COLUMN, Table.INT);
  visualizationDataTable.addColumn(VisualizationStrategy.RADIUS_COLUMN, Table.INT);
  visualizationDataTable.addColumn(VisualizationStrategy.COLOR_COLUMN, Table.INT);
  visualizationDataTable.addColumn(VisualizationStrategy.LABEL_COLUMN, Table.STRING);
  visualizationDataTable.addColumn(VisualizationStrategy.RANK_COLUMN, Table.INT);
}

private void initializeInterpolators() {
  radiusInterpolators = new Integrator[visualizationDataTable.getRowCount()];
  
  for (int i = 0; i < visualizationDataTable.getRowCount(); i++) {
    float radiusValue = visualizationDataTable.getFloat(i, VisualizationStrategy.RADIUS_COLUMN);
    radiusInterpolators[i] = new Integrator(radiusValue, 0.7, 0.01);
  }
}

private void initializeVisualizationQueue() {
  visualizationStrategyQueue = new LinkedList();
  visualizationStrategyQueue.offer(new HappinessValueVisualizationStrategy());
  visualizationStrategyQueue.offer(new HealthVisualizationStrategy());
  visualizationStrategyQueue.offer(new GdpVisualizationStrategy());
  visualizationStrategyQueue.offer(new CorruptionVisualizationStrategy());
  visualizationStrategyQueue.offer(new FreedomVisualizationStrategy());
  visualizationStrategyQueue.offer(new SocialValueVisualizationStrategy());
  //Initialize the active VisualizationStrategy
  visualizationStrategyQueue.peek().initializeTable(visualizationDataTable);
}

private void initializeImageStack() {
  imageStack = new Stack();
  
  for (String imageName : IMAGE_FILE_NAMES) {
    PImage image = loadImage(imageName);
    image.resize(MAP_WIDTH, MAP_HEIGHT);
    imageStack.push(image);
  }
}

@Override
public void draw() {
  background(255);
  image(imageStack.peek(), 0, 0);
  smooth();
  noStroke();
  
  if (imageStack.size() == 1) {
    String subTitle = visualizationStrategyQueue.peek().getTitle();   
    drawCityEllipses();
    drawTitle(subTitle);
    drawLegend(subTitle);
    drawZoomBar();
  }
}

private void drawZoomBar() {
  if (zoomLevel == 0) {
    return;
  }
  
  fill(LABEL_COLOR);
  stroke(LABEL_COLOR);
  line(MAP_WIDTH - 20, 20, MAP_WIDTH - 20, 110);
  
  for (int i = 0; i < 10; i++) {
    line(MAP_WIDTH - 25, (10 * i) + 20, MAP_WIDTH - 15, (10 * i) + 20); 
  }
  
  text(">", MAP_WIDTH - 30, 124 - (10 * zoomLevel));
}

private void drawCityEllipses() {
  TableRow hoverRow = null;
  
  for (int i = 0; i < visualizationDataTable.getRowCount(); i++) {
    TableRow row = visualizationDataTable.getRow(i);
    radiusInterpolators[i].update();
    
    if (withinZoomWindow(row)) {
      int xPos = row.getInt(VisualizationStrategy.X_POSITION_COLUMN);
      int yPos = row.getInt(VisualizationStrategy.Y_POSITION_COLUMN);
      float radius = radiusInterpolators[i].value;
      
      //Outline the ellipse
      fill(VisualizationStrategy.MINIMUM_COLOR);
      ellipse(xPos, yPos, radius + 1, radius + 1);
      
      //Fill the outlined ellipse
      fill(row.getInt(VisualizationStrategy.COLOR_COLUMN));
      ellipse(xPos, yPos, radius, radius);
      
      //This conditional may be true more than once if the mouse cursor lies on two overlapping
      //values. Because the table is sorted in reverse order, the first time through this loop 
      //'hoverRow' will be set to the larger, outer value. As processing continues on rows with 
      //smaller radii, 'hoverRow' will be set to the smallest circle that contains the mouse cursor.
      if (containsMouse(row)) {
        hoverRow = row;
      }
    }
  }
  
  drawRowDescription(hoverRow);
}

private void drawTitle(String subTitle) {
  fill(LABEL_COLOR);
  textFont(titleFont);
  text("World Happiness Report", 20, 20);
  textFont(subTitleFont);
  text(subTitle, 20, 40);
}

private void drawLegend(String title) {
  textFont(legendFont);
  text("Maximum " + title, 43, MAP_HEIGHT - 158);
  fill(VisualizationStrategy.MINIMUM_COLOR);
  text("Minimum " + title, 43, MAP_HEIGHT - 77);
  
  for (int i = 0; i < 5; i++) {
    int radius = (int) map(i, 0, 5, 2, 20);
    
    //draw the ellipse outline
    fill(VisualizationStrategy.MINIMUM_COLOR);
    int y = MAP_HEIGHT - ((i + 1) * 20) - 60;
    ellipse(30, y, radius + 1, radius + 1);
    
    //fill the ellipse outline
    float colorScalar = map(i, 0, 5, 1, 0);
    fill(lerpColor(VisualizationStrategy.MAXIMUM_COLOR, VisualizationStrategy.MINIMUM_COLOR, colorScalar));
    ellipse(30, y, radius, radius);
  }
}

private void drawRowDescription(TableRow row) {
  if (row != null) {
    fill(LABEL_COLOR);
    textFont(labelFont);
    String label = row.getString(VisualizationStrategy.LABEL_COLUMN);
    text(label, 3 * (MAP_WIDTH/4), MAP_HEIGHT - 50);
  }
}

@Override
public void keyReleased() {
  if (key == SPACE_BAR_KEYCODE) {
    if (imageStack.size() > 1) {
      imageStack.pop();
      return;
    }
    
    //remove the current VisualizationStrategy from the front of the Queue
    //and add it to the rear
    visualizationStrategyQueue.offer(visualizationStrategyQueue.poll());
    //initialize the newly activated VisualizationStrategy
    visualizationStrategyQueue.peek().initializeTable(visualizationDataTable);
    
    for (int i = 0; i < visualizationDataTable.getRowCount(); i++) {
      radiusInterpolators[i].target(visualizationDataTable.getFloat(i, VisualizationStrategy.RADIUS_COLUMN));
    }
  }
}

@Override
void mouseWheel(MouseEvent event) {
  if (event.getCount() < 0 && zoomLevel < 10) {
    zoomLevel += 1;
  }
  
  if (event.getCount() > 0 && zoomLevel > 0) {
    zoomLevel -= 1;
  }
}

/**
 *
 * Determines whether the mouse currently resides inside the circle defined by 'row'
 *
 * @param the row that defines the circle (ie. has an x_pos, y_pos and radius defined)
 * @return 'true' if (mouseX, mouseY) lies within the circle defined by 'row'
 *
 **/
private boolean containsMouse(TableRow row) {
  int rowX = row.getInt(VisualizationStrategy.X_POSITION_COLUMN);
  int rowY = row.getInt(VisualizationStrategy.Y_POSITION_COLUMN);
  int radius = row.getInt(VisualizationStrategy.RADIUS_COLUMN);
  boolean xContains = abs(rowX - mouseX) <= radius;
  boolean yContains = abs(rowY - mouseY) <= radius;
  return xContains && yContains;
}

private boolean withinZoomWindow(TableRow row) {
  if (zoomLevel <= 0) {
    return true;
  }
  
  int windowSize = (int) ((zoomLevel * .01) * visualizationDataTable.getRowCount());
  int rank = row.getInt(VisualizationStrategy.RANK_COLUMN);
  float positionInWindow = map(rank, windowSize, visualizationDataTable.getRowCount() - windowSize, 1, 10);
  return positionInWindow < windowSize;
}