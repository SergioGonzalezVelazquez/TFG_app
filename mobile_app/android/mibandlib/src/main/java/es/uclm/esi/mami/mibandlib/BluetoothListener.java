package es.uclm.esi.mami.mibandlib;

import android.bluetooth.BluetoothGattCharacteristic;
import android.bluetooth.BluetoothGattDescriptor;

import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.util.UUID;

import javax.crypto.NoSuchPaddingException;


/**
 * Bluetooth listener
 */
public interface BluetoothListener {

    /**
     * Called on established connection
     */
    void onConnectionEstablished();

    /**
     * Called on disconnection
     */
    void onDisconnected();

    /**
     * Called on getting successful result
     *
     * @param data Characteristic data
     */
    void onResult(BluetoothGattCharacteristic data) throws NoSuchPaddingException, NoSuchAlgorithmException, InvalidKeyException;

    /**
     * Called on getting successful result of RSSI strength
     *
     * @param rssi RSSI strength
     */
    void onResultRssi(int rssi);

    /**
     * Called on fail from service
     *
     * @param serviceUUID      Service UUID
     * @param characteristicId Characteristic ID
     * @param msg              Error message
     */
    void onFail(UUID serviceUUID, UUID characteristicId, String msg);

    /**
     * Called on fail from Bluetooth IO
     *
     * @param errorCode Error code
     * @param msg       Error message
     */
    void onFail(int errorCode, String msg);
}
