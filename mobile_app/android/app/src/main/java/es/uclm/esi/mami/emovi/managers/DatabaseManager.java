package es.uclm.esi.mami.emovi.managers;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import androidx.annotation.NonNull;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.DocumentSnapshot;
import com.google.firebase.firestore.FieldValue;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.SetOptions;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

import es.uclm.esi.mami.mibandlib.model.PhyActivity;

/**
 * This class is used to handle the database operations. It is used to persist the physical activity
 * data in the database.
 *
 * Inside the class, we handle a firestore collections, called phy_activity.
 */
public class DatabaseManager {
    private SharedPreferences mPreferences;
    private FirebaseFirestore mFirestore;
    private Context mContext;
    private String userId;

    private final String TAG = "DatabaseManager";
    private SimpleDateFormat formatDate = new SimpleDateFormat("yyyy_MM_dd");
    private SimpleDateFormat formatTime = new SimpleDateFormat("HH");
    private final String FLUTTER_SHARED_PREFERENCES = "FlutterSharedPreferences";
    private static final String COLLECTION_PHY_ACTIVITY = "phy_activity";
    private static final String ACTIVITIES_DOCUMENT = "activities";

    public DatabaseManager(Context context){
        this.userId = "";
        this.mContext = context;
        initFirestore();
    }

    private void initFirestore() {
        mFirestore = FirebaseFirestore.getInstance();
    }

    /**
     *  This method takes an PhyActivityObject and inserts it
     *  into the corresponding subcollection of phy_activity collection.
     *
     *  Returns true if task is successful.
     *
     * @param phyActivity element that will be stored
     */
    public void storePhyActivity(PhyActivity phyActivity){
        //final boolean[] result = new boolean[1];
        Log.w(TAG, phyActivity.toString());

        // Read userID from sharedPreferences
        if(this.userId.isEmpty()){
            Log.w(TAG, "userID is empty");
            this.userId = getCurrentUserID();
            Log.w(TAG, "userID: " + userId);
        }
        // Get Date as string (YYYY_MM_DD)
        Date date = new Date(phyActivity.getActivityTimestamp().getTime());
        final String strDate = formatDate.format(date);
        final String strCurrentHour = formatTime.format(date) + "_00";

        // Check if document for current hour exists in current date subcollection
        //DocumentReference docIdRef =  mFirestore.collection(COLLECTION_PHY_ACTIVITY).document(userId).collection(strDate).document(strCurrentHour);
        // Initialize current hour document with an array which contains current phyActivity
        //Log.w(TAG, "Document " + strCurrentHour + " does not exists!");
        Log.w(TAG, "Document for " + strDate + "collection at " + strCurrentHour);
        Map<String, Object> docData = new HashMap<>();
        docData.put(ACTIVITIES_DOCUMENT, FieldValue.arrayUnion(phyActivity.toMap()));
        mFirestore.collection(COLLECTION_PHY_ACTIVITY)
                .document(userId)
                .collection(strDate)
                .document(strCurrentHour)
                .set(docData, SetOptions.merge());

        Log.w(TAG, "storePhyActivity completed");
    }

    /**
     * Provides the user unique ID after reading it from the shared preferences.
     * @return unique drive ID as string
     */
    private String getCurrentUserID(){
        Log.w(TAG, "Get Current USER ID");
        // Get current auth user id from SharedPreferences
        SharedPreferences mPreferencesFlutter =
                this.mContext.getSharedPreferences(FLUTTER_SHARED_PREFERENCES, Context.MODE_PRIVATE);
        return mPreferencesFlutter.getString("flutter."+"userId", null);

    }
}
