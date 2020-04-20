package com.example.tfg_app;

import android.hardware.SensorEvent;

/**
 * This is a POJO (Plain Old Java Object) class and the
 * EventProcessorThread class uses it to tag the events while processing. It
 * contains the SensorEvent object and other primitive variables.
 *
 * This is used to store the original accelerometer or gyroscope data in the form of
 * a sensor Event object along with other tagging information such us isDuplicate, magnitude,
 * and time in milliseconds.
 */
public class SensorData {
    public SensorEvent mSensorEvent;
    public double magnitude;
    public boolean isDuplicate;
    public long time;
}
