package es.uclm.esi.mami.emovi.managers;

import android.app.IntentService;
import android.app.Notification;
import android.app.NotificationChannel;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.app.Service;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.le.ScanResult;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.IBinder;
import android.util.Log;

import androidx.annotation.Nullable;
import androidx.core.app.NotificationCompat;

import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;

import es.uclm.esi.R;
import es.uclm.esi.mami.mibandlib.MiBand;
import es.uclm.esi.stopmiedo.MainActivity;
import io.reactivex.functions.Consumer;

import es.uclm.esi.mami.emovi.behaviour.AutomatonMiBandManager;

/**
 * An {@link IntentService} subclass for handling asynchronous task requests in
 * a service on a separate handler thread.
 * <p>
 * TODO: Customize class - update intent actions, extra parameters and static
 * helper methods.
 */
/**
 * An {@link IntentService} subclass for handling asynchronous task requests in
 * a service on a separate handler thread.
 * <p>
 * TODO: Customize class - update intent actions, extra parameters and static
 * helper methods.
 */
public class MiBandServiceManager extends Service {
    // Things to work
    private HashMap<String, BluetoothDevice> devices;
    private MiBand miBand;
    private InputOutputManagement inputOutputManager;
    private PhyActivityManager phyActivityManager;
    private boolean setConfig = false;
    private boolean actuallyPaired = false;
    private boolean actuallyEnableFetchAndCharAct = false;
    private String macAddress = "";
    //private String macAddress = "E8:84:4D:8E:B6:8F";
    //private String macAddress = "C1:F5:14:77:BD:48";

//    private String macAddress = "F3:58:E3:AF:65:84";
//    private String macAddress = "CB:75:F8:A9:65:F7";

    private static AutomatonMiBandManager automataConducta;
    private final String TAG = "MiBandServiceManager";
    private final String CHANNEL_ID = "eMOVIService";

    public MiBandServiceManager() {
        super();
        devices = new HashMap<>();
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        Log.w(TAG, "On start command!");
        miBand = new MiBand(this, inputOutputManager.readKey());
        Log.w(TAG, "miBand object created");
        macAddress = inputOutputManager.readMacAddress();
        Log.w(TAG, "readMacAddress finished");

        if (macAddress.equals("")) {
            macAddress = intent.getStringExtra("macAddress");
            Log.w(TAG, "MAC ADDRESS DETECT " + String.valueOf(intent.getStringExtra("macAddress")));

            if (!macAddress.equals(null) && !macAddress.equals("")) {
                inputOutputManager.writeMacAddress(macAddress);
            }
        }
        Log.w(TAG, "create automataConducta");
        automataConducta = new AutomatonMiBandManager("AutomataMiBandManager", this, getApplicationContext());
        Log.w(TAG, "create automataConducta");
        automataConducta.automatonInit();
        automataConducta.addEvent("go to con");

        return START_STICKY;
    }

