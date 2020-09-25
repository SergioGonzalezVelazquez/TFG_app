package es.uclm.esi.drive_detection;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import android.os.Handler;
import java.util.ArrayList;

/**
 * This is a singleton class for collecting the raw gyroscope
 * sensor data and providing this data to the EventProcessorThread class for
 * further event detection processing.
 * It will collects the data at a frequency of 50Hz
 */
public class GyroscopeSensor implements SensorEventListener {
    private ArrayList<SensorEvent> mGyroscopeList = new
            ArrayList<SensorEvent>();
    private static GyroscopeSensor gyroscopeSensor;
    private SensorManager mSensorManager;
    private Sensor mSensor;


    public static GyroscopeSensor getInstance() {
        if (gyroscopeSensor == null) {
            gyroscopeSensor = new GyroscopeSensor();
        }
        return gyroscopeSensor;
    }

    public void unregister() {
        mSensorManager.unregisterListener(this);
    }
    public void register(Handler mHandler, Context context) {
        mSensorManager = (SensorManager)
                context.getSystemService(Context.SENSOR_SERVICE);
        mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_GYROSCOPE);
        //GYROSCOPE_INTERVAL is 20000, i.e. 50 times in second (50 Hz)
        mSensorManager.registerListener(this, mSensor, Constants.GYROSCOPE_INTERVAL, mHandler);
    }


    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        mGyroscopeList.add(sensorEvent);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {}

    public ArrayList<SensorEvent> getGyroscopeList()
    {
        return mGyroscopeList;
    }
}
