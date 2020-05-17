package es.uclm.esi.drive_detection;

import android.location.Location;

/**
 * This is a POJO (Plain Old Java Object) class and the
 * EventProcessorThread class uses it to tag the events.
 * It contains the Location class and other primitive
 * variables.
 *
 * This is used to store the original location data in the form of
 * the Location object along with other tagging information such
 * as isDuplicate, eventType, and isfused:
 */
public class LocationData {
    public Location mLocation;
    public DrivingEventType eventType;
    public boolean isFused;
    public boolean isDuplicate;
    public long time;

    // NO VIENE EN EL LIBRO
    public double acceleration;
}
