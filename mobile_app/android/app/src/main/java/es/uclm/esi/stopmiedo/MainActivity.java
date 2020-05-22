package es.uclm.esi.stopmiedo;

import android.Manifest;
import android.app.ActivityManager;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.content.SharedPreferences;
import android.content.pm.PackageManager;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import java.util.ArrayList;
import java.util.Map;

import es.uclm.esi.drive_detection.AutoDriveDetectionService;
import es.uclm.esi.drive_detection.EventDetectionService;
import es.uclm.esi.mami.emovi.managers.MiBandServiceManager;
import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private final String TAG = "MainActivity";

  // Event Channel used to stream  driving event data to the Dart side
  /*
  private static final String ACTIVITY_RECOGNITION_EVENTS_STREAM_CHANNEL
          = "driving_detection/activityUpdates";*/

  // Method Channel used to invoke methods from the Dart side related to
  // AutoDriveDetection Service
  private static final String ACTIVITY_RECOGNITION_METHOD_CHANNEL
          = "driving_detection/methodChannel";

  // Method Channel used to invoke methods from the Dart side
  // related to eMOVI Service
  private static final String EMOVI_METHOD_CHANNEL
          = "emovi/methodChannel";
  private static final String EMOVI_CHANNEL_STARTSERVICE = "es.uclm.mami.init_miband_service";
  private static final String EMOVI_CHANNEL_MAC_ADDRESS = "es.uclm.esi.mami.macAddress";
  private static MethodChannel methodChannelStartService;
  private Intent intentForEMOVI;

  // driving Detection channels
  private Intent intentForDrivingDetectionService;
  private MethodChannel drivingDetectionMethodChannel;
  // private EventChannel drivingEventChannel;
  // Used to return results asynchronous computations, through drivingEventChannel
  // private EventChannel.EventSink drivingEventSink;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);
    Log.w(TAG, "MainActivity onCreate");

    intentForDrivingDetectionService = new Intent(MainActivity.this,
            AutoDriveDetectionService.class);

    intentForEMOVI = new Intent(MainActivity.this, MiBandServiceManager.class);

    // DRIVING DETECTION METHOD CHANNEL
    drivingDetectionMethodChannel = new MethodChannel(getFlutterView(), ACTIVITY_RECOGNITION_METHOD_CHANNEL);
    drivingDetectionMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("startDrivingDetectionService")) {
          startAutoDriveDetectionService();
          Log.w(TAG, "Method Channel: Driving Detection Service Started");
          result.success("Driving Detection Service Started");
        } else if (call.method.equals("stopDrivingDetectionService")) {
          Log.w(TAG, "Method Channel: Driving Detection Service Stopped");
          stopService(intentForDrivingDetectionService);
          result.success("Driving Detection Service stopped");
        } else if (call.method.equals("isDrivingDetectionServiceRunning")) {
          boolean isRunning = isServiceRunning(AutoDriveDetectionService.class);
          result.success(isRunning);
        } else if (call.method.equals("isEventDetectionServiceRunning")) {
          boolean isRunning = isServiceRunning(EventDetectionService.class);
          result.success(isRunning);
        }
        // ONLY FOR TESTING PURPOSE
        else if (call.method.equals("getLogger")) {
          Log.d("MAIN ACTIVITY SHARED", "RESUME");
          SharedPreferences mPreferences = getSharedPreferences("AndroidLogger", Context.MODE_PRIVATE);
          Map<String, ?> prefsMap = mPreferences.getAll();
          for (Map.Entry<String, ?> entry : prefsMap.entrySet()) {
            Log.d("MAIN ACTIVITY SHARED", entry.getKey() + ":" +
                    entry.getValue().toString());
          }
          String logger = mPreferences.getString("logger", null);
          result.success(logger);
        }
      }
    });

    // EMOVI METHOD CHANNEL
    methodChannelStartService = new MethodChannel(getFlutterView(), EMOVI_METHOD_CHANNEL);
    methodChannelStartService.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall call, MethodChannel.Result result) {
        if (call.method.equals("startService")) {
          final String macAddress = call.argument("macAddress");
          Log.w(TAG, call.arguments.toString());
          startEMOVIService(macAddress);
          Log.w(TAG, "eMOVI Service Started");
          result.success("eMOVI Service Started");
        }
        else if (call.method.equals("stopService")) {
          Log.w(TAG, "Method Channel: eMOVI Service Stopped");
          stopService(intentForEMOVI);
          result.success("eMOVI Service stopped");
        }
        else if (call.method.equals("isServiceRunning")) {
          boolean isRunning = isServiceRunning(MiBandServiceManager.class);
          result.success(isRunning);
        }
      }
    });
  }

  private void startEMOVIService(String macAddress){
    intentForEMOVI.putExtra("macAddress", macAddress);
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
      Log.w(TAG, "onMethodCall INIT SERVICE TEST");
      Log.w(TAG, "Start Foreground Service");
      startForegroundService(intentForEMOVI);
    } else {
      Log.w(TAG, "Start Service");
      startService(intentForEMOVI);
    }
  }

  private void startAutoDriveDetectionService() {
    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O)
      startForegroundService(intentForDrivingDetectionService);
    else startService(intentForDrivingDetectionService);

    // Register to receive messages from AutoDriveDetectionService.
    // We are registering an observer (driveDetectionReceiver) to receive Intents
    // with actions named "driving-event-detection".
    /*
    LocalBroadcastManager.getInstance(this).registerReceiver(driveDetectionReceiver,
            new IntentFilter("driving-event-detection"));
            */
  }

  // Our handler for received Intents. This will be called whenever an Intent
  // with an action named "custom-event-name" is broadcasted.
  /*
  private BroadcastReceiver driveDetectionReceiver = new BroadcastReceiver() {
    @Override
    public void onReceive(Context context, Intent intent) {
      // Get extra data included in the Intent
      // activity default value is UNKNOWN
      String msg = intent.getStringExtra("msg");
      drivingEventSink.success(msg);
    }
  };
   */


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
    // LocalBroadcastManager.getInstance(this).unregisterReceiver(driveDetectionReceiver);
  }
}



