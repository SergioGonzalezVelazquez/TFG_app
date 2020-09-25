package es.uclm.esi.mami.mibandlib;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.le.BluetoothLeScanner;
import android.bluetooth.le.ScanCallback;
import android.bluetooth.le.ScanResult;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.util.Log;

import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import org.apache.commons.lang3.ArrayUtils;

import es.uclm.esi.mami.mibandlib.listenters.NotifyListener;
import es.uclm.esi.mami.mibandlib.model.Profile;
import es.uclm.esi.mami.mibandlib.model.Protocol;
import io.reactivex.Observable;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.util.Arrays;
import java.util.Calendar;
import java.util.UUID;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;

import io.reactivex.ObservableEmitter;
import io.reactivex.ObservableOnSubscribe;
import io.reactivex.subjects.PublishSubject;

import java.util.Date;

public final class MiBand implements BluetoothListener {

    private static final String TAG = "miband-wearable";

    private final Context context;
    private final BluetoothIO bluetoothIO;

    private PublishSubject<Boolean> connectionSubject;

    private PublishSubject<Boolean> pairSubject;
    private boolean pairRequested;

    private PublishSubject<Boolean> fetchDescriptorSubject;
    private PublishSubject<Boolean> charActivityDescriptorSubject;
    private PublishSubject<Boolean> startFetchingActivitySubject;
    private PublishSubject<Boolean> fetchingPastDataSubject;
    private PublishSubject<Boolean> setTimeDataSubject;

    private PublishSubject<Boolean> setHeartRateMeasure;

    private byte[] miBandKey;

    public MiBand(Context context, byte[] key) {
        this.context = context;
        bluetoothIO = new BluetoothIO(this);

        connectionSubject = PublishSubject.create();
        pairSubject = PublishSubject.create();
        fetchDescriptorSubject = PublishSubject.create();
        charActivityDescriptorSubject = PublishSubject.create();
        startFetchingActivitySubject = PublishSubject.create();
        fetchingPastDataSubject = PublishSubject.create();
        setTimeDataSubject = PublishSubject.create();
        setHeartRateMeasure = PublishSubject.create();


        miBandKey = key;
        Log.d("KEY:", String.valueOf(Arrays.toString(miBandKey)));


    }

    /**
     * Starts scanning for devices
     *
     * @return An Observable which emits ScanResult
     */
    public Observable<ScanResult> startScan() {
        final Intent intent = new Intent();
        intent.setAction("STOP_SCANNING");

        return Observable.create(new ObservableOnSubscribe<ScanResult>() {
            @Override
            public void subscribe(final ObservableEmitter<ScanResult> subscriber) throws Exception {
                BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
                if (adapter != null) {
                    // Esta forma me implementar la API 21 (en lugar de la 19)
                    final BluetoothLeScanner scanner = adapter.getBluetoothLeScanner();
                    if (scanner != null) {
                        Handler handler = new Handler();
                        // Stops scanning after 10 seconds.
                        final long SCAN_PERIOD = 15000;
                        // Stops scanning after a pre-defined scan period.
                        handler.postDelayed(new Runnable() {
                            @Override
                            public void run() {
                                LocalBroadcastManager.getInstance(context).sendBroadcast(intent);
                            }
                        }, SCAN_PERIOD);

                        scanner.startScan(getScanCallback(subscriber));
                    } else {
                        Log.e(TAG, "BluetoothLeScanner is null");
                        subscriber.onError(new NullPointerException("BluetoothLeScanner is null"));
                    }
                } else {
                    Log.e(TAG, "BluetoothAdapter is null");
                    subscriber.onError(new NullPointerException("BluetoothLeScanner is null"));
                }
            }
        });
    }

    /**
     * Stops scanning for devices
     *
     * @return An Observable which emits ScanResult
     */
    public Observable<ScanResult> stopScan() {
        return Observable.create(new ObservableOnSubscribe<ScanResult>() {
            @Override
            public void subscribe(final ObservableEmitter<ScanResult> subscriber) throws Exception {
                BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();
                if (adapter != null) {
                    // Esta forma me implementar la API 21 (en lugar de la 19)
                    final BluetoothLeScanner scanner = adapter.getBluetoothLeScanner();
                    if (scanner != null) {
                        scanner.stopScan(getScanCallback(subscriber));
                    } else {
                        Log.e(TAG, "BluetoothLeScanner is null");
                        subscriber.onError(new NullPointerException("BluetoothLeScanner is null"));
                    }
                } else {
                    Log.e(TAG, "BluetoothAdapter is null");
                    subscriber.onError(new NullPointerException("BluetoothLeScanner is null"));
                }
            }
        });
    }

