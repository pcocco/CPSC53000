import java.text.DecimalFormat;
import java.util.List;
import java.util.ArrayList;

private static final int BACKGROUND_COLOR = #999966;

private static final int SCREEN_WIDTH = 1000;
private static final int SCREEN_HEIGHT = 600;
private static final int PLOT_AREA_TOP_LEFT_X = 100;
private static final int PLOT_AREA_TOP_LEFT_Y = 90;
private static final int PLOT_AREA_WIDTH = 700;
private static final int PLOT_AREA_HEIGHT = 400;
private static final int AXES_COLOR = #000000;
private static final int PLOT_COLOR = #ffffcc;
private static final int ADJUSTED_VALUE_COLOR = #00ccff;
private static final int UNADJUSTED_VALUE_COLOR = #ff5050;
private static final int TEXT_COLOR = #000000;
private static final int MAX_ROW = 5;

private float dataMin;

private float dataMax;

DataSet currentDataSet = null;

List<DataSet> dataSets = new ArrayList<DataSet>();

int currentRow = 0;

void setup() {
  size(1000, 600, JAVA2D);
  int[] fileYears = {2017, 2016, 2015};
  
  for (int fileYear : fileYears) {
    DataSet dataSet = new DataSetBuilder()
      .year(fileYear)
      .file(fileYear + "Adjusted.csv", "adjusted")
      .file(fileYear + "Unadjusted.csv", "unadjusted")
      .columnMask("NAICS  Code")
      .columnMask("TOTAL")
      .rowMask(7, 0)
      .get();
    
    dataSets.add(dataSet);
  }
  
  currentDataSet = dataSets.get(0);
}

void draw() {
  smooth();
  noStroke();
  background(BACKGROUND_COLOR);
  calculateMaxMin();

  textAlign(CENTER);
  fill(TEXT_COLOR);
  text(currentDataSet.getDataSetTitle(), SCREEN_WIDTH / 2, 30);
  drawPlotArea();
  drawXAxisLabels();
  drawYAxisLabels();
  drawLegend();
  plotData();
}

private void calculateMaxMin() {
  this.dataMin = ((int) currentDataSet.getRowMin("unadjusted", currentRow).floatValue() / 1000) * 1000 - 1000;
  this.dataMax = ((int) currentDataSet.getRowMax("unadjusted", currentRow).floatValue() / 1000) * 1000 + 1000;
}

private void drawLegend() {
  rectMode(CORNER);
  fill(PLOT_COLOR);
  rect(830, 200, 150, 75);
  fill(ADJUSTED_VALUE_COLOR);
  rect(845, 230, 6, 6);
  fill(UNADJUSTED_VALUE_COLOR);
  rect(845, 252, 6, 6);
  
  fill(TEXT_COLOR);
  textAlign(RIGHT);
  text("Legend", 880, 215);
  text("Adjusted Values", 952, 239);
  text("Unadjusted Values", 965, 260);
}

private void plotData() {
  plotDataForRow(currentRow, "adjusted", ADJUSTED_VALUE_COLOR);
  plotDataForRow(currentRow, "unadjusted", UNADJUSTED_VALUE_COLOR);
}

private void plotDataForRow(int row, String zAxisName, int fillColor) {
  fill(fillColor);
  Integer x = null;
  Integer y = null;
  String[] xAxisNames = currentDataSet.getXAxisNames(zAxisName);
  
  for (int i = 1; i < xAxisNames.length; i++) {
    String xAxisName = xAxisNames[i];
    int value = (int) currentDataSet.getValue(xAxisName, row, zAxisName).floatValue();
    int offset = (i - 1) * (PLOT_AREA_WIDTH / (xAxisNames.length - 2));
    int newX = PLOT_AREA_TOP_LEFT_X + offset;
    int newY = getYForValue(value);
    
    if (x != null && y != null) {
      line(x, y, newX, newY);
    }
    
    rect(newX - 3, newY - 3, 6, 6);
    x = newX;
    y = newY;
  }
}

private void drawPlotArea() {
  rectMode(CORNER);
  noStroke();
  fill(PLOT_COLOR);
  rect(PLOT_AREA_TOP_LEFT_X, PLOT_AREA_TOP_LEFT_Y, PLOT_AREA_WIDTH, PLOT_AREA_HEIGHT);
}

private void drawYAxisLabels() {
  fill(AXES_COLOR);
  stroke(128);
  text("Million $", PLOT_AREA_TOP_LEFT_X - 35, 60);
  
  int volumeIntervalMinor = (int) (dataMax - dataMin) / 10;
  
  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor) {
    float y = getYForValue(v);
    if (v == dataMin) {
      textAlign(RIGHT); // Align by the bottom
    } else if (v == dataMax) {
      textAlign(RIGHT, CENTER); // Align by the top
    } else {
      textAlign(RIGHT, CENTER); // Center vertically
    }
    
    String valueStr = DecimalFormat.getInstance().format(floor(v));
    text(valueStr, PLOT_AREA_TOP_LEFT_X - 15, y);
    line(PLOT_AREA_TOP_LEFT_X - 10, y, PLOT_AREA_TOP_LEFT_X + PLOT_AREA_WIDTH, y); // Draw major tick
  }
}

void drawXAxisLabels() {
  fill(AXES_COLOR);
  stroke(128);
  String[] columnNames = currentDataSet.getXAxisNames("adjusted");
  int labelY = PLOT_AREA_TOP_LEFT_Y + PLOT_AREA_HEIGHT + 40;
  
  for (int i = 1; i < columnNames.length; i++) {
    int offset = (i - 1) * (PLOT_AREA_WIDTH / (columnNames.length - 2)) + 8;
    int labelX = PLOT_AREA_TOP_LEFT_X + offset;
    verticalText(columnNames[i], labelX, labelY);
  }
}

void verticalText(String text, int x, int y) {
  textAlign(CENTER, BOTTOM);
  pushMatrix();
  translate(x, y);
  rotate(-HALF_PI);
  text(text, 0, 0);
  popMatrix();
}

int getYForValue(float value) {
  return (int) max(map(value, this.dataMin, this.dataMax, PLOT_AREA_TOP_LEFT_Y + PLOT_AREA_HEIGHT, PLOT_AREA_TOP_LEFT_Y), 0);
}

void mouseWheel(MouseEvent event) {
  int currentIndex = dataSets.indexOf(currentDataSet);
  
  if (event.getCount() < 0 && currentIndex < dataSets.size() - 1) {
    currentDataSet = dataSets.get(currentIndex + 1);
  }
  
  if (event.getCount() > 0 && currentIndex > 0) {
    currentDataSet = dataSets.get(currentIndex - 1);
  }
}

void keyPressed() { 
  if (key == '[') {
    if (currentRow > 0) {
      currentRow--;
    }
  } 
  
  if (key == ']') {
    if (currentRow < MAX_ROW) {
      currentRow++;
    }
  }
  
  calculateMaxMin();
}