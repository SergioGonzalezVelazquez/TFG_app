package com.example.tfg_app;

public class Constants {
    // the desired time between activity detections (milliseconds). Larger values will result
    // in fewer activity detections while improving battery life.
    // A value of 0 will result in activity detections at the fastest possible rate.
    static final long ACTIVITY_RECOGNITION_REQUEST_INTERVAL = 60 * 1000;

    // Activity recognition API confidence level must be greater or equal than 75
    static final int CONFIDENCE_THRESHOLD = 75;
}
