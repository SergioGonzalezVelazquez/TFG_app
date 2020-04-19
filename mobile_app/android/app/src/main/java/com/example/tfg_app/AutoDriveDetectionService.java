package com.example.tfg_app;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.android.gms.location.ActivityRecognitionClient;
import com.google.android.gms.location.ActivityRecognitionResult;
import com.google.android.gms.location.DetectedActivity;

import java.text.SimpleDateFormat;
import java.util.Date;


// This is an instance Android service that will
// stay in the background and listen to the callbacks (intents) of Activity recognition
// and Geo-fence APIs.
// It will control the flow of data between ActivityRecognitionHelper, GPSHelper and
// GeofenceHelper classes, and will send data streams to MainActivity class.
public class AutoDriveDetectionService extends Service {
    public static final String CHANNEL_ID = "ForegroundServiceChannel";
    private final String TAG = "DrivingDetectionService";

    private GeofenceHelper mGeofenceHelper;
    private ActivityRecognitionHelper mActivityRecognitionHelper;
    private GPSHelper mGPSHelper;

    // flags used to avoid calling the handlePotentialStartDriveTrigger()
    // method again when the potential drive start event condition
    // checks are already in progress
    private boolean isDriveCheckInProgress = false;
    private boolean isDriveInProgress = false;

    // Method invokes when the service is initially created.
    // create the objects of the the GeofenceHelper, ActivityRecognitionHelper,
    // GPSHelper classes.
    @Override
    public void onCreate() {
        Log.d(TAG,"onCreate() service");
        super.onCreate();
        createNotificationChannel();
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);

        // A Foreground service must provide a notification for the status bar.
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("STOPMiedo")
                .setContentText("Driving event detection service is active")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .build();
        startForeground(101, notification);

        mActivityRecognitionHelper = new ActivityRecognitionHelper();
        mActivityRecognitionHelper.startActivityUpdates();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    CHANNEL_ID,
                    "STOPMiedo",
                    NotificationManager.IMPORTANCE_DEFAULT
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }

    // We will receive the input of the Activity recognition and Geo-fence APIs inside
    // onStartCommand() from the service.
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        if(ActivityRecognitionResult.hasResult(intent)) {
            String date = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss").format(new Date());
            Log.d(TAG,"onStartCommand() receive the input of the Activity recognition and Geo-fence APIs ");
            handleActivityRecognitionInput(ActivityRecognitionResult.extractResult(intent));
        }else {
            String date = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss").format(new Date());
            Log.d(TAG,date + ": ActivityRecognitionResult.hasNOTResult(intent)");
        }
        return Service.START_STICKY;
    }

    // Get the list of the probable activities associated with the current state of the
    // device. Each activity is associated with a confidence level (between 0-100)
    public void handleActivityRecognitionInput (ActivityRecognitionResult result) {
        Log.d(TAG,"handleActivityRecognitionInput() Result.length: " + result.getProbableActivities().size());
        for (DetectedActivity activity : result.getProbableActivities()) {
            Log.d(TAG, "Detected activity: " + activity.getType() + ", " + activity.getConfidence());
            sendMessage(activity.getType(), activity.getConfidence());

            // If the type of detected activity is WALKING or ON_FOOT
            // and has a confidence of 75 or above, and also if we are in
            // active drive, then we call the handleWalkingActivityDuringDrive() method
            // of the GPSHelper class for further processing
            if(DetectedActivity.WALKING == activity.getType()
                || DetectedActivity.ON_FOOT == activity.getType()){
                if(activity.getConfidence() > Constants.CONFIDENCE_THRESHOLD
                        && !isDriveCheckInProgress && !isDriveInProgress){
                }
            }
            // If the type of detected activity is IN_VEHICLE and has a confidence of 75
            // or above, then we consider it a trigger for the potential start drive event and
            // check for other conditions.
            if(DetectedActivity.IN_VEHICLE == activity.getType()) {
                if(activity.getConfidence() > Constants.CONFIDENCE_THRESHOLD) {
                }
            }
        }
    }

    // Allows communication between this service and MainActivity
    // Send an Intent with an action named "driving-event-detection". The Intent sent should
    // be received by the MainActivity.
    private void sendMessage(int activity, int confidence) {
        Log.d(TAG, "Broadcasting message");
        Intent intent = new Intent("driving-event-detection");
        intent.putExtra("activity", activity);
        intent.putExtra("confidence", confidence);

        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
    }


    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    // inner class inside the AutoDriveDetectionService class
    // It is used to request activities updates ti the Activity recognition API.
    public class ActivityRecognitionHelper {
        public void startActivityUpdates() {
            Log.d(TAG,"startActivityUpdates() ActivityRecognitionHelper");
            Intent intent = new Intent(getApplicationContext(), AutoDriveDetectionService.class);
            PendingIntent pendingIntent = PendingIntent.getService(getApplicationContext(),0,intent, PendingIntent.FLAG_UPDATE_CURRENT);

            //ACTIVITY_RECOGNITION_REQUEST_INTERVAL is 60 seconds
            ActivityRecognitionClient mActivityRecognitionClient = new ActivityRecognitionClient(getApplicationContext());
            mActivityRecognitionClient.requestActivityUpdates(
                    Constants.ACTIVITY_RECOGNITION_REQUEST_INTERVAL,
                    pendingIntent);
        }
    }

    // inner class inside the AutoDriveDetectionService class
    // It has two major objectives:
    //  - Create a new geofence for a given location.
    //  - Remove the last geofence created.
    public class GeofenceHelper {

    }

    // inner class inside the AutoDriveDetectionService class
    // Used to get the locations updates with the implementation of the
    // Fused-location API. Most of the driving start and stop event logic
    // is also present inside this class.
    public class GPSHelper {

    }
}
