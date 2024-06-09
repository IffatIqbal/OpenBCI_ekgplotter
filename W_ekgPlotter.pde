class W_ekgPlotter extends Widget {
  
  ControlP5 localCP5;
  Button startButton;
  SerialPort serialPort;
  String serialPortName = "/dev/ttyUSB0"; // Adjust this according to your setup
  int serialBaudRate = 9600;

  List<Float> hrData = new ArrayList<>();
  List<Float> hrvData = new ArrayList<>();
  List<Float> sensorData = new ArrayList<>();
  List<Float> timeData = new ArrayList<>();
  long startTime;

  W_ekgPlotter(PApplet _parent){
    super(_parent); //calls the parent CONSTRUCTOR method of Widget (DON'T REMOVE)

    // Instantiate local cp5 for this box
    localCP5 = new ControlP5(ourApplet);
    localCP5.setGraphics(ourApplet, 0,0);
    localCP5.setAutoDraw(false);

    // Create the start button to initialize serial communication
    createStartButton();
  }

  public void update(){
    super.update(); //calls the parent update() method of Widget (DON'T REMOVE)
    readSerialData();
  }

  public void draw(){
    super.draw(); //calls the parent draw() method of Widget (DON'T REMOVE)

    // Draw all cp5 objects in the local instance
    localCP5.draw();
    
    // Plot the data
    plotData();
  }

  public void screenResized(){
    super.screenResized(); //calls the parent screenResized() method of Widget (DON'T REMOVE)

    // Set the position of our Cp5 object after the screen is resized
    localCP5.setGraphics(ourApplet, 0, 0);
    startButton.setPosition(x + w/2 - startButton.getWidth()/2, y + h/2 - startButton.getHeight()/2);
  }

  public void mousePressed(){
    super.mousePressed(); //calls the parent mousePressed() method of Widget (DON'T REMOVE)
  }

  public void mouseReleased(){
    super.mouseReleased(); //calls the parent mouseReleased() method of Widget (DON'T REMOVE)
  }

  private void createStartButton() {
    startButton = createButton(localCP5, "startButton", "Start EKG Plotter", x + w/2, y + h/2, 200, navHeight, p4, 14, colorNotPressed, OPENBCI_DARKBLUE);
    startButton.setBorderColor(OBJECT_BORDER_GREY);
    startButton.onRelease(new CallbackListener() {
      public void controlEvent(CallbackEvent theEvent) {
        if (!topNav.configSelector.isVisible && !topNav.layoutSelector.isVisible) {
          initializeSerial();
        }
      }
    });
    startButton.setDescription("Start the EKG plotter by initializing serial communication.");
  }

  private void initializeSerial() {
    try {
      serialPort = new SerialPort(serialPortName, serialBaudRate);
      serialPort.openPort();
      serialPort.setParams(serialBaudRate, 8, 1, 0);
      startTime = System.currentTimeMillis();
    } catch (SerialPortException e) {
      e.printStackTrace();
    }
  }

  private void readSerialData() {
    if (serialPort != null && serialPort.isOpened()) {
      try {
        String data = serialPort.readString();
        if (data != null) {
          String[] values = data.split(",");
          if (values.length == 3) {
            float hr = Float.parseFloat(values[0]);
            float hrv = Float.parseFloat(values[1]);
            float sensorValue = Float.parseFloat(values[2]);
            float currentTime = (System.currentTimeMillis() - startTime) / 1000.0f;
            timeData.add(currentTime);
            hrData.add(hr);
            hrvData.add(hrv);
            sensorData.add(sensorValue);

            // Keep only the latest 100 points for better performance
            if (timeData.size() > 100) {
              timeData.remove(0);
              hrData.remove(0);
              hrvData.remove(0);
              sensorData.remove(0);
            }
          }
        }
      } catch (SerialPortException e) {
        e.printStackTrace();
      }
    }
  }

  private void plotData() {
    ourApplet.stroke(255);
    ourApplet.noFill();
    ourApplet.beginShape();
    for (int i = 0; i < timeData.size(); i++) {
      float xPos = PApplet.map(timeData.get(i), timeData.get(0), timeData.get(timeData.size()-1), x, x + w);
      float yPos = PApplet.map(sensorData.get(i), 0, 100, y + h, y);
      ourApplet.vertex(xPos, yPos);
    }
    ourApplet.endShape();
  }
};

//These functions need to be global , functions are activated when an item from the corresponding dropdown is selected
void Dropdown1(int n){
  println("Item " + (n+1) + " selected from Dropdown 1");
}

void Dropdown2(int n){
  println("Item " + (n+1) + " selected from Dropdown 2");
}

void Dropdown3(int n){
  println("Item " + (n+1) + " selected from Dropdown 3");
}
