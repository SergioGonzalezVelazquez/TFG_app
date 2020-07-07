package es.uclm.esi.drive_detection;

import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.location.Location;
import android.os.Build;
import android.os.IBinder;
import android.preference.PreferenceManager;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.android.gms.location.ActivityRecognitionClient;
import com.google.android.gms.location.ActivityRecognitionResult;
import com.google.android.gms.location.DetectedActivity;
import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.Geofence;
import com.google.android.gms.location.GeofencingClient;
import com.google.android.gms.location.GeofencingEvent;
import com.google.android.gms.location.GeofencingRequest;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;

import es.uclm.esi.R;
import es.uclm.esi.stopmiedo.MainActivity;

/**
 * This is an instance Android service that will
 * stay in the background and listen to the callbacks (intents) of Activity recognition
 * and Geo-fence APIs.
 * /It will control the flow of data between ActivityRecognitionHelper, GPSHelper and
 * GeofenceHelper classes, and will send data streams to MainActivity class.
 */
public class AutoDriveDetectionService extends Service {
    private final String CHANNEL_ID = "DrivingDetectionService";
    private final String TAG = "DrivingDetectionService";

    //debug
    private int intervalDebugger = 0;

    private Intent intentEventDetectionService;
    private GeofenceHelper mGeofenceHelper;
    private ActivityRecognitionHelper mActivityRecognitionHelper;
    private GPSHelper mGPSHelper;
    private LocationDBHelper mLocationDBHelper;

    // flags used to avoid calling the handlePotentialStartDriveTrigger()
    // method again when the potential drive start event condition
    // checks are already in progress
    private boolean isDriveCheckInProgress = false;
    private boolean isDriveInProgress = false;

    /**
     * Method invokes when the service is initially created.
     * create the objects of the the GeofenceHelper, ActivityRecognitionHelper,
     * GPSHelper classes.
     */
    @Override
    public void onCreate() {
        super.onCreate();
        createNotificationChannel();
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);

