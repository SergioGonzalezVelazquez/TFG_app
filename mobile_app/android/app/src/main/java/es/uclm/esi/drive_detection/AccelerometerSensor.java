package es.uclm.esi.drive_detection;

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;
import android.hardware.SensorManager;
import java.util.ArrayList;
import android.os.Handler;

/**
 * This is a singleton class for collecting the raw
 * accelerometer sensor data and providing this data to the
 * EventProcessorThread class for further event detection processing
 * It collects data from the acceleromenter and stores it in mAcceloremeterList.
 * It collects data at frequency of 50Hz, that is, 20.000 microseconds interval.
 */
public class AccelerometerSensor implements SensorEventListener {
    private ArrayList<SensorEvent> mAccelerometerList = new ArrayList<SensorEvent>();
    private SensorManager mSensorManager;
    private Sensor mSensor;
    private static AccelerometerSensor accelerometerSensor;

    public static AccelerometerSensor getInstance(){
        if(accelerometerSensor == null) {
            accelerometerSensor = new AccelerometerSensor();
        }
        return accelerometerSensor;
    }

    public void unregister(){
        mSensorManager.unregisterListener(this);
    }

    public void register(Handler mHandler, Context context){
        mSensorManager = (SensorManager) context.getSystemService(Context.SENSOR_SERVICE);
        mSensor = mSensorManager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);

        // Accelerometer interval is 20.000 (50 times in second, 50Hz)
        mSensorManager.registerListener(this, mSensor, Constants.ACCELEROMETER_INTERVAL, mHandler);
    }

    @Override
    public void onSensorChanged(SensorEvent sensorEvent) {
        mAccelerometerList.add(sensorEvent);
    }

    @Override
    public void onAccuracyChanged(Sensor sensor, int i) {}

    public ArrayList<SensorEvent> getAccelerometerList(){
        return mAccelerometerList;
    }
}
