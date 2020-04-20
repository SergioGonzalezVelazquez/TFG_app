package com.example.tfg_app;

public class Constants {
    // the desired time between activity detections (milliseconds). Larger values will result
    // in fewer activity detections while improving battery life.
    // A value of 0 will result in activity detections at the fastest possible rate.
    static final long ACTIVITY_RECOGNITION_REQUEST_INTERVAL = 60 * 1000;

    // Activity recognition API confidence level must be greater or equal than 75
    static final int CONFIDENCE_THRESHOLD = 75;

    //Radius (meters) around the latest location
    static final int GEOFENCE_RADIUS = 200;

    // String that uniquely identifies the geo-fence
    static final String GEOFENCE_NAME = "geo-fence-identifier";

    static final double BACKINDRIVE_SPEED_THRESHOLD = 3.57;
    static final long POTENTIALSTOP_TIME_THRESHOLD = 1000 * 60 * 5;

    static final double POTENTIALSTOP_SPEED_THRESHOLD = 6.7;
    static final long POTENTIALSTART_TIME_THRESHOLD = 1000 * 60;

    // Desired interval between any two active location updates in milliseconds.
    static final long GPS_INTERVAL = 1000;

    static final long INITIAL_DELAY = 1000 * 30;
    static final long FIXED_DELAY = 1000 * 30;

    // Accelerometer and gyroscope sensors will collects data at frequency of 50Hz,
    // that is, a 20.000 microseconds interval.
    static final int ACCELEROMETER_INTERVAL = 20000;
    static final int  GYROSCOPE_INTERVAL = 20000;
}
