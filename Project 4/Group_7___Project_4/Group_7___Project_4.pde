import java.text.DecimalFormat;

private static final int BACKGROUND_COLOR = 255;

private static final int SCREEN_WIDTH = 1000;
private static final int SCREEN_HEIGHT = 600;
private static final int PLOT_AREA_TOP_LEFT_X = 100;
private static final int PLOT_AREA_TOP_LEFT_Y = 75;
private static final int PLOT_AREA_WIDTH = 800;
private static final int PLOT_AREA_HEIGHT = 450;

private static final int AXES_COLOR = #000000;
private static final int PLOT_COLOR = #5679C1;
private DataSet ds2015 = null;

void setup() {
  size(1000, 600, JAVA2D);
  
  ds2015 = new DataSetBuilder()
    .year(2015)
    .file("2015Adjusted.csv", "adjusted")
    .file("2015Unadjusted.csv", "unadjusted")
    .columnMask("NAICS  Code")
    .columnMask("TOTAL")
    .rowMask(7, 0)
    .get();
}

void draw() {
  background(BACKGROUND_COLOR);
  smooth();
  noStroke();
  
  drawPlotArea();
  drawXAxisLabels();
  drawYAxisLabels();
}

private void drawPlotArea() {
  rectMode(CORNER);
  noStroke();
  fill(PLOT_COLOR);
  rect(PLOT_AREA_TOP_LEFT_X, PLOT_AREA_TOP_LEFT_Y, PLOT_AREA_WIDTH, PLOT_AREA_HEIGHT);
}

private void drawYAxisLabels() {
  fill(AXES_COLOR);
  text("Million $", PLOT_AREA_TOP_LEFT_X - 45, 75);
  
  float dataMin = ds2015.getRowMin("adjusted", 1).floatValue();
  float dataMax = ds2015.getRowMax("adjusted", 1).floatValue();
  int volumeIntervalMinor = 500000;
  int volumeInterval = 1000000;
  
  for (float v = 0; v <= dataMax; v += volumeIntervalMinor) {
    if (v % volumeIntervalMinor == 0) { // If a tick mark
      float y = map(v, dataMin, dataMax, SCREEN_HEIGHT - 125, 75);
      if (v % volumeInterval == 0) { // If a major tick mark
        if (v == dataMin) {
          textAlign(RIGHT); // Align by the bottom
        } else if (v == dataMax) {
          textAlign(RIGHT, TOP); // Align by the top
        } else {
          textAlign(RIGHT, CENTER); // Center vertically
        }
        
        String valueStr = DecimalFormat.getInstance().format(floor(v));
        text(valueStr, PLOT_AREA_TOP_LEFT_X - 45, y);
        //line(PLOT_AREA_TOP_LEFT_X - 14, y, PLOT_AREA_TOP_LEFT_X, y); // Draw major tick
      } else {
        //line(PLOT_AREA_TOP_LEFT_X - 12, y, PLOT_AREA_TOP_LEFT_X, y); // Draw minor tick
      }
    }
  }  
}

void drawXAxisLabels() {
  fill(AXES_COLOR);
  String[] columnNames = ds2015.getXAxisNames("adjusted");
  int labelY = PLOT_AREA_TOP_LEFT_Y + PLOT_AREA_HEIGHT + 40;
  
  for (int i = 1; i < columnNames.length; i++) {
    int offset = i * (PLOT_AREA_WIDTH / (columnNames.length));
    int labelX = PLOT_AREA_TOP_LEFT_X + 10 + offset;
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