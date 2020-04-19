package com.example.tfg_app;

import android.Manifest;
import android.annotation.TargetApi;
import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

import static android.Manifest.permission.ACCESS_COARSE_LOCATION;
import static android.Manifest.permission.ACCESS_FINE_LOCATION;

public class MainActivity extends FlutterActivity {
  //List of permissions
  private ArrayList permissionsToRequest;
  private ArrayList permissionsRejected = new ArrayList();
  private ArrayList permissions = new ArrayList();
  // integer for permissions results request
  private final static int ALL_PERMISSIONS_RESULT = 101;

  private final String TAG = "MainActivity";

  // Event Channel used to stream  driving event data to the Dart side
  private static final String ACTIVITY_RECOGNITION_EVENTS_STREAM_CHANNEL
          = "driving_detection/activityUpdates";

  // Method Channel used to invoke methods from the Dart side
  private static final String ACTIVITY_RECOGNITION_METHOD_CHANNEL
          = "driving_detection/methodChannel";

  private Intent intentForDrivingDetectionService;
  private MethodChannel methodChannel;
  private EventChannel drivingEventChannel;

  // Used to return results asynchronous computations, through drivingEventChannel
  private EventChannel.EventSink drivingEventSink;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    intentForDrivingDetectionService = new Intent(MainActivity.this,
            AutoDriveDetectionService.class);

    methodChannel = new MethodChannel(getFlutterView(), ACTIVITY_RECOGNITION_METHOD_CHANNEL);
    methodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("startDrivingDetectionService")) {
          startAutoDriveDetectionService();
          result.success("Driving Detection Service Started");
        } else if (call.method.equals("stopDrivingDetectionService")) {
          stopService(intentForDrivingDetectionService);
          result.success("Driving Detection Service stopped");
        } else if (call.method.equals("isDrivingDetectionServiceRunning")) {
          boolean isRunning = isServiceRunning(AutoDriveDetectionService.class);
          result.success(isRunning);
        }
      }
    });

    drivingEventChannel = new EventChannel(getFlutterView(), ACTIVITY_RECOGNITION_EVENTS_STREAM_CHANNEL);
    drivingEventChannel.setStreamHandler(new EventChannel.StreamHandler() {
      @Override
      public void onListen(Object listener, EventChannel.EventSink emitter) {
        drivingEventSink = emitter;
      }
      @Override
      public void onCancel(Object listener) { }
    });

    // we add permissions we need to request location of the users
    permissions.add(Manifest.permission.ACCESS_FINE_LOCATION);
    permissions.add(Manifest.permission.ACCESS_COARSE_LOCATION);

    permissionsToRequest = permissionsToRequest(permissions);

    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      if (permissionsToRequest.size() > 0) {
        requestPermissions((String[]) permissionsToRequest
                .toArray(new String[permissionsToRequest.size()]), ALL_PERMISSIONS_RESULT);
      }
    }
  }

  private ArrayList<String> permissionsToRequest(ArrayList<String> wantedPermissions) {
    ArrayList<String> result = new ArrayList<>();
    for (String perm : wantedPermissions) {
      if (!hasPermission(perm)) {
        result.add(perm);
      }
    }
    return result;
  }

  private boolean hasPermission(String permission) {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
      return checkSelfPermission(permission) == PackageManager.PERMISSION_GRANTED;
    }

    return true;
  }


  private void startAutoDriveDetectionService() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      startForegroundService(intentForDrivingDetectionService);

    else startService(intentForDrivingDetectionService);

    // Register to receive messages from AutoDriveDetectionService.
    // We are registering an observer (driveDetectionReceiver) to receive Intents
    // with actions named "driving-event-detection".
    LocalBroadcastManager.getInstance(this).registerReceiver(driveDetectionReceiver,
            new IntentFilter("driving-event-detection"));
  }

  // Our handler for received Intents. This will be called whenever an Intent
  // with an action named "custom-event-name" is broadcasted.
  private BroadcastReceiver driveDetectionReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      // Get extra data included in the Intent
      // activity default value is UNKNOWN
      int activity = intent.getIntExtra("activity", 4);
      int confidence = intent.getIntExtra("confidence", 0);

      Log.d(TAG, "Got message: " + activity + ", confidence: " + confidence);
      String activityText = "";

      switch (activity) {
        case 0:
          activityText = "conduciendo";
          break;
        case 1:
          activityText = "en bici";
          break;
        case 2:
          activityText = "de pie";
          break;
        case 3:
          activityText = "quieto";
          break;
        case 4:
          activityText = "en estado desconocido";
          break;
        case 5:
          activityText = " ¿inclinación?";
          break;
        case 7:
          activityText = "andando";
          break;
        case 8:
          activityText = "corriendo";
          break;
        default:
          // code block
      }

      drivingEventSink.success("Estás " + activityText + ", probabilidad: " + confidence);
    }
  };


  private boolean isServiceRunning(Class<?> serviceClass) {
    ActivityManager manager = (ActivityManager) getSystemService(Context.ACTIVITY_SERVICE);
    for (ActivityManager.RunningServiceInfo service : manager.getRunningServices(Integer.MAX_VALUE)) {
      if (serviceClass.getName().equals(service.service.getClassName())) {
        return true;
      }
    }
    return false;
  }


  @Override
  protected void onDestroy() {
    super.onDestroy();
    stopService(intentForDrivingDetectionService);

    // Unregister since the service is about to be closed.
    LocalBroadcastManager.getInstance(this).unregisterReceiver(driveDetectionReceiver);
  }
}



