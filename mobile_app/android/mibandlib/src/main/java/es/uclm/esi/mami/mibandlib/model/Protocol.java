package es.uclm.esi.mami.mibandlib.model;

import java.util.TimeZone;

/**
 * Defines values for accessing data and controlling band
 *
 */
public final class Protocol {

    //miBand 2/3:
    public static final byte[] PAIR = {0x01,0x00,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x40,0x41,0x42,0x43,0x44,0x45};
    public static final byte[] PAIR_2 = {0x02, 0x00};

    public static final byte[] PAIR_RECONECT = {0x01,0x08,0x30,0x31,0x32,0x33,0x34,0x35,0x36,0x37,0x38,0x39,0x40,0x41,0x42,0x43,0x44,0x45};
    public static final byte[] PAIR_2_RECONECT = {0x02, 0x08};

    public static final byte[] FETCH_1_ST = {0x01, 0x01};
    public static final byte[] FETCH_1_END = {0x00, 0x08};
    public static final byte[] FETCH_PAST_DATA = {0x02};
    public static final byte[] FETCH_FLUSH_DATA = {0x03};

    public static byte ENDPOINT_DISPLAY_ITEMS = 0x0a;

    public static byte DISPLAY_ITEM_BIT_CLOCK = 0x01;
    public static byte DISPLAY_ITEM_BIT_STEPS = 0x02;
    public static byte DISPLAY_ITEM_BIT_DISTANCE = 0x04;
    public static byte DISPLAY_ITEM_BIT_CALORIES= 0x08;
    public static byte DISPLAY_ITEM_BIT_HEART_RATE = 0x10;
    public static byte DISPLAY_ITEM_BIT_BATTERY = 0x20;

    public static final byte[] COMMAND_CHANGE_SCREENS = new byte[]{ENDPOINT_DISPLAY_ITEMS, DISPLAY_ITEM_BIT_CLOCK, 0x30, 0x00, 0x00, 0x00, 0x06, 0x00, 0x00, 0x00, 0x00, 0x00};
    public static byte ENDPOINT_DISPLAY = 0x06;
    public static final byte[] COMMAND_ENABLE_BAND_SCREEN_UNLOCK = new byte[]{ENDPOINT_DISPLAY, 0x16, 0x00, 0x01};
    public static final byte[] DATEFORMAT_DATE_MM_DD_YYYY = new byte[]{ENDPOINT_DISPLAY, 30, 0x00, 'M', 'M', '/', 'd', 'd', '/', 'y', 'y', 'y', 'y'};

    public static final byte[] DATEFORMAT_DATE_TIME = new byte[] {ENDPOINT_DISPLAY, 0x0a, 0x0, 0x03 };

    public static final byte[] screens = {0x20, };
    public static final byte[] VIBRATION_WITH_LED = {1};
    public static final byte[] VIBRATION_10_TIMES_WITH_LED = {2};
    public static final byte[] VIBRATION_WITHOUT_LED = {4};
    public static final byte[] STOP_VIBRATION = {0};
    public static final byte[] ENABLE_REALTIME_STEPS_NOTIFY = {3, 1};
    public static final byte[] DISABLE_REALTIME_STEPS_NOTIFY = {3, 0};
    public static final byte[] ENABLE_SENSOR_DATA_NOTIFY = {18, 1};
    public static final byte[] DISABLE_SENSOR_DATA_NOTIFY = {18, 0};
    public static final byte[] SET_COLOR_RED = {14, 6, 1, 2, 1};
    public static final byte[] SET_COLOR_BLUE = {14, 0, 6, 6, 1};
    public static final byte[] SET_COLOR_ORANGE = {14, 6, 2, 0, 1};
    public static final byte[] SET_COLOR_GREEN = {14, 4, 5, 0, 1};
    public static final byte[] START_HEART_RATE_SCAN = {21, 2, 1};

    // ENABLE HEART RATE MEASUREMENT
    public static final byte[] COMMAND_ENABLE_HR_SLEEP_MEASUREMENT = new byte[]{0x15, 0x00, 0x01};
    public static final byte[] COMMAND_DISABLE_HR_SLEEP_MEASUREMENT = new byte[]{0x15, 0x00, 0x00};

    public static final byte[] COMMAND_SET_PERIODIC_HR_MEASUREMENT_INTERVAL = {0x14, 0x01};

    public static final byte[] REBOOT = {12};
    public static final byte[] REMOTE_DISCONNECT = {1};
    public static final byte[] FACTORY_RESET = {9};
    public static final byte[] SELF_TEST = {2};
}
