package com.example.tfg_app;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;

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

    private static final String COLLECTION_DRIVING_ACTIVITY = "driving_activity";
    private static final String COLLECTION_DRIVING_ROUTE = "driving_routes";
    private static final String COLLECTION_EVENT_DETAILS = "driving_event_details";
    private static final String DRIVE_ID = "driveId";

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
        SharedPreferences mPreferences;

        // Create a Map to store the data we want to set
        Map<String, Object> docData = new HashMap<>();
        docData.put("userId", "abcdefghijklmnpoq");
        docData.put("start_at", FieldValue.serverTimestamp());
        mFirestore.collection(COLLECTION_DRIVING_ACTIVITY).document(driveId).set(docData);


        mPreferences = mContext.getSharedPreferences("DrivingEvents", Context.MODE_PRIVATE);
        SharedPreferences.Editor mEditor = mPreferences.edit();
        mEditor.putString(DRIVE_ID, driveId);
        Log.d(TAG,"generateDriveID() result:" + driveId);
        return driveId;
    }

    /**
     * Provides the latest drive´s unique ID after reading it from the shared preferences.
     * @return unique drive ID as string
     */
    public String getCurrentDriveID(){
        SharedPreferences mSharedPreferences = mContext.getSharedPreferences("DrivingEvents", Context.MODE_PRIVATE);
        return mSharedPreferences.getString(DRIVE_ID, "default");

    }
}