    public Consumer<Boolean> handleConnectResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.w(TAG, "Connected:" + String.valueOf(result));
                if (result) {
                    if (miBand.getKey()[0] == 0x00) {
                        setConfig = true;
                    } else {
                        Log.w("KEY_0x00", String.valueOf(Arrays.toString(miBand.getKey())));
                    }
                    // Enable Notifications (this is the first step preparing pairing/auth...)
                    miBand.setPairRequested(true);
                    automataConducta.addEvent("go to pair");
                } else{
                    Log.w(TAG, "Connection FAIL");
                    actuallyPaired = false;
                    automataConducta.addEvent("go to wait");
                    automataConducta.addEvent("go to con");
                }
            }
        };
    }

    public Consumer<Boolean> handlePairResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {

                Log.w("PAIR", "Pairing result, " + result);
                actuallyPaired = true;
                if (result){
                    if (setConfig) {
                        inputOutputManager.writeKey(miBand.getKey());
                        Log.w("PAIR", "Pairing successful, go to heart");
                        automataConducta.addEvent("go to heart");
                    } else{
                        Log.w("PAIR", "Pairing successful, go to fetch");
                        automataConducta.addEvent("go to fetch");
                    }
                } else{
                    Log.w("PAIR", "Pairing failed, go to wait");
                    automataConducta.addEvent("go to wait");
                    Log.w("PAIR", "Pairing failed, go to con");
                    automataConducta.addEvent("go to con");
                }

            }
        };
    }

    public Consumer<Boolean> handleHeartRateMeasurementResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.w("HEART_RATE","Measuring successful");

                automataConducta.addEvent("go to time");

            }
        };
    }

    public Consumer<Boolean> handleEnableFetchingResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.w("FETCH","Fetching notifications enabled");
                automataConducta.addEvent("go to char_act");

            }
        };
    }

    public Consumer<Boolean> handleEnableCharActivityResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.w("CHAR_ACTIVITY","Char activity notifications enabled, go to st_rec");


                automataConducta.addEvent("go to st_rec");

            }
        };
    }

    public Consumer<Boolean> handleStartFetchingActivityResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.w("ST_FETCH_ACTIVITY","handleStartFetchingActivityResult");


                automataConducta.addEvent("go to rec");

            }
        };


    }

    public Consumer<Boolean> handleFetchingPastDataResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {

                Log.w("FETCH_PAST_DATA","Fetching past data " + result);
                if (!result){
                    Log.w("FETCH_PAST_DATA","Go to wait state");
                    automataConducta.addEvent("go to wait");
                    automataConducta.addEvent("go to st_rec");
                } else{
                    Log.w("FETCH_PAST_DATA","Go to send state");
                    automataConducta.addEvent("go to send");
                    automataConducta.addEvent("go to wait");
                    automataConducta.addEvent("go to pair");
                }

            }
        };
    }

    public Consumer<Boolean> handleSetTimeResult() {
        return new Consumer<Boolean>() {
            @Override
            public void accept(Boolean result) throws Exception {
                Log.w("SET_TIME","Setting the clock's timing");
                setConfig = false;
                if(result) {
                    automataConducta.addEvent("go to pair");

                }

            }
        };

    }

    public void continueWithPairedDevice() throws InterruptedException {
        try{
            if(!actuallyEnableFetchAndCharAct){
                Thread.sleep(5000);

                Log.w(TAG, "FLOW continueWithPairedDevice");
                automataConducta.addEvent("go to fetch");
            } else{
                automataConducta.addEvent("go to st_rec");
            }
        } catch (InterruptedException e){
            Log.w("Exception OCCURRED", e.getMessage());
        }

    }

    public void continueWithFetchedDevice(){
        automataConducta.addEvent("go to wait");
        automataConducta.addEvent("go to pair");

    }

    public Consumer<Throwable> handleError() {
        return new Consumer<Throwable>() {
            @Override
            public void accept(Throwable throwable) throws Exception {
                throwable.printStackTrace();
                Log.w(TAG, "Main Activity " + String.valueOf(throwable));

            }
        };
    }

    public MiBand getMiBand() {
        return miBand;
    }

    public InputOutputManagement getInputOutputManager() {
        return inputOutputManager;
    }

    public PhyActivityManager getPhyActivityManager() {
        return phyActivityManager;
    }

    @Override
    public void onDestroy() {
        Log.w(TAG, "DESTRUYENDO");
        super.onDestroy();
    }

    @Nullable
    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }

    @Override
    public void onCreate() {
        Log.w(TAG, "CREATEANDO");

        phyActivityManager = new PhyActivityManager(new Date());
        inputOutputManager = new InputOutputManagement(this);

        // Registering BroadcastReceiver MyReceiver
        /*
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction("recordingArray");
        registerReceiver(new MyReceiver(),intentFilter);
        */
        /*
        if (Build.VERSION.SDK_INT >= 26) {
            String CHANNEL_ID = "my_channel_01";
            NotificationChannel channel = new NotificationChannel(CHANNEL_ID,
                    "Channel human readable title",
                    NotificationManager.IMPORTANCE_DEFAULT);
            ((NotificationManager) getSystemService(Context.NOTIFICATION_SERVICE)).createNotificationChannel(channel);
            Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                    .setContentTitle("")
                    .setContentText("").build();
            startForeground(1, notification);
        }
        */
        Intent notificationIntent = new Intent(this, MainActivity.class);
        PendingIntent pendingIntent = PendingIntent.getActivity(this,
                0, notificationIntent, 0);

        // A Foreground service must provide a notification for the status bar.
        Notification notification = new NotificationCompat.Builder(this, CHANNEL_ID)
                .setContentTitle("STOPMiedo")
                .setContentText("eMOVI is active")
                .setSmallIcon(R.mipmap.ic_launcher)
                .setContentIntent(pendingIntent)
                .build();
        startForeground(102, notification);

        /*
        NotificationCompat.Builder builder = new NotificationCompat.Builder(this, "messages").
                setContentText("eMOVI is running in background")
                .setContentTitle("eMOVI")
                .setSmallIcon(R.mipmap.ic_launcher);
        startForeground(101, builder.build());
         */
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


    public String getMacAddress() {
        return macAddress;
    }

    public boolean isActuallyPaired() {
        return actuallyPaired;
    }

    public void setActuallyEnableFetchAndCharAct(boolean actuallyEnableFetchAndCharAct) {
        this.actuallyEnableFetchAndCharAct = actuallyEnableFetchAndCharAct;
    }

    public void checkMiBandConnection(){
        BluetoothDevice aux = miBand.getBluetoothIO().getConnectedDevice();
        Log.w(TAG, "DEVICE: " + String.valueOf(aux.getName() + aux.getAddress()));
        if(aux.equals(null)) {
            Log.w(TAG, "NULLIFIED TRYING TO RECONECT");
            automataConducta.addEvent("go to wait");
            automataConducta.addEvent("go to con");
        }
    }

    public HashMap<String, BluetoothDevice> getDevices() {
        return devices;
    }
}