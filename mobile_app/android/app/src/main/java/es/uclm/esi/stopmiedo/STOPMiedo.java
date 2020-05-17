package es.uclm.esi.stopmiedo;

import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.os.Build;
import android.util.Log;

import io.flutter.app.FlutterApplication;

public class STOPMiedo extends FlutterApplication {

    @Override
    public void onCreate() {
        Log.d("driving","onCreate() STOPMiedo.java");
        super.onCreate();
        createNotificationChannel();
    }

    private void createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            NotificationChannel serviceChannel = new NotificationChannel(
                    "STOPMiedoService",
                    "STOPMiedo",
                    NotificationManager.IMPORTANCE_LOW
            );

            NotificationManager manager = getSystemService(NotificationManager.class);
            manager.createNotificationChannel(serviceChannel);
        }
    }
}
