package es.uclm.esi.mami.mibandlib.model;

import java.util.UUID;

/**
 * Defines keys for services, descriptors and characteristics
 *
 */
public class Profile {

    // SERVICES

    /**
     * Data service
     */
    // (This one for miband 2/3:)
    public static final UUID UUID_SERVICE_MILI = UUID.fromString("0000fee1-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_SERVICE_FETCH = UUID.fromString("0000fee0-0000-1000-8000-00805f9b34fb");


    /**
     * Vibration service
     */
    public static final UUID UUID_SERVICE_VIBRATION = UUID.fromString("00001802-0000-1000-8000-00805f9b34fb");

    /**
     * Heart rate service
     */
    public static final UUID UUID_SERVICE_HEARTRATE = UUID.fromString("0000180d-0000-1000-8000-00805f9b34fb");

    /**
     * Screen char configuration (FETCH SERVICE)
     */
    public static final UUID UUID_CHAR_SCREEN = UUID.fromString("00000003-0000-3512-2118-0009af100700");
    public static final UUID UUID_CHAR_CURRENT_TIME = UUID.fromString("00002A2B-0000-1000-8000-00805f9b34fb");

    /**
     * Unknown services
     */
    public static final UUID UUID_SERVICE_UNKNOWN1 = UUID.fromString("00001800-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_SERVICE_UNKNOWN2 = UUID.fromString("00001801-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_SERVICE_UNKNOWN4 = UUID.fromString("0000fee1-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_SERVICE_UNKNOWN5 = UUID.fromString("0000fee7-0000-1000-8000-00805f9b34fb");


    // DESCRIPTORS
    public static final UUID UUID_DESCRIPTOR_UPDATE_NOTIFICATION = UUID.fromString("00002902-0000-1000-8000-00805f9b34fb");

    public static final UUID UUID_NOTIFICATION_HEARTRATE = UUID.fromString("00002a37-0000-1000-8000-00805f9b34fb");

    public static final UUID UUID_CHARACTERISTIC_6_BATTERY_INFO = UUID.fromString("00000006-0000-3512-2118-0009af100700");


    // CHARACTERISTICS
    public static final UUID UUID_CHAR_ACTIVITY_DATA= UUID.fromString("00000005-0000-3512-2118-0009af100700");

    public static final UUID UUID_CHAR_FETCH= UUID.fromString("00000004-0000-3512-2118-0009af100700");




    public static final UUID UUID_CHAR_DEVICE_INFO = UUID.fromString("0000ff01-0000-1000-8000-00805f9b34fb");

    public static final UUID UUID_CHAR_DEVICE_NAME = UUID.fromString("0000ff02-0000-1000-8000-00805f9b34fb");

    /**
     * Notification
     */
    public static final UUID UUID_CHAR_NOTIFICATION = UUID.fromString("0000ff03-0000-1000-8000-00805f9b34fb");

    /**
     * User info
     */
    public static final UUID UUID_CHAR_USER_INFO = UUID.fromString("0000ff04-0000-1000-8000-00805f9b34fb");

    /**
     * Used for manipulations with service control
     */
    public static final UUID UUID_CHAR_CONTROL_POINT = UUID.fromString("0000ff05-0000-1000-8000-00805f9b34fb");

    /**
     * Used for enabling/disabling realtime steps
     */
    public static final UUID UUID_CHAR_REALTIME_STEPS = UUID.fromString("0000ff06-0000-1000-8000-00805f9b34fb");

    /**
     * Used for getting batter info
     */
    public static final UUID UUID_CHAR_BATTERY = UUID.fromString("0000ff0c-0000-1000-8000-00805f9b34fb");

    /**
     * Used for fetching sensor data
     */
    public static final UUID UUID_CHAR_SENSOR_DATA = UUID.fromString("0000ff0e-0000-1000-8000-00805f9b34fb");

    /**
     * Used for pairing device
     */
    // public static final UUID UUID_CHAR_PAIR = UUID.fromString("0000ff0f-0000-1000-8000-00805f9b34fb");
    // (This one for miband 2:)
    public static final UUID UUID_CHAR_PAIR = UUID.fromString("00000009-0000-3512-2118-0009af100700");

    /**
     * Used for enabling/disabling vibration
     */
    public static final UUID UUID_CHAR_VIBRATION = UUID.fromString("00002a06-0000-1000-8000-00805f9b34fb");

    /**
     * Used for reading heart rate data
     */
    public static final UUID UUID_CHAR_HEARTRATE = UUID.fromString("00002a39-0000-1000-8000-00805f9b34fb");

    public static final UUID UUID_CHAR_ACTIVITY = UUID.fromString("0000ff07-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_CHAR_FIRMWARE_DATA = UUID.fromString("0000ff08-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_CHAR_LE_PARAMS = UUID.fromString("0000ff09-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_CHAR_DATA_TIME = UUID.fromString("0000ff0a-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_CHAR_STATISTICS = UUID.fromString("0000ff0b-0000-1000-8000-00805f9b34fb");
    public static final UUID UUID_CHAR_TEST = UUID.fromString("0000ff0d-0000-1000-8000-00805f9b34fb");
}
