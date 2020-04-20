package com.example.tfg_app;

import android.app.Service;
import android.content.Intent;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.SystemClock;

import androidx.annotation.Nullable;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.ScheduledFuture;
import java.util.concurrent.TimeUnit;

/**
 * This is an instance Android service that will stay in
 * the background, process raw sensor data, and capture risky driving events only
 * when the user is in active drive. It will also control the flow of data between the
 * different classes.
 */
public class EventDetectionService extends Service {
    LocationDBHelper mLocationDBHelper;
    HandlerThread mHandlerThread;
    Handler mHandler;
    ScheduledExecutorService mScheduledExecutorService;
    ScheduledFuture mEventProcessorFutureRef;
    EventProcessorThread mEventProcessorThread;
    long timeOffsetValue;

    /**
     * Initiate the object of the LocationDBHelper class, and create the
     * objects of the HandlerThread and Handler class.
     */
    @Override
    public void onCreate(){
        super.onCreate();
        //CREAR LOCATION DBHELPER
        /*
        mLocationDBHelper = new
                LocationDBHelper(getApplicationContext());*/

        mHandlerThread = new HandlerThread("Sensor Thread",
                android.os.Process.THREAD_PRIORITY_BACKGROUND);
        mHandlerThread.start();
        mHandler = new Handler(mHandlerThread.getLooper());
        mScheduledExecutorService =
                Executors.newScheduledThreadPool(2);
        timeOffsetValue = System.currentTimeMillis() -
                SystemClock.elapsedRealtime();
    }

    /**
     * Receives two importants messages from AutoDriveDetectionService
     * in the form of intents: when the drive was started and when the
     * drive was stopped.
     * The value true for the boolean variable isDriveStarted signifies
     * the start of the drive.
     * @return
     */
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(intent!=null && intent.getBooleanExtra
                ("isDriveStarted", false)) {
            startEventProcessing();
        } else {
            stopEventProcessing();
        }
        return Service.START_STICKY;
    }

    /**
     * In the startEventProcessing we take the following important actions:
     *  - Generate a unique in for the drive
     *  - Start collecting the sensors' raw data
     *  - Start processing sensor data once every 30 seconds
     */
    public void startEventProcessing() {
        // mLocationDBHelper.generateDriveID();
        // GyroscopeSensor.getInstance().register(mHandler, getApplicationContext());
        // GPSSensor.getInstance().register(mHandler, getApplicationContext());
        mEventProcessorThread = new EventProcessorThread();

        //INITIAL_DELAY and FIXED_DELAY is 30 seconds
        mEventProcessorFutureRef = mScheduledExecutorService
                .scheduleWithFixedDelay(mEventProcessorThread,
                        Constants.INITIAL_DELAY, Constants.FIXED_DELAY,
                        TimeUnit.MILLISECONDS);

    }

    /**
     * Executed after the drive has stopped. It is responsible for stop collecting
     * the sensors data and stop the scheduling regular processing of sensor data happending
     * once every 30 seconds.
     */
    public void stopEventProcessing(){
        //GyroscopeSensor.getInstance().unregister();
        //GPSSensor.getInstance().unregister();
        //AccelerometerSensor.getInstance().unregister();
        mEventProcessorFutureRef.cancel(false);
    }


    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    /**
     * This is an inner class inside
     * the EventDetectionService class and implements the runnable interface. It
     * contains all the event detection logic and executes once every 30 seconds to
     * process the raw data obtained from the sensors
     */
    public class EventProcessorThread implements Runnable {

        @Override
        public void run() {

        }
    }
}
