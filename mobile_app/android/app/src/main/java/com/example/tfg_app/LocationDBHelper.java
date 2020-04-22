package com.example.tfg_app;

import android.content.ContentValues;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.Map;

/**
 * This class is used to handle the database operations. It is used to persist the risky event
 * data and drive the summary data in the database.
 *
 * Inside the class, we handle two firestore collections, called driving_routes and event_details.
 */
public class LocationDBHelper {
    private final String TAG = "LocationDBHelper";
    private final String FLUTTER_SHARED_PREFERENCES = "FlutterSharedPreferences";
    private final String DRIVING_EVENTS_SHARED_PREFERENCES = "DrivingEventsPreferences";
    private static final String COLLECTION_DRIVING_ACTIVITY = "driving_activity";
    private static final String COLLECTION_DRIVING_ROUTE = "driving_routes";
    private static final String COLLECTION_EVENT_DETAILS = "driving_event_details";
    private static final String DRIVE_ID = "driveId";

    private  SharedPreferences mPreferences;

    private FirebaseFirestore mFirestore;
    private Context mContext;

    public LocationDBHelper(Context context){
        this.mContext = context;
        initFirestore();
    }
    /**
     * Get an instance of FirebaseFirestore to work with
     */
    private void initFirestore() {
        mFirestore = FirebaseFirestore.getInstance();
    }

    /**
     * This method is called when from EventDetectionService whenever a new drive
     * is started.
     * Generates an unique ID by appending the current time in milliseconds with the drive_
     * string and saves it in the shared preferences.
     *
     * Creates a firestore document at '' collection with this unique ID, linking this drive
     * with the current auth user (read from SharedPreferences)
     * @return unique drive ID as string
     */
    public String generateDriveID() {
        Log.d(TAG,"generateDriveID() start");
        String driveId = "drive_" + String.valueOf(System.currentTimeMillis());

        // Get current auth user id from SharedPreferences
        SharedPreferences mPreferencesFlutter =
                mContext.getSharedPreferences(FLUTTER_SHARED_PREFERENCES, Context.MODE_PRIVATE);
        String userId = mPreferencesFlutter.getString("flutter."+"userId", null);
        Log.d(TAG,"generateDriveID() read user id: " + userId);
        // Create a Map to store the data we want to set
        Map<String, Object> docData = new HashMap<>();
        docData.put("userId", userId);
        docData.put("start_at", FieldValue.serverTimestamp());
        mFirestore.collection(COLLECTION_DRIVING_ACTIVITY).document(driveId).set(docData);
        sendMessage("mFirestore writes on " + COLLECTION_DRIVING_ACTIVITY + "- userId: " + userId);

        SharedPreferences mPreferences =
                mContext.getSharedPreferences(DRIVING_EVENTS_SHARED_PREFERENCES, Context.MODE_PRIVATE);
        SharedPreferences.Editor mEditor = mPreferences.edit();
        mEditor.putString(DRIVE_ID, driveId);
        mEditor.apply();
        Log.d(TAG,"db generateDriveID() result:" + driveId);
        return driveId;
    }

    /**
     * Provides the latest drive´s unique ID after reading it from the shared preferences.
     * @return unique drive ID as string
     */
    public String getCurrentDriveID(){
        SharedPreferences mSharedPreferences =
                mContext.getSharedPreferences(DRIVING_EVENTS_SHARED_PREFERENCES, Context.MODE_PRIVATE);
        return mSharedPreferences.getString(DRIVE_ID, "default");

    }

