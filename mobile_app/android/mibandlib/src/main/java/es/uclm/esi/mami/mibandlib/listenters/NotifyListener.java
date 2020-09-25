package es.uclm.esi.mami.mibandlib.listenters;

/**
 * Listener for data notifications
 */

public interface NotifyListener {

    /**
     * Called when new data arrived
     *
     * @param data Binary data
     */
    void onNotify(byte[] data);
}
