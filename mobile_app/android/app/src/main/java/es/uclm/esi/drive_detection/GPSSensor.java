package es.uclm.esi.drive_detection;
import android.content.Context;
import android.location.Location;
import android.location.LocationListener;
import android.os.Bundle;
import android.os.Handler;

import com.google.android.gms.location.FusedLocationProviderClient;
import com.google.android.gms.location.LocationCallback;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.location.LocationResult;
import com.google.android.gms.location.LocationServices;

import java.util.ArrayList;

/**
 * This is also a singleton class for collecting the location data and
 * providing this data to the EventProcessorThread class for further event
 * detection processing. It uses the GoogleApiClient class to connect to the fused
 * location API to get the location data.
 *
 * Collects the location every second.
 */
public class GPSSensor implements LocationListener {
    private ArrayList<Location> mLocationDataList = new
            ArrayList<Location>();
    private static GPSSensor gpsSensor;
    private LocationRequest mLocationRequest;
    private FusedLocationProviderClient mFusedLocationClient;
    private LocationCallback mLocationCallback;

    public static GPSSensor getInstance() {
        if (gpsSensor == null) {
            gpsSensor = new GPSSensor();
        }
        return gpsSensor;
    }

    public void register(Handler mHandler, Context context) {
        mLocationRequest = LocationRequest.create();
        mLocationRequest.setPriority(LocationRequest.PRIORITY_HIGH_ACCURACY);
        mLocationRequest.setInterval(Constants.GPS_INTERVAL);
        mLocationRequest.setFastestInterval(Constants.GPS_INTERVAL);
        mFusedLocationClient = LocationServices.getFusedLocationProviderClient(context);

        mLocationCallback = new LocationCallback() {
            public void onLocationResult(LocationResult locationResult) {
                if (locationResult != null) {
                    Location location = locationResult.getLocations().get(0);
                    mLocationDataList.add(location);
                }
            };
        };

        mFusedLocationClient.requestLocationUpdates(mLocationRequest, mLocationCallback, null);
    }

    public void unregister() {
        //REVISAR CÓMO DESCONECTAR
        if(mFusedLocationClient != null){
            mFusedLocationClient.removeLocationUpdates(mLocationCallback);
        }
    }


    public ArrayList<Location> getGPSList()
    {
        return mLocationDataList;
    }

    @Override
    public void onLocationChanged(Location location) {
        mLocationDataList.add(location);
    }

    @Override
    public void onStatusChanged(String s, int i, Bundle bundle) {}

    @Override
    public void onProviderEnabled(String s) {}

    @Override
    public void onProviderDisabled(String s) {}
}