    /**
     * This method takes the ArrayList of the Location objects and insert them (latitude, longitude
     * and time) into the driving_routes collection.
     * This is called once every 30 seconds by the EventProcessorThread class to update the driving
     * route
     */
    public void updateDrivingRoute(ArrayList<Location> mLocationDataList){
        sendMessage("db updateDrivingRoute with " + mLocationDataList.size() + " locations");
        String driveId = getCurrentDriveID();
        for(int i=0; i < mLocationDataList.size(); i++){
            Location mLocationData = mLocationDataList.get(i);
            Map<String, Object> docData = new HashMap<>();
            docData.put(DRIVE_ID, driveId);
            docData.put("time", mLocationData.getTime());
            docData.put("latitude", mLocationData.getLatitude());
            docData.put("longitude", mLocationData.getLongitude());
            mFirestore.collection(COLLECTION_DRIVING_ROUTE).document().set(docData);
        }
    }

    /**
     * This method takes the ArrayList of the EventData objects and inserts
     * the event details into the driving_event_details collection.
     *
     * It gets the latest drive ID from the getCurrentDriveId() method.
     * This is called once every 30 seconds by the EventProcessorThread class
     * to update the detected event details.
     *
     * We used a switch statement to filter the types of events as we don't save the speed
     * and acceleration for events such as parking, hard turns, and phone distractions.
     */
    public void updateEventDetails(ArrayList<EventData> mEventDataList){
        sendMessage("db updateEventDetails with size " + mEventDataList.size());
        String driveId = getCurrentDriveID();
        for (int i = 0; i < mEventDataList.size(); i++){
            EventData mEventData = mEventDataList.get(i);
            Map<String, Object> docData = new HashMap<>();
            docData.put(DRIVE_ID, driveId);
            docData.put("time", mEventData.eventTime);
            docData.put("type", mEventData.eventType);
            docData.put("latitute", mEventData.latitude);
            docData.put("longitude", mEventData.longitude);
            docData.put("isFused", mEventData.isFused);

            if(mEventData.eventType == DrivingEventType.SPEEDING.ordinal()
                    || mEventData.eventType == DrivingEventType.HARD_BRAKING.ordinal()
                    || mEventData.eventType == DrivingEventType.HARD_ACCELERATION.ordinal()
            ) {
                docData.put("acceleration", mEventData.acceleration);
                docData.put("driving_speed", mEventData.speed);
            }
            else if (mEventData.eventType == DrivingEventType.PHONE_DISTRACTION.ordinal()
                    || mEventData.eventType == DrivingEventType.HARD_TURN.ordinal()
            ) {
                docData.put("driving_speed", mEventData.speed);
                docData.put("acceleration", 0);
            }
            else {
                docData.put("acceleration", 0);
                docData.put("driving_speed", 0);
            }
            mFirestore.collection(COLLECTION_EVENT_DETAILS).document().set(docData);
        }

    }

    // Allows communication between this service and MainActivity
    // Send an Intent with an action named "driving-event-detection". The Intent sent should
    // be received by the MainActivity.
    // Allows communication between this service and MainActivity
    // Send an Intent with an action named "driving-event-detection". The Intent sent should
    // be received by the MainActivity.
    private void sendMessage(String msg) {
        Log.d(TAG,"SEND MESSAGE");
        // add timestamp to logger msg
        String DATE_FORMAT_NOW = "dd-MM HH:mm:ss";
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
        sdf.format(cal.getTime());
        msg = "[" + sdf.format(cal.getTime()) + "] : " + msg;

        // USING FLUTTER SHARED PREFERENCES FOR SAVING LOGGER MESSAGES
        if(mPreferences == null){
            mPreferences =  mContext.getSharedPreferences("AndroidLogger", Context.MODE_PRIVATE);
        }
        SharedPreferences.Editor editor = mPreferences.edit();
        Gson gson = new Gson();
        ArrayList<String> loggers;
        if(mPreferences.contains("logger")){
            String json = mPreferences.getString("logger", null);
            Type type = new TypeToken<ArrayList<String>>() {}.getType();
            loggers = gson.fromJson(json, type);
        } else {
            loggers = new ArrayList<>();
        }
        loggers.add(msg);
        String newJson = gson.toJson(loggers);
        editor.putString("logger", newJson);
        editor.apply();
        // END OF SHARED PREFERENCES
    }

}
