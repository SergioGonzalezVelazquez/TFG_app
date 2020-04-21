package com.example.tfg_app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.hardware.SensorEvent;
import android.location.Location;
import android.os.Build;
import android.os.Handler;
import android.os.HandlerThread;
import android.os.IBinder;
import android.os.SystemClock;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.ArrayList;
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
    private final String CHANNEL_ID = "EventDetectionService";
    private final String TAG = "EventDetectionService";

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
        Log.d(TAG,"onCreate()");
        createNotificationChannel();
        super.onCreate();

        // A Foreground service must provide a notification for the status bar.
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("STOPMiedo")
                .setContentText("Driving events detection service is active")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .build();
        startForeground(101, notification);

        mLocationDBHelper = new LocationDBHelper(getApplicationContext());

        mHandlerThread = new HandlerThread("Sensor Thread",
                android.os.Process.THREAD_PRIORITY_BACKGROUND);
        mHandlerThread.start();
        mHandler = new Handler(mHandlerThread.getLooper());
        mScheduledExecutorService =
                Executors.newScheduledThreadPool(2);
        timeOffsetValue = System.currentTimeMillis() -
                SystemClock.elapsedRealtime();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "STOPMiedo",
                    NotificationManager.IMPORTANCE_DEFAULT
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
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
        Log.d(TAG,"onStartCommand()");
        if(intent!=null && intent.getBooleanExtra
                ("isDriveStarted", false)) {
            sendMessage("EventDetectionService: startEventProcessing");
            startEventProcessing();
        } else {
            sendMessage("EventDetectionService: stopEventProcessing");
            stopEventProcessing();
        }
        return Service.START_STICKY;
    }

    // The system invokes this method when the service is no longer used and is being destroyed.
    @Override
    public void onDestroy() {
        Log.d(TAG,"onDestroy() service");
        super.onDestroy();
        stopEventProcessing();
    }


    // Allows communication between this service and MainActivity
    // Send an Intent with an action named "driving-event-detection". The Intent sent should
    // be received by the MainActivity.
    private void sendMessage(String msg) {
        Intent intent = new Intent("driving-event-detection");
        intent.putExtra("msg", msg);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }



    /**
     * In the startEventProcessing we take the following important actions:
     *  - Generate a unique in for the drive
     *  - Start collecting the sensors' raw data
     *  - Start processing sensor data once every 30 seconds
     */
    public void startEventProcessing() {
        mLocationDBHelper.generateDriveID();
        GyroscopeSensor.getInstance().register(mHandler, getApplicationContext());
        GPSSensor.getInstance().register(mHandler, getApplicationContext());
        AccelerometerSensor.getInstance().register(mHandler, getApplicationContext());

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
        GyroscopeSensor.getInstance().unregister();
        //  GPSSensor.getInstance().unregister();
        AccelerometerSensor.getInstance().unregister();
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
     * process the raw data obtained from the sensors.
     *
     * The EventProcessorThread host all the individual event detection logic, which is spread
     * across multiple methods and which is called from the run() method.
     */
    public class EventProcessorThread implements Runnable {
        ArrayList<Location> mGPSRawList = new ArrayList<Location>();
        ArrayList<SensorEvent> mAccelerometerRawList = new ArrayList<SensorEvent>();
        ArrayList<SensorEvent> mGyroscopeRawList = new ArrayList<SensorEvent>();
        ArrayList<SensorData> mAccelerometerPotentialList = new ArrayList<SensorData>();
        ArrayList<SensorData> mCrashPotentialList = new ArrayList<SensorData>();
        ArrayList<SensorData> mGyroscopePotentialList = new ArrayList<SensorData>();
        ArrayList<LocationData> mGPSPotentialList = new ArrayList<LocationData>();
        ArrayList<EventData> mEventList = new ArrayList<EventData>();

        SensorData mAccelerometerData;
        SensorData mGyroscopeData;
        LocationData mLocationData;
        double magnitude;
        boolean isHighSpeedEventPresent;
        EventData mEventData;


        @Override
        public void run() {
            transferData();
            detectPhoneDistraction();
            detectHardTurns();
            eventDetectionUsingGPS();
            eventDetectionUsingAccelerometer();
            fusingGPSAccelerometerEvents();
            processNonFusedGPSEvents();
            saveSensorEventInDB();
            clearData();
        }

        /**
         * Method used to transfer all the sensor data from the individual singleton
         * sensor classes to the local ArrayList, so that they are not processed the
         * next time.
         */
        private void transferData(){
            //Transferring all the data from the main collection array and cleaning
            // after that, so that adding new values to the arrays doesn't get blocked
            mGPSRawList.addAll(GPSSensor.getInstance().getGPSList());
            GPSSensor.getInstance().getGPSList().clear();
            mAccelerometerRawList.addAll(AccelerometerSensor
                    .getInstance().getAccelerometerList());
            AccelerometerSensor.getInstance().getAccelerometerList()
                    .clear();
            mGyroscopeRawList.addAll(GyroscopeSensor.getInstance()
                    .getGyroscopeList());
            GyroscopeSensor.getInstance().getGyroscopeList().clear();
        }

        /**
         * Detecting the phone distraction event is a three step process:
         *  1) find those gyroscope sensor values where the magnitude is greater than 2.5
         *  2) remove those gyroscope sensor values that are close enough to be considered
         *      duplicate events
         *  3) filter out the gyroscope values that were generated at driving speeds of 20 mph
         *     (32,18 km/h) or less
         */
        private void detectPhoneDistraction(){
            // Calculating the magnitude (Length of vector) and checking if its greater than 2.5 threshold
            // Magnitude is sqrt(x*x + y*y + Z*z)
            int sizeGyroscopeRawList = mGyroscopeRawList.size();
            for (int i = 0; i < sizeGyroscopeRawList; i++) {
                magnitude = Math.sqrt(Math.pow(mGyroscopeRawList
                        .get(i).values[0], 2) + Math.pow(mGyroscopeRawList
                        .get(i).values[1], 2) + Math.pow(mGyroscopeRawList
                        .get(i).values[2], 2));
                if (magnitude > Constants.PHONE_DISTRACTION_PEAK) {
                    // If the magnitude value exceeds the threshold, converts the sensor event time
                    // from the phone`s boot time to epoch time.
                    mGyroscopeData = new SensorData();
                    mGyroscopeData.mSensorEvent = mGyroscopeRawList.get(i);
                    mGyroscopeData.magnitude = magnitude;
                    mGyroscopeData.time = (mGyroscopeRawList.get(i).timestamp / 1000000L) +
                            timeOffsetValue;
                    mGyroscopePotentialList.add(mGyroscopeData);
                }
            }
            // Removing the Gyroscope Potential Overlapping and duplicate Data,
            // which are close enough (less than 3 seconds)
            int sizeGyroscopePotentialtList = mGyroscopePotentialList.size();
            for (int i = 0; i < sizeGyroscopePotentialtList; i++) {
                for (int j = i+1; j < sizeGyroscopePotentialtList; j++) {
                    if(mGyroscopePotentialList.get(j).time -
                            mGyroscopePotentialList.get(i).time <
                            Constants.POTENTIAL_OVERLAPPING_INTERVAL) {
                        mGyroscopePotentialList.get(j).isDuplicate = true;
                    }
                }
            }

            //Capturing Phone Distraction Events location and checking for speed threshold.
            // Executed over myGyrocopePotentialList for only those gyroscope values for which
            // the isDuplicate Boolean variable is false.
            boolean correspondingGPSFound;
            for (int i = 0; i < sizeGyroscopePotentialtList; i++){
                if(!mGyroscopePotentialList.get(i).isDuplicate) {
                    correspondingGPSFound = false;
                    mEventData = new EventData();
                    for (int k = 0; k < mGPSRawList.size(); k++) {
                        // PHONE_DISTRACTION_SPEEDLIMT is 20 miles per hour (32,18 km/h)
                        // Location.getSpeed() retunr the speed in meters/second
                        if(Math.abs(mGyroscopePotentialList.get(i).time -
                                mGPSRawList.get(k).getTime()) <
                                Constants.ONE_AND_HALF_SECOND && mGPSRawList.get(k)
                                .getSpeed() > Constants.PHONE_DISTRACTION_SPEEDLIMT) {
                            correspondingGPSFound = true;
                            mEventData.speed = mGPSRawList.get(k).getSpeed();
                            mEventData.latitude = mGPSRawList.get(k).getLatitude();
                            mEventData.longitude = mGPSRawList.get(k).getLongitude();
                            break;
                        }
                    }
                    if(correspondingGPSFound) {
                        mEventData.eventType = DrivingEventType.PHONE_DISTRACTION.ordinal();
                        mEventData.eventTime = mGyroscopePotentialList.get(i).time;
                        mEventList.add(mEventData);
                    }
                }
            }
        }

        /**
         * This method is responsible for detecting hard turns using the GPS bearing
         * data obtained from mGPSRawList.
         *
         * We will only consider turns that have a turn angle equal to or greater
         * than 90 degrees, and the time of completion of the turn as 4 seconds or less.
         */
        private void detectHardTurns(){
            // A turn has two important properties: the angle of the turn and the time to
            // complete the turn.
            float fourthAngle, thirdAngle, secondAngle, firstAngle, averageTurnAngle = 0;
            int sizeGPSList = mGPSRawList.size();
            for (int i = 0; i < sizeGPSList - 4; i++) {

                //Calculating fourth angle
                if (mGPSRawList.get(i + 4).getBearing() < 90 &&
                        mGPSRawList.get(i + 3).getBearing() > 270) {
                    fourthAngle = (mGPSRawList.get(i + 4).getBearing() + 360) -
                            mGPSRawList.get(i + 3).getBearing();
                }

                else if (mGPSRawList.get(i + 4).getBearing() > 270 &&
                        mGPSRawList.get(i + 3).getBearing() < 90) {
                    fourthAngle = (mGPSRawList.get(i + 3).getBearing() + 360) -
                            mGPSRawList.get(i + 4).getBearing();
                }

                else {
                    fourthAngle = Math.abs(mGPSRawList.get(i + 4).getBearing() -
                            mGPSRawList.get(i + 3).getBearing());
                }

                //Calculating third angle
                if (mGPSRawList.get(i + 3).getBearing() < 90 &&
                        mGPSRawList.get(i + 2).getBearing() > 270) {
                    thirdAngle = (mGPSRawList.get(i + 3).getBearing() + 360) -
                            mGPSRawList.get(i + 2).getBearing();
                }

                else if (mGPSRawList.get(i + 3).getBearing() > 270 &&
                        mGPSRawList.get(i + 2).getBearing() < 90) {
                    thirdAngle = (mGPSRawList.get(i + 2).getBearing() + 360) -
                            mGPSRawList.get(i + 3).getBearing();
                }

                else {
                    thirdAngle = Math.abs(mGPSRawList.get(i + 3).getBearing() -
                            mGPSRawList.get(i + 2).getBearing());
                }


                //Calculating second angle
                if (mGPSRawList.get(i + 2).getBearing() < 90 &&
                        mGPSRawList.get(i + 1).getBearing() > 270) {
                    secondAngle = (mGPSRawList.get(i + 2).getBearing() + 360) - mGPSRawList.get(i + 1).getBearing();
                }

                else if (mGPSRawList.get(i + 2).getBearing() > 270 &&
                        mGPSRawList.get(i + 1).getBearing() < 90) {
                    secondAngle = (mGPSRawList.get(i + 1).getBearing() + 360) -
                            mGPSRawList.get(i + 2).getBearing();
                }

                else {
                    secondAngle = Math.abs(mGPSRawList.get(i + 2).getBearing() -
                            mGPSRawList.get(i + 1).getBearing());
                }


                //Calculating first angle
                if (mGPSRawList.get(i + 1).getBearing() < 90 && mGPSRawList.get(i).getBearing() > 270) {
                    firstAngle = (mGPSRawList.get(i + 1).getBearing() + 360) -
                            mGPSRawList.get(i).getBearing();
                }

                else if (mGPSRawList.get(i + 1).getBearing() > 270 &&
                        mGPSRawList.get(i).getBearing() < 90) {
                    firstAngle = (mGPSRawList.get(i).getBearing() + 360) -
                            mGPSRawList.get(i + 1).getBearing();
                }

                else {
                    firstAngle = Math.abs(mGPSRawList.get(i + 1).getBearing() -
                            mGPSRawList.get(i).getBearing());
                }

                //Calculating average angle
                averageTurnAngle = (fourthAngle + thirdAngle + secondAngle +
                        firstAngle) / 4;

                //If the average change of angle for 4 seconds is greater than 22.5 degrees, we will
                // consider it a hard turn. HARD_TURN_PEAK is 22.5f
                if (averageTurnAngle > Constants.HARD_TURN_PEAK) {

                    //This is considered as hard turn and adding this hard turn to Detected Event List Array
                    mEventData = new EventData();
                    mEventData.eventType = DrivingEventType.HARD_TURN.ordinal();
                    mEventData.speed = mGPSRawList.get(i + 2).getSpeed();
                    mEventData.latitude = mGPSRawList.get(i + 2).getLatitude();
                    mEventData.longitude = mGPSRawList.get(i + 2).getLongitude();
                    mEventData.eventTime = mGPSRawList.get(i + 2).getTime();
                    mEventList.add(mEventData);
                }
            }
        }

        /**
         * With GPS data, we process three types of risky event: hard braking, hard acceleration
         * and high speed.
         * For that, we iterate over the entire GPS array mGPSRawList and calculate the
         * acceleration, which is the difference in speed between two consecutive GPS data
         * points
         */
        private void eventDetectionUsingGPS(){
            //Processing the GPS data for Hard Braking, Fast Acceleration and High Speed
            int sizeGPSRawList = mGPSRawList.size();
            float acceleration = 0;
            isHighSpeedEventPresent = false;
            for (int i = 0; i < sizeGPSRawList-1; i++) {
                // calculating change in speed between two consecutive points
                acceleration = mGPSRawList.get(i+1).getSpeed() - mGPSRawList.get(i).getSpeed();

                //Checking for HARD ACCELERATION PEAK(above 8 mph or 3.57632 meters per second)
                if(acceleration > Constants.HARD_ACCELERATION_PEAK){
                    mLocationData = new LocationData();
                    mLocationData.eventType = DrivingEventType.HARD_ACCELERATION.ordinal();
                    mLocationData.mLocation = mGPSRawList.get(i+1);
                    mLocationData.acceleration = acceleration;
                    mGPSPotentialList.add(mLocationData);
                }

                // Checking for HARD BREAKING, between -8 mph
                // (HARD_BREAKING_LOWER_PEAK) to -17 mph
                // (HARD_BREAKING_HIGHER_PEAK)
                else if((acceleration >
                        Constants.HARD_BREAKING_HIGHER_PEAK) &&
                        (acceleration < Constants.HARD_BREAKING_LOWER_PEAK)) {
                    //Potential Candidate for Hard Brake Severe Crash
                    mLocationData = new LocationData();
                    mLocationData.eventType = DrivingEventType.HARD_BRAKING.ordinal();
                    mLocationData.mLocation = mGPSRawList.get(i+1);
                    mLocationData.acceleration = acceleration;
                    mGPSPotentialList.add(mLocationData);
                }
                //Checking for HIGH SPEEDING PEAK (80 miles per hour or 35.76 meters per second)
                if(mGPSRawList.get(i).getSpeed() > Constants.HIGH_SPEED_PEAK &&
                        !isHighSpeedEventPresent) {
                    mEventData = new EventData();
                    mEventData.eventType = DrivingEventType.SPEEDING.ordinal();
                    mEventData.acceleration = acceleration;
                    mEventData.speed = mGPSRawList.get(i).getSpeed();
                    mEventData.latitude = mGPSRawList.get(i).getLatitude();
                    mEventData.longitude = mGPSRawList.get(i).getLongitude();
                    mEventData.eventTime = mGPSRawList.get(i).getTime();
                    mEventList.add(mEventData);
                    isHighSpeedEventPresent = true;
                }
            }
            // Removing the GPS Potential Overlapping & Duplicate Data, which are close
            // enough (within 3 seconds interval)
            int sizeGPSPotentialList = mGPSPotentialList.size();
            for (int i = 0; i < sizeGPSPotentialList; i++) {
                for (int j = i + 1; j < sizeGPSPotentialList; j++) {
                    if (mGPSPotentialList.get(j).time -
                            mGPSPotentialList.get(i).time <
                            Constants.POTENTIAL_OVERLAPPING_INTERVAL) {
                        mGPSPotentialList.get(j).isDuplicate = true;
                    }
                }
            }
        }



        private void eventDetectionUsingAccelerometer(){

        }

        /**
         *
         */
        private void fusingGPSAccelerometerEvents(){

        }

        /**
         * Process those GPS events that were not overlapping with accelerometer events.
         * We will use the tagging (isFused=true) to filter out fused events from nonfused
         * events. We will iterate over mGPSPotentialList for those events that are
         * not fused and are not duplicated using the for loop. For those events that satisfy
         * these conditions, we will create a new EventData object and add it
         * to mEventList.
         */
        private void processNonFusedGPSEvents(){
            //Adding GPS events to mEventList, which are not fused with accelerometer data
            int sizeGPSPotentialList = mGPSPotentialList.size();
            for (int i = 0; i < sizeGPSPotentialList; i++)
            {
                if(!mGPSPotentialList.get(i).isFused &&
                        !mGPSPotentialList.get(i).isDuplicate)
                {
                    mEventData = new EventData();
                    mEventData.eventType =
                            mGPSPotentialList.get(i).eventType;
                    //Either Hard Braking or Acceleration
                    mEventData.acceleration = mGPSPotentialList.get(i).acceleration;
                    mEventData.speed = mGPSPotentialList.get(i).mLocation.getSpeed();
                    mEventData.eventTime = mGPSPotentialList.get(i).mLocation.getTime();
                    mEventData.latitude = mGPSPotentialList.get(i).mLocation.getLatitude();
                    mEventData.longitude = mGPSPotentialList.get(i).mLocation.getLongitude();
                    mEventList.add(mEventData);
                }
            }
        }

        /**
         * Event data in mEventList is persisted in the database using the updateEventDetails()
         * method of the LocationDBHelper class. Similarly, all the GPS locations collected
         * in mGPSRawList are also persisted in the database using
         * the updateDrivingRoute() method
         */
        private void saveSensorEventInDB()
        {
            //Updating the database with Event List and Location Trail
            // mLocationDBHelper.updateEventDetails(mEventList);
            // mLocationDBHelper.updateDrivingRoute(mGPSRawList);
        }

        /**
         * It is used to clear all the data stored inside the
         * temporary arrays used to process the events
         */
        private void clearData()
        {
            //Clear all the data from Arrays
            mGPSRawList.clear();
            mAccelerometerRawList.clear();
            mGyroscopeRawList.clear();
            mAccelerometerPotentialList.clear();
            mCrashPotentialList.clear();
            mGyroscopePotentialList.clear();
            mGPSPotentialList.clear();
            mEventList.clear();
        }
    }
}