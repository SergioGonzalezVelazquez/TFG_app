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

    static final double PHONE_DISTRACTION_PEAK = 2.5;

    static final long POTENTIAL_OVERLAPPING_INTERVAL = 1000 * 3;
    static final long ONE_AND_HALF_SECOND = 1500;
    static final long ONE_SECOND = 1000;
    static final long TWO_SECONDS = 1000 * 2;

    // We consider phone distractions at speed greater than 20mph (8.9408 m/s or 32,18 km/h)
    static final double PHONE_DISTRACTION_SPEEDLIMT = 8.9408;

    // We consider a hard turn if the average angle change for 4 seconds is greater than 22.5
    static final double HARD_TURN_PEAK = 22.5;

    // If the acceleration is greater than 8 mph per second (3.57 m/s^2), then we
    // consider it as a hard acceleration event
    static final double HARD_ACCELERATION_PEAK = 3.57632;

    // If the acceleration is negative and between -8 mph per second and -17 mph per second,
    // then we consider it a hard braking event
    static final double HARD_BREAKING_HIGHER_PEAK = 3.57632;
    static final double HARD_BREAKING_LOWER_PEAK  = 7.59968;

    // Whenever the speed crosses the 80 mph (128,748 km/h or 35,7632 m/s) threshold,
    // we consider it a high-speed event.
    static final double HIGH_SPEED_PEAK = 35.7632;

    static final int ACCELEROMETER_PEAK = 20;
    static final double FALLING_PEAK = 0.5;




}
