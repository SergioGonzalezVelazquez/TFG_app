package com.example.tfg_app;

/**
 * This is a POJO (Plain Old Java Object) class and the
 * EventProcessorThread class uses it to
 * store details of events. It only contains primitive variables.
 *
 * This is used to store all the information extracted from raw sensor
 * data before saving it to the database. It has the location, time, and other tagging
 * information.
 */
public class EventData {
    public double latitude;
    public double longitude;
    public double speed;
    public double acceleration;
    public long eventTime;
    public DrivingEventType eventType;
    public boolean isFused;
}
