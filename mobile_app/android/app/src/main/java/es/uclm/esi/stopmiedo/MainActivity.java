package es.uclm.esi.stopmiedo;

import android.app.ActivityManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import es.uclm.esi.drive_detection.AutoDriveDetectionService;
import es.uclm.esi.drive_detection.EventDetectionService;
import es.uclm.esi.mami.emovi.managers.MiBandServiceManager;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;


public class MainActivity extends FlutterActivity {
  private final String TAG = "MainActivity";

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

  @Override
  public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
    GeneratedPluginRegistrant.registerWith(flutterEngine);
    Log.w(TAG, "MainActivity onCreate");

    intentForDrivingDetectionService = new Intent(MainActivity.this,
            AutoDriveDetectionService.class);

    intentForEMOVI = new Intent(MainActivity.this, MiBandServiceManager.class);

    // DRIVING DETECTION METHOD CHANNEL
    drivingDetectionMethodChannel = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger()
            , ACTIVITY_RECOGNITION_METHOD_CHANNEL);
    drivingDetectionMethodChannel.setMethodCallHandler(
            (call, result) -> {
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
            }
    );
    // EMOVI METHOD CHANNEL
    methodChannelStartService = new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger()
            , EMOVI_METHOD_CHANNEL);
    methodChannelStartService.setMethodCallHandler(
            (call, result) -> {
              if (call.method.equals("startService")) {
                final String macAddress = call.argument("macAddress");
                Log.w(TAG, call.arguments.toString());
                startEMOVIService(macAddress);
                Log.w(TAG, "eMOVI Service Started");
                result.success("eMOVI Service Started");
              } else if (call.method.equals("stopService")) {
                Log.w(TAG, "Method Channel: eMOVI Service Stopped");
                stopService(intentForEMOVI);
                result.success("eMOVI Service stopped");
              } else if (call.method.equals("isServiceRunning")) {
                boolean isRunning = isServiceRunning(MiBandServiceManager.class);
                result.success(isRunning);
              }
            }
    );
  }

  private void startEMOVIService(String macAddress) {
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

  }


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