    /**
     * Creates {@link ScanCallback} instance
     *
     * @param subscriber Subscriber
     * @return ScanCallback instance
     */
    private ScanCallback getScanCallback(final ObservableEmitter<? super ScanResult> subscriber) {
        return new ScanCallback() {
            @Override
            public void onScanFailed(int errorCode) {
                subscriber.onError(new Exception("Scan failed, error code " + errorCode));
            }

            @Override
            public void onScanResult(int callbackType, ScanResult result) {
                subscriber.onNext(result);
            }
        };
    }

    /**
     * Starts connection process to the device
     *
     * @param device Device to connect
     */
    public Observable<Boolean> connect(final BluetoothDevice device) {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                connectionSubject.subscribe(new ObserverWrapper<>(subscriber));
                bluetoothIO.connect(context, device);
            }
        });
    }

    /**
     * Gets connected device
     *
     * @return Connected device or null, if device is not connected
     */
    public BluetoothDevice getDevice() {
        return bluetoothIO.getConnectedDevice();
    }


    /**
     * Executes device pairing
     */
    public Observable<Boolean> pair() {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                pairSubject.subscribe(new ObserverWrapper<>(subscriber));
            }
        });
    }

    /**
     * Enables fetching notifications
     */
    public Observable<Boolean> enableFetchingNotifications() {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                fetchDescriptorSubject.subscribe(new ObserverWrapper<>(subscriber));
            }
        });
    }

    /**
     * Enables Char PhyActivity notifications
     */
    public Observable<Boolean> enableCharActivityNotifications() {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                charActivityDescriptorSubject.subscribe(new ObserverWrapper<>(subscriber));
            }
        });
    }

    public Observable<Boolean> setTimeActivity() {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                setTimeDataSubject.subscribe(new ObserverWrapper<>(subscriber));

                Calendar cal = Calendar.getInstance();
                byte[] dateInBytes = calendarToRawBytes(cal);
                byte[] timezone = {0x00, 0x08};
                dateInBytes = ArrayUtils.addAll(dateInBytes, timezone);

                Log.d("DATE TO SET: ", String.valueOf(Arrays.toString(dateInBytes)));

                bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_CURRENT_TIME, dateInBytes);
            }
        });
    }

    public Observable<Boolean> startFetchingActivity(final Date lastRead) {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                startFetchingActivitySubject.subscribe(new ObserverWrapper<>(subscriber));

                byte[] dateInBytes = converseDateToByte(lastRead);

                Log.d("VALUES -> ", String.valueOf(Arrays.toString(dateInBytes)));

                byte[] rqLastPck = ArrayUtils.addAll(Protocol.FETCH_1_ST, dateInBytes);
                byte[] rqLastPckEnd = ArrayUtils.addAll(rqLastPck, Protocol.FETCH_1_END);

                bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_FETCH, rqLastPckEnd);
            }
        });
    }

    public byte[] converseDateToByte(Date date) {
        Calendar cal = Calendar.getInstance();
        cal.setTimeInMillis(date.getTime());
        int year = cal.get(Calendar.YEAR);
        int month = cal.get(Calendar.MONTH) + 1;
        int day = cal.get(Calendar.DAY_OF_MONTH);
        int hour = cal.get(Calendar.HOUR_OF_DAY);
        int min = cal.get(Calendar.MINUTE);

        ByteBuffer yearBytes = ByteBuffer.allocate(2).order(ByteOrder.LITTLE_ENDIAN).putShort((short) year);
        ByteBuffer monthBytes = ByteBuffer.allocate(1).order(ByteOrder.LITTLE_ENDIAN).put((byte) month);
        ByteBuffer dayBytes = ByteBuffer.allocate(1).order(ByteOrder.LITTLE_ENDIAN).put((byte) day);
        ByteBuffer hourBytes = ByteBuffer.allocate(1).order(ByteOrder.LITTLE_ENDIAN).put((byte) hour);
        ByteBuffer minBytes = ByteBuffer.allocate(1).order(ByteOrder.LITTLE_ENDIAN).put((byte) min);

        byte[] dateInBytes = {yearBytes.get(0), yearBytes.get(1), monthBytes.get(0), dayBytes.get(0),
                hourBytes.get(0), minBytes.get(0)};

        return dateInBytes;
    }

    public Observable<Boolean> fetchingPastData() {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                fetchingPastDataSubject.subscribe(new ObserverWrapper<>(subscriber));
            }
        });
    }

    public Observable<Boolean> measuringHeartRate() {
        return Observable.create(new ObservableOnSubscribe<Boolean>() {
            @Override
            public void subscribe(ObservableEmitter<Boolean> subscriber) throws Exception {
                setHeartRateMeasure.subscribe(new ObserverWrapper<>(subscriber));
                bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_HEARTRATE, Profile.UUID_CHAR_HEARTRATE, Protocol.COMMAND_SET_PERIODIC_HR_MEASUREMENT_INTERVAL);

            }
        });
    }

    /**
     * Sets pair notification listener
     *
     * @param listener Listener
     */
    public void setPairingNotifyListener(NotifyListener listener) throws InterruptedException {
        bluetoothIO.setNotifyListener(Profile.UUID_SERVICE_MILI, Profile.UUID_CHAR_PAIR, listener);
    }

    /**
     * Sets fetch notification listener
     *
     * @param listener Listener
     */
    public void setFetchingNotifyListener(NotifyListener listener) throws InterruptedException {
        bluetoothIO.setNotifyListener(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_FETCH, listener);
    }

    /**
     * Sets char activity notification listener
     *
     * @param listener Listener
     */
    public void setCharActivityNotifyListener(NotifyListener listener) throws InterruptedException {
        bluetoothIO.setNotifyListener(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_ACTIVITY_DATA, listener);
    }

    /**
     * Sets set Time activity notification listener
     *
     * @param listener Listener
     */
    public void setTimeActivityNotifyListener(NotifyListener listener) throws InterruptedException {
        bluetoothIO.setNotifyListener(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_CURRENT_TIME, listener);
    }

    /**
     * Sets start fetching activity notification listener
     *
     * @param listener Listener
     */
    public void setHeartRateMeasureNotifyListener(NotifyListener listener) throws InterruptedException {
        bluetoothIO.setNotifyListener(Profile.UUID_SERVICE_HEARTRATE, Profile.UUID_CHAR_HEARTRATE, listener);
    }

    /**
     * Notify for connection results
     *
     * @param result True, if connected. False if disconnected
     */
    private void notifyConnectionResult(boolean result) {
        Log.d("CONNECTION RESULT: ", String.valueOf(result));
        connectionSubject.onNext(result);
//        connectionSubject.onComplete();
//
//        // create new connection subject
//        connectionSubject = PublishSubject.create();
    }

    /**
     * Sets fetching past data listener
     *
     * @param listener Listener
     */
    public void setFetchingPastDataListener(NotifyListener listener) throws InterruptedException {
        bluetoothIO.setNotifyListener(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_ACTIVITY_DATA, listener);
        Log.d("LISTENER FETCH", "SETTED LISTENER");
    }

    @Override
    public void onConnectionEstablished() {
        notifyConnectionResult(true);
    }

    @Override
    public void onDisconnected() {
        notifyConnectionResult(false);
    }

    @Override
    public void onResult(BluetoothGattCharacteristic characteristic) {
        UUID serviceId = characteristic.getService().getUuid();
        UUID characteristicId = characteristic.getUuid();

        // AUTH SERVICE
        if (serviceId.equals(Profile.UUID_SERVICE_MILI)) {
            // PAIRING
            if (characteristicId.equals(Profile.UUID_CHAR_PAIR)) {

                if (pairRequested) { // After enabling pair notifications - write: {0x01,0x08, 128 default key}
                    if (miBandKey[0] == 0x00) {
                        bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_MILI, Profile.UUID_CHAR_PAIR, Protocol.PAIR);
                        pairRequested = false;
                    } else {
                        bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_MILI, Profile.UUID_CHAR_PAIR, Protocol.PAIR_2);
                        pairRequested = false;
                    }
                }
                // Notification received: {0x10,0x01,0x01} -> successfully first pairing phase
                else if (characteristic.getValue().length == 3 && characteristic.getValue()[0] == 16 && characteristic.getValue()[1] == 1 && characteristic.getValue()[2] == 1) {
                    Log.d(TAG, "Pair result " + Arrays.toString(characteristic.getValue()) + " - length: " + characteristic.getValue().length);
                    // Write demanding a device's generated random key {0x02,0x08}

                    bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_MILI, Profile.UUID_CHAR_PAIR, Protocol.PAIR_2);

                    // Notification received: {0x10,0x02,0x01, 16 bytes of device secret key} -> successfully second pairing phase
                } else if (characteristic.getValue().length == 19 && characteristic.getValue()[0] == 16 && characteristic.getValue()[1] == 2 && characteristic.getValue()[2] == 1) {
                    try {
                        if (miBandKey[0] == 0x00) {
                            byte[] tmpValue = Arrays.copyOfRange(characteristic.getValue(), 3, 19);
                            Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
                            SecretKeySpec key = new SecretKeySpec(ArrayUtils.subarray(Protocol.PAIR, 2, Protocol.PAIR.length), "AES");
                            cipher.init(Cipher.ENCRYPT_MODE, key);
                            byte[] bytes = cipher.doFinal(tmpValue);
                            byte[] rq = ArrayUtils.addAll(new byte[]{0x03, 0x00}, bytes);

                            // Write to the characteristic: {0x03, 0x08, (encrypted generated key)}”
                            bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_MILI, Profile.UUID_CHAR_PAIR, rq);
                            miBandKey = tmpValue;
                            Log.d("Key to write: ", String.valueOf(rq));

//                          bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_CURRENT_TIME, rq);
                        } else {
                            byte[] tmpValue = Arrays.copyOfRange(characteristic.getValue(), 3, 19);
                            Cipher cipher = Cipher.getInstance("AES/ECB/NoPadding");
                            SecretKeySpec key = new SecretKeySpec(ArrayUtils.subarray(Protocol.PAIR, 2, Protocol.PAIR.length), "AES");
                            cipher.init(Cipher.ENCRYPT_MODE, key);
                            byte[] bytes = cipher.doFinal(tmpValue);
                            byte[] rq = ArrayUtils.addAll(new byte[]{0x03, 0x00}, bytes);

                            bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_MILI, Profile.UUID_CHAR_PAIR, rq);

                        }
                    } catch (Exception e) {
                        pairSubject.onError(e);
                        pairSubject = PublishSubject.create();
                        e.printStackTrace();
                    }

                }
                // Notification received: {0x10,0x11,0x01} -> successfully third pairing phase
                else if (characteristic.getValue().length == 3 && characteristic.getValue()[0] == 16 && characteristic.getValue()[1] == 3 && characteristic.getValue()[2] == 1) {

                    pairSubject.onNext(true);
                    pairSubject.onComplete();
                    pairSubject = PublishSubject.create();
                } else if (characteristic.getValue().length == 3 && characteristic.getValue()[0] == 16 && characteristic.getValue()[1] == 1 && characteristic.getValue()[2] != 1){
                    // There is an error while try to pairing
                    Log.d("ERROR", "FAILED PAIRING");
                    pairSubject.onNext(false);


                }
            }

        }

        // FETCHING SERVICE
        if (serviceId.equals(Profile.UUID_SERVICE_FETCH)) {
            if (characteristicId.equals(Profile.UUID_CHAR_FETCH) && characteristic.getValue() == null) {
                // Reset physical activity arraylist, time is managed by PhyActivityManager

                Log.d("ENABLE", "FETCH");
                fetchDescriptorSubject.onNext(true);
                fetchDescriptorSubject.onComplete();
                fetchDescriptorSubject = PublishSubject.create();
            } else if (characteristicId.equals(Profile.UUID_CHAR_ACTIVITY_DATA) && characteristic.getValue() == null) {
                Log.d("ENABLE", "CHAR_ACTIVITY");
                charActivityDescriptorSubject.onNext(true);
                charActivityDescriptorSubject.onComplete();
                charActivityDescriptorSubject = PublishSubject.create();

            } else if (characteristicId.equals(Profile.UUID_CHAR_FETCH) && characteristic.getValue() != null &&
                    (characteristic.getValue()[0] == 16) && (characteristic.getValue()[1] == 1) && (characteristic.getValue()[2] == 1)) {
                Log.d("START_FETCH", "FETCH SECOND STEP");

                // ANALIZANDO LO QUE DEVUELVE...
                byte[] bCharacteristicValue = characteristic.getValue();
                byte[] bYear = ArrayUtils.subarray(bCharacteristicValue, 7, 9);
                ByteBuffer buf = ByteBuffer.wrap(bYear);
                buf.order(ByteOrder.LITTLE_ENDIAN);

                bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_FETCH, Protocol.FETCH_PAST_DATA);
                startFetchingActivitySubject.onNext(true);
                startFetchingActivitySubject.onComplete();
                startFetchingActivitySubject = PublishSubject.create();

            } else if (characteristicId.equals(Profile.UUID_CHAR_FETCH) && characteristic.getValue() != null &&
                    (characteristic.getValue()[0] == 16) && (characteristic.getValue()[1] == 2) && (characteristic.getValue()[2] == 1)) {
                Log.d("RECOVER PAST DATA", "CHAR_ACTIVITY LAST PACKAGE RECEIVED");
                bluetoothIO.writeCharacteristic(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_FETCH, Protocol.FETCH_FLUSH_DATA);
                fetchingPastDataSubject.onNext(true);
                fetchingPastDataSubject.onComplete();
                fetchingPastDataSubject = PublishSubject.create();

            } else if (characteristicId.equals(Profile.UUID_CHAR_ACTIVITY_DATA) && characteristic.getValue() != null && characteristic.getValue().length > 3) {
                // FETCHING PAST DATA ULTIMO PAQUETE QUE NO CONTIENE TODOS LOS DATOS
                Log.d("RECOVER PAST DATA", "CHAR_ACTIVITY LAST PACKAGE INCOMPLETE");
                byte[] bCharacteristicValue = characteristic.getValue();

            } else if (characteristicId.equals(Profile.UUID_CHAR_CURRENT_TIME)) {

                Log.d("CURRENT_TIME", String.valueOf(Arrays.toString(characteristic.getValue())));
                setTimeDataSubject.onNext(true);
                setTimeDataSubject.onComplete();
                setTimeDataSubject = PublishSubject.create();

            } else if (characteristicId.equals(Profile.UUID_CHAR_FETCH) && characteristic.getValue() != null &&
                        (characteristic.getValue()[0] == 16) && (characteristic.getValue()[2] == 4)){
                Log.d("ERROR", "NOT DATA AVAILABLE");
                fetchingPastDataSubject.onNext(false);
                fetchingPastDataSubject.onComplete();
                fetchingPastDataSubject = PublishSubject.create();

            }

        }

        // HEARTRATE SERVICE
        if (serviceId.equals(Profile.UUID_SERVICE_HEARTRATE)){
            if (characteristicId.equals(Profile.UUID_SERVICE_HEARTRATE) && characteristic.getValue() == null){
                Log.d("HEAR_RATE", "NULL");

            }else{
                Log.d("HEAR_RATE", String.valueOf(characteristic.getValue().toString()));
                setHeartRateMeasure.onNext(true);
                setHeartRateMeasure.onComplete();
                setHeartRateMeasure = PublishSubject.create();
            }
        }
    }


    @Override
    public void onResultRssi(int rssi) {

    }

    @Override
    public void onFail(UUID serviceId, UUID characteristicId, String msg) {
        if (serviceId.equals(Profile.UUID_SERVICE_MILI)) {
            // Pair
            if (characteristicId.equals(Profile.UUID_CHAR_PAIR)) {
                Log.d(TAG, "Pair failed " + msg);
                pairSubject.onError(new Exception("Pairing failed"));
                pairSubject = PublishSubject.create();
            }
        }
    }

    @Override
    public void onFail(int errorCode, String msg) {
        Log.d(TAG, String.format("onFail: errorCode %d, message %s", errorCode, msg));
        switch (errorCode) {
            case BluetoothIO.ERROR_CONNECTION_FAILED:
                connectionSubject.onError(new Exception("Establishing connection failed"));
                connectionSubject = PublishSubject.create();
                break;
        }
    }

    public boolean getPairRequested() {
        return pairRequested;
    }

    // No eliminar bajo ningún concepto o dejará de funcionar
    public static byte[] calendarToRawBytes(Calendar timestamp) {
        // MiBand2:
        // year,year,month,dayofmonth,hour,minute,second,dayofweek,0,0,tz

        byte[] year = fromUint16(timestamp.get(Calendar.YEAR));
        return new byte[]{
                year[0],
                year[1],
                fromUint8(timestamp.get(Calendar.MONTH) + 1),
                fromUint8(timestamp.get(Calendar.DATE)),
                fromUint8(timestamp.get(Calendar.HOUR_OF_DAY)),
                fromUint8(timestamp.get(Calendar.MINUTE)),
                fromUint8(timestamp.get(Calendar.SECOND)),
                dayOfWeekToRawBytes(timestamp),
                0, // fractions256 (not set)
                // 0 (DST offset?) Mi2
                // k (tz) Mi2
        };
    }

    public static byte[] fromUint16(int value) {
        return new byte[]{
                (byte) (value & 0xff),
                (byte) ((value >> 8) & 0xff),
        };
    }

    public static byte fromUint8(int value) {
        return (byte) (value & 0xff);
    }

    private static byte dayOfWeekToRawBytes(Calendar cal) {
        int calValue = cal.get(Calendar.DAY_OF_WEEK);
        switch (calValue) {
            case Calendar.SUNDAY:
                return 7;
            default:
                return (byte) (calValue - 1);
        }
    }

    public void setPairRequested(boolean pairRequested) {
        this.pairRequested = pairRequested;
    }

    public byte[] getKey(){
        return this.miBandKey;
    }

    public BluetoothIO getBluetoothIO() {
        return bluetoothIO;
    }
}