        // A Foreground service must provide a notification for the status bar.
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("STOPMiedo")
                .setContentText("El servicio de detección de la condución se está ejecutando en segundo plano")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .build();
        startForeground(101, notification);
        mLocationDBHelper = new LocationDBHelper(getApplicationContext());
        mGPSHelper = new GPSHelper();
        mGeofenceHelper = new GeofenceHelper();
        mActivityRecognitionHelper = new ActivityRecognitionHelper();
        mGPSHelper.getSingleLocationForGeoFence();
        mActivityRecognitionHelper.startActivityUpdates();
    }

    public void createNotificationChannel() {
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

    // The system invokes this method when the service is no longer used and is being destroyed.
    @Override
    public void onDestroy() {
        sendMessage("AutoDriveDetectionService stopped");
        super.onDestroy();
        mActivityRecognitionHelper.stopActivityUpdates();
        mGPSHelper.stopLocationUpdates();

        if(intentEventDetectionService != null) {
            stopService(intentEventDetectionService);
        }
    }

    @Override
    public void onTaskRemoved(Intent rootIntent) {
        Intent restartServiceIntent = new Intent(getApplicationContext(),this.getClass());
        restartServiceIntent.setPackage(getPackageName());
        startService(restartServiceIntent);
        super.onTaskRemoved(rootIntent);
    }

    /**
     * We will receive the input of the Activity recognition and Geo-fence APIs inside
     * onStartCommand() from the service.
     */
    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        GeofencingEvent geofencingEvent = GeofencingEvent.fromIntent(intent);
        if(geofencingEvent != null){
            if(!geofencingEvent.hasError()) {
                Log.w(TAG,"onStartCommand() geofencingEvent");
                handleGeofenceInput(geofencingEvent);
            }
        }
         if(ActivityRecognitionResult.hasResult(intent)) {
            String date = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss").format(new Date());
            Log.w(TAG,"onStartCommand() receive the input of the Activity recognition and Geo-fence APIs ");

            // DEBUG: Fuerza el inicio de la conducción
            if(intervalDebugger == 0){
                 handleActivityRecognitionInput(ActivityRecognitionResult.extractResult(intent), false);
             }
             else {
                 handleActivityRecognitionInput(ActivityRecognitionResult.extractResult(intent), false);
             }
             intervalDebugger++;

        } else {
            String date = new SimpleDateFormat("dd-MM-yyyy hh:mm:ss").format(new Date());
            Log.w(TAG,date + ": ActivityRecognitionResult.hasNOTResult(intent)");
        }
        return Service.START_STICKY;
    }



    // If not-in-drive and not-in-checking-for-potential-start drive, then we remove the
    // last geo-fence.
    public void handleGeofenceInput(GeofencingEvent geofencingEvent){
        Log.w(TAG,"handleGeofenceInput: " + geofencingEvent.toString());
        Log.w(TAG,"getGeofenceTransition: " + geofencingEvent.getGeofenceTransition());
        if (geofencingEvent.getGeofenceTransition() == Geofence.GEOFENCE_TRANSITION_EXIT) {
            Log.w(TAG,"geofencingEvent.getGeofenceTransition() == Geofence.GEOFENCE_TRANSITION_EXIT");
            mGeofenceHelper.removeLastGeoFence();
            if(!isDriveCheckInProgress && !isDriveInProgress) {
                sendMessage("handleGeofenceInput handlePotentialStartDriveTrigger");
                mGPSHelper.handlePotentialStartDriveTrigger();
            }
        }
    }

    /**
     * Get the list of the probable activities associated with the current state of the
     * device. Each activity is associated with a confidence level (between 0-100)
     * @param result list of the probable activities
     * @param simulateDriving
     */
    public void handleActivityRecognitionInput (ActivityRecognitionResult result, boolean simulateDriving) {
        Log.w(TAG,"handleActivityRecognitionInput() Result.length: " + result.getProbableActivities().size());

        if(simulateDriving) {
            mGeofenceHelper.removeLastGeoFence();
            mGPSHelper.handlePotentialStartDriveTrigger();
            sendMessage("simulado posible comienzo de conducción");
            return ;
        }
        for (DetectedActivity activity : result.getProbableActivities()) {
            Log.w(TAG, "Detected activity: " + activity.getType() + ", " + activity.getConfidence());
            // If the type of detected activity is WALKING or ON_FOOT
            // and has a confidence of 75 or above, and also if we are in
            // active drive, then we call the handleWalkingActivityDuringDrive() method
            // of the GPSHelper class for further processing
            if(DetectedActivity.WALKING == activity.getType()
                    || DetectedActivity.ON_FOOT == activity.getType() || DetectedActivity.STILL == activity.getType()) {
                //CONFIDENCE THRESHOLD is 75
                if(activity.getConfidence() > Constants.CONFIDENCE_THRESHOLD && isDriveInProgress) {
                    mGPSHelper.handleWalkingActivityDuringDrive();
                    sendMessage("DetectedActivity.WALKING or ON_FOOT, CONFIDENCE THRESHOLD is >= 75 and isDriveInProgress");
                }else {
                    sendMessage("DetectedActivity.WALKING or ON_FOOT with confidence of " + activity.getConfidence());
                }
            }
            // If the type of detected activity is IN_VEHICLE and has a confidence of 75
            // or above, then we consider it a trigger for the potential start drive event and
            // check for other conditions.
            else if(DetectedActivity.IN_VEHICLE == activity.getType()) {
                sendMessage("DetectedActivity.IN_VEHICLE with confidence of " + activity.getConfidence());
                if(activity.getConfidence() > Constants.CONFIDENCE_THRESHOLD &&
                        !isDriveCheckInProgress && !isDriveInProgress) {
                    sendMessage("DetectedActivity.IN_VEHICLE handlePotentialStartDriveTrigger");
                    mGeofenceHelper.removeLastGeoFence();
                    mGPSHelper.handlePotentialStartDriveTrigger();
                }
            }
            // DEBUG: Este else if sobra
            else if (activity.getConfidence() > Constants.CONFIDENCE_THRESHOLD) {
                String activityText = "";
                switch (activity.getType()) {
                    case 0:
                        activityText = "IN_VEHICLE";
                        break;
                    case 1:
                        activityText = "ON_BICYCLE";
                        break;
                    case 2:
                        activityText = "ON_FOOT";
                        break;
                    case 3:
                        activityText = "STILL";
                        break;
                    case 4:
                        activityText = "UNKNOWN";
                        break;
                    case 5:
                        activityText = "TILTING";
                        break;
                    case 7:
                        activityText = "WALKING";
                        break;
                    case 8:
                        activityText = "RUNNING";
                        break;
                    default:
                        // code block
                }

                sendMessage("Detected Activity : " + activityText + "conf: " + activity.getConfidence());
            }
        }
    }

    /**
     * Method used for communication with GPSHelper class.
     * Create a new geo-fence with the latest location.
     * @param location latest location
     */
    public void onNewLocationFoundForGeoFence(Location location) {
        mGeofenceHelper.createNewGeoFence(location);
    }

    /**
     * Passes a boolean variable, the isDriveStarted as true to
     * the Event Detection Service class, using the intent.
     * @param location location from GPSHelper
     */
    public void onStartDrivingEvent(Location location) {
        sendMessage("onStartDrivingEvent :" + location.toString() );
        intentEventDetectionService = new Intent(this, EventDetectionService.class);
        intentEventDetectionService.putExtra("isDriveStarted", true);
        mLocationDBHelper.generateDriveID(location);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            startForegroundService(intentEventDetectionService);
        else startService(intentEventDetectionService);
    }

    public void onStopDrivingEvent(Location location) {
        sendMessage("onStopDrivingEvent :" + location.toString() );
        mGeofenceHelper.createNewGeoFence(location);
        intentEventDetectionService = new Intent(this, EventDetectionService.class);
        intentEventDetectionService.putExtra("isDriveStarted", false);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
            startForegroundService(intentEventDetectionService);
        else startService(intentEventDetectionService);
    }

    // IMPORTANTE. NO VIENE EN LA BIOGRAFÍA.
    // Se utiliza para decirle al servicio EventDetection que la
    // clase GPSHelper ha reconocido una potencial parada. Mientras no se
    // confirme que ha sido un falso positivo, no se escribiran nuevas rutas en la BBDD
    // Esto consigue que no se guarde la localización cuando el usuario se ha bajado del coche
    // y está andando.
    public void onPotentialStopDriving() {
        Log.w(TAG, "onPotentialStop driving starts");
        intentEventDetectionService = new Intent(this, EventDetectionService.class);
        intentEventDetectionService.putExtra("isStopCheckInProgress", true);
    }

    public void onPotentialStopFailed() {
        Log.w(TAG, "onPotentialStop failed");
        intentEventDetectionService = new Intent(this, EventDetectionService.class);
        intentEventDetectionService.putExtra("isStopCheckInProgress", false);
    }

    /**
     * Uses the object of the LocationDBHelper class to save
     * the parking location in the database via an array list of
     * Event Data.
     * @param location of detected parking
     */
    public void onParkingDetected(Location location) {
        sendMessage("onParkingDetected :" + location.toString() );
        ArrayList<EventData> parkingList = new ArrayList<EventData>();
        EventData eventData = new EventData();
        eventData.eventType = DrivingEventType.PARKING;
        eventData.eventTime = location.getTime();
        eventData.latitude = location.getLatitude();
        eventData.longitude = location.getLongitude();
        parkingList.add(eventData);
        mLocationDBHelper.updateEventDetails(parkingList);
        parkingList.clear();
        sendMessage("closeDrivingActivity :" + location.toString() );
        mLocationDBHelper.closeDrivingActivity(location);
    }

    public void onStartDriveFailed(Location location) {
        mGeofenceHelper.createNewGeoFence(location);
    }

    // Allows communication between this service and MainActivity
    // Send an Intent with an action named "driving-event-detection". The Intent sent should
    // be received by the MainActivity.
    private void sendMessage(String msg) {
        // add timestamp to logger msg
        String DATE_FORMAT_NOW = "dd-MM HH:mm:ss";
        Calendar cal = Calendar.getInstance();
        SimpleDateFormat sdf = new SimpleDateFormat(DATE_FORMAT_NOW);
        sdf.format(cal.getTime());
        msg = "[" + sdf.format(cal.getTime()) + "] : " + msg;
        Log.w(TAG, msg);

        // USING FLUTTER SHARED PREFERENCES FOR SAVING LOGGER MESSAGES
        /*
        if(mPreferences == null){
            mPreferences = getSharedPreferences("AndroidLogger", Context.MODE_PRIVATE);
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

        Intent intent = new Intent("driving-event-detection");
        intent.putExtra("msg", msg);
        LocalBroadcastManager.getInstance(this).sendBroadcast(intent);
        */
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    // inner class inside the AutoDriveDetectionService class
    // It is used to request activities updates ti the Activity recognition API.
    public class ActivityRecognitionHelper {
        private ActivityRecognitionClient mActivityRecognitionClient;
        private PendingIntent mActivityRecognitionPendingIntent;

        public void startActivityUpdates() {
            Log.w(TAG,"startActivityUpdates() ActivityRecognitionHelper");
            Intent intent = new Intent(getApplicationContext(), AutoDriveDetectionService.class);
            mActivityRecognitionPendingIntent = PendingIntent.getService(getApplicationContext(),0,intent, PendingIntent.FLAG_UPDATE_CURRENT);

            //ACTIVITY_RECOGNITION_REQUEST_INTERVAL is 60 seconds (60 * 1000 milliseconds)
            mActivityRecognitionClient = new ActivityRecognitionClient(getApplicationContext());
            mActivityRecognitionClient.requestActivityUpdates(
                    Constants.ACTIVITY_RECOGNITION_REQUEST_INTERVAL,
                    mActivityRecognitionPendingIntent);
        }

        public void stopActivityUpdates(){
            if(mActivityRecognitionClient != null){
                mActivityRecognitionClient.removeActivityUpdates(mActivityRecognitionPendingIntent);
            }
        }
    }

    // inner class inside the AutoDriveDetectionService class
    // It has two major objectives:
    //  - Create a new geofence for a given location.
    //  - Remove the last geofence created.
    public class GeofenceHelper {
        private GeofencingClient mGeofencingClient;
        private GeofencingRequest mGeofencingRequest;
        private ArrayList<String> mGeofencedIDList = new
                ArrayList<String>();
        private Geofence mGeofence;
        private Location mLocation;
        private boolean createNewGeoFence = false;

        // create a new geofence for a given location
        public void createNewGeoFence(Location location) {
            sendMessage("GeofenceHelper: createNewGeoFence");
            this.createNewGeoFence = true;
            this.mLocation = location;
            connectToGeofenceService();
        }

        // remove the last geofence created
        public void removeLastGeoFence() {
            sendMessage("GeofenceHelper: removeLastGeoFence");
            this.createNewGeoFence = false;
            connectToGeofenceService();
        }

        // create a new geo-fence or remove the old one, depending on the state of the
        // boolean variable createNewGeoFence, which is set inside the public createNewGeoFence()
        // and removeLastGeoFence() methods.
        private void connectToGeofenceService(){
            Log.w(TAG,"connectToGeofenceService");
            if (mGeofencingClient == null) {
                mGeofencingClient = LocationServices.getGeofencingClient(getApplicationContext());
            }
            //create new geofence
            if(createNewGeoFence) {
                // Step 1: Creation of the new geo-fence object using the location API´S builder class.
                mGeofencedIDList.add(Constants.GEOFENCE_NAME);
                mGeofence = new Geofence.Builder()
                        .setRequestId(mGeofencedIDList.get(0))
                        .setTransitionTypes(Geofence.GEOFENCE_TRANSITION_EXIT)
                        .setCircularRegion(mLocation.getLatitude(), mLocation.getLongitude(), Constants.GEOFENCE_RADIUS)
                        .setExpirationDuration(Geofence.NEVER_EXPIRE)
                        .build();

                // Step 2: Creation of a new geo-fence request object
                mGeofencingRequest = new GeofencingRequest.Builder().addGeofence(mGeofence).build();
                Intent intent = new Intent(getApplicationContext(), AutoDriveDetectionService.class);
                PendingIntent pendingIntent =
                        PendingIntent.getService(getApplicationContext(), 0 , intent, PendingIntent.FLAG_UPDATE_CURRENT);

                // Step 3: Addition of the geo-fence request to the geo-fence API
                mGeofencingClient.addGeofences(mGeofencingRequest, pendingIntent);
            }
            // remove old geofence
            else {
                mGeofencingClient.removeGeofences(mGeofencedIDList);
                mGeofencedIDList.clear();
            }
            // DUDA. En el libro hace un disconnect aquí.
        }
    }

    /**
     * inner class inside the AutoDriveDetectionService class
     * Used to get the locations updates with the implementation of the
     *  Fused-location API. Most of the driving start and stop event logic
     *  is also present inside this class.
     */
    public class GPSHelper {
        private FusedLocationProviderClient mFusedLocationClient;
        private LocationCallback mLocationCallback;
        private LocationRequest mLocationRequest;
        private boolean getSingleLocation = false;
        private ArrayList<Location> mPotentialStartList = new ArrayList<Location>();
        private ArrayList<Location> mPotentialStopList = new ArrayList<Location>();

        /**
        * Get the single location for setting the initial geo-fence
        * Set up the current location when the service starts.
        * After getting a single location, we turn off the location updates.
        */
        public void getSingleLocationForGeoFence() {
            getSingleLocation = true;
            startLocationUpdates();
        }

        /**
         * Check for a potential drive start event confirmation or failure.
         * After getting regular location updates in the onLocationChanged method, we
         * check the drive start confirmation condition.
         */
        public void handlePotentialStartDriveTrigger() {
            sendMessage("handlePotentialStartDriveTrigger");
            isDriveCheckInProgress = true;
            startLocationUpdates();
        }



        public void startLocationUpdates(){
            sendMessage("GPSHelper startLocationUpdates");
            if(mFusedLocationClient == null) {
                sendMessage("GPSHelper mFusedLocationClient == null");
                mLocationRequest = LocationRequest.create();
                // The accuracy of the location is the most important to us. It uses GPS as its
                // main source for location updates.
                mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
                // Set the desired interval between any two active location updates in milliseconds.
                mLocationRequest.setInterval(Constants.GPS_INTERVAL);
                mLocationRequest.setFastestInterval(Constants.GPS_INTERVAL);

                mFusedLocationClient = LocationServices.getFusedLocationProviderClient(getApplicationContext());

                // Receive all the location updates by the fused location API. The location updates
                // are received in the form of objects of the Location class, which contain location
                // information such as latitude, longitude, speed, accuracy, time of location update
                // angle and altitude.
                mLocationCallback = new LocationCallback() {
                    public void onLocationResult(LocationResult locationResult) {
                        sendMessage("GPSHelper mLocationCallback received");
                        if (locationResult != null) {
                            Location location = locationResult.getLocations().get(0);
                            if(isDriveInProgress){
                                checkForPotentialStopEvent(location);
                            }
                            else {
                                if(getSingleLocation) {
                                    sendMessage("GPSHelper getSingleLocation lat- " + location.getLatitude() +" long- " + location.getLongitude());
                                    onNewLocationFoundForGeoFence(location);
                                    stopLocationUpdates();
                                    getSingleLocation = false;
                                } else {
                                    checkForPotentialStartEvent(location);
                                }
                            }
                        }
                    };
                };

                mFusedLocationClient.requestLocationUpdates(mLocationRequest, mLocationCallback, null);
            }
        }

        /**
         * Stop GPS location updates
         */
        public void stopLocationUpdates(){
            sendMessage("GPSHelper stopLocationUpdates");
            if(mFusedLocationClient != null){
                mFusedLocationClient.removeLocationUpdates(mLocationCallback);

                mFusedLocationClient = null;
            }
        }

        /**
         * Check for potential drive stop event confirmation or failure. Once the drive
         * has started, we start monitoring for the drive stop event.
         * This method receives all the locations updates from the GPS, and we check
         * if the driving speed is zero (we consider then a potential drive stop).
         *
         * Once we get a potential drive stop event, which is checked using the size of the
         * mPotentialStopList array, and if the size is greater than zero, it means we already
         * have a potential drive stop event in progress.
         * The confirmation of potential drive stop based on two conditions:
         *      - The potential drive stop event remains active for 5 minutes.
         *      - We get a high confidence walking or on foot activity from the activity recognition.
         *
         * @param location updated from the GPS
         */
        public void checkForPotentialStopEvent(Location location) {
            if(location.getSpeed() == 0) {
                if(mPotentialStartList.isEmpty()) {
                    onPotentialStopDriving();
                }
                mPotentialStopList.add(location);
                //BACKINDRIVE_SPEED_THRESHOLD is 3.57 meters per second or 8 mph
            } else if(mPotentialStopList.size()>0 &&
                    location.getSpeed()>Constants.BACKINDRIVE_SPEED_THRESHOLD) {
                //Back in the drive
                mPotentialStopList.clear();
                onPotentialStopFailed();
            }
            //POTENTIALSTOP_TIME_THRESHOLD is 300 seconds or 5 mins
            if(mPotentialStopList.size()>0 &&
                    System.currentTimeMillis() - mPotentialStopList.get(0)
                            .getTime() > Constants.POTENTIALSTOP_TIME_THRESHOLD) {
                confirmStopDrivingEvent();
            }
        }

        /**
         * Called from AutoDriveDetectionService when we get a high confidence
         * walking or on foot activity from the activity recognition API.
         */
        public void handleWalkingActivityDuringDrive(){
            if(mPotentialStopList.size()>0) {
                confirmStopDrivingEvent();
            }
        }

        /**
         * Set the boolean variable isDriveInProgress to false and stop the location updates.
         * We also clear the mPotentialStopList array and notify AutoDriveDetectionService by
         * calling its onStopDrivingEvent() method, passing the latest location object, which
         * will be used to set up the new geo-fence.
         */
        public void confirmStopDrivingEvent() {
            isDriveInProgress = false;
            stopLocationUpdates();
            onStopDrivingEvent(mPotentialStopList
                    .get(mPotentialStopList.size() - 1));
            onParkingDetected(mPotentialStopList.get(0));
            mPotentialStopList.clear();
        }


        /**
         * Check the drive start confirmation condition. Whenever the driving speed
         * goes above 6.7 meters per second (24,1 km/h) for the next 60 seconds, then
         * we assume that it was a false positive event and call the confirmStartDriveFailed()
         * method.
         * @param location update from the GPS
         */
        public void checkForPotentialStartEvent(Location location) {
            sendMessage("GPSHelper checkForPotentialStartEvent");
            mPotentialStartList.add(location);
            //POTENTIALSTOP_SPEED_THRESHOLD is 6.7 meters per second or 15 miles per hour
            if (location.getSpeed() >
                    Constants.POTENTIALSTOP_SPEED_THRESHOLD) {
                sendMessage("GPSHelper confirmStartDrivingEvent because speed is " + location.getSpeed() + "m/s");
                confirmStartDrivingEvent();
                //POTENTIALSTART_TIME_THRESHOLD is 60 seconds
            } else if (location.getTime() -
                    mPotentialStartList.get(0).getTime() >
                    Constants.POTENTIALSTART_TIME_THRESHOLD) {
                sendMessage("GPSHelper confirmStartDriveFailed");
                confirmStartDriveFailed(location);
            }
        }

        // Sets the isDriveCheckInProgress boolean variable to
        // false and isDriveInProgress to true. After that, notifies the
        // AutoDriveDetectionService by calling its onStartDrivingEvent()
        public void confirmStartDrivingEvent() {
            isDriveCheckInProgress = false;
            isDriveInProgress = true;
            onStartDrivingEvent(mPotentialStartList.get(0));
            mPotentialStartList.clear();
        }

        // Stops the location updates and sets the isDriveCheckInProgres boolean
        // variable to false. Notifies the AutoDriveDetectionService by calling its
        // onStartDriveFailed() method and passing the lastest location.
        public void confirmStartDriveFailed(Location location) {
            stopLocationUpdates();
            isDriveCheckInProgress = false;
            onStartDriveFailed(location);
            mPotentialStartList.clear();
        }
    }
}
