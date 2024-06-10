import controlP5.ControlP5;
import processing.core.PApplet;
import brainflow.BoardShim;
import brainflow.BoardIds;
import brainflow.BrainFlowInputParams;
import java.util.ArrayList;
import java.util.List;

public class W_ekgPlotter extends Widget {
    List<Float> sensorData = new ArrayList<>();
    List<Float> timeData = new ArrayList<>();
    long startTime;
    int cBack;
    ControlP5 cp5;
    BoardShim boardShim;

    W_ekgPlotter(PApplet _parent) {
        super(_parent);
        cp5 = new ControlP5(ourApplet);
        cp5.setAutoDraw(false);
        startTime = System.currentTimeMillis();
        onColorChange();
        initializeBrainFlow();
        ourApplet.registerMethod("dispose", this);
    }

    private void onColorChange() {
        cBack = ourApplet.color(255);
    }

    public void update() {
        super.update();
        updateEKGData();
    }

    public void draw() {
        super.draw();
        ourApplet.background(cBack);
        plotData();
        cp5.draw();
    }

    public void screenResized() {
        super.screenResized();
    }

    private void plotData() {
        if (timeData.isEmpty() || sensorData.isEmpty()) {
            println("No data to plot");
            return;
        }

        ourApplet.stroke(0);
        ourApplet.noFill();
        ourApplet.beginShape();
        for (int i = 0; i < timeData.size(); i++) {
            float xPos = PApplet.map(timeData.get(i), timeData.get(0), timeData.get(timeData.size() - 1), x + 30, x + w - 30);
            float yPos = PApplet.map(sensorData.get(i), 0, 1023, y + h - 30, y + 30);
            ourApplet.vertex(xPos, yPos);
        }
        ourApplet.endShape();
    }

private void initializeBrainFlow() {
    try {
        BrainFlowInputParams params = new BrainFlowInputParams();
        params.serial_port = "COM4"; // Change port name as necessary
        boardShim = new BoardShim(BoardIds.CYTON_BOARD, params);
        boardShim.prepare_session();
        boardShim.start_stream();
        println("BrainFlow session started");
    } catch (BrainFlowError e) {
        println("Error initializing BrainFlow: " + e.getMessage());
        e.printStackTrace();
    } catch (Exception e) {
        println("An unexpected error occurred during initialization:");
        e.printStackTrace();
    }
}


private void updateEKGData() {
    try {
        double[][] data = boardShim.get_current_board_data(1);
        if (data != null && data.length > 0) {
            float time = (System.currentTimeMillis() - startTime) / 1000.0f;
            float sensorValue = (float) data[7][0]; // Assuming channel 8 has EKG data
            timeData.add(time);
            sensorData.add(sensorValue);

            if (timeData.size() > 100) {
                timeData.remove(0);
                sensorData.remove(0);
            }

            println("Received data: Time=" + time + ", Sensor Value=" + sensorValue);
        } else {
            println("No data received from board");
        }
    } catch (Exception e) {
        println("Error while retrieving data:");
        e.printStackTrace();
    }
}




    public void dispose() {
        try {
            if (boardShim != null) {
                boardShim.stop_stream();
                boardShim.release_session();
                println("BrainFlow session stopped");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
