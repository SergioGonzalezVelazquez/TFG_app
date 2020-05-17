package es.uclm.esi.mami.emovi.managers;

import android.content.Context;
import android.util.Log;

import java.io.BufferedReader;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStreamReader;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.Locale;

public class InputOutputManagement {

    private static String FICHERO_KEY = "key.txt";
    private static String FICHERO_LAST_DATE_LECTURE = "lastDateLecture.txt";
    private static String FICHERO_MAC_ADDRESS = "macAddress.txt";

    private static final String DATE_FORMAT = "yyyy-MM-dd HH:mm";
    private static final SimpleDateFormat formatter = new SimpleDateFormat(DATE_FORMAT, Locale.US);

    private Context context;
    private final String TAG = "InputOutputManagement";

    public InputOutputManagement(Context context) {
        this.context = context;
    }

    public void writeKey(byte[] key){
        try {
            FileOutputStream f = context.openFileOutput(FICHERO_KEY,
                    Context.MODE_PRIVATE);
            Log.w("KEY_WRITED:", String.valueOf(Arrays.toString(key)));
            f.write(key);
            f.close();
        } catch (Exception e) {
            Log.e("KEY_WRITING: ", e.getMessage(), e);
        }
    }

    public byte[] readKey() {
        String linea = "";
        try {
            FileInputStream f = context.openFileInput(FICHERO_KEY);
            BufferedReader entrada = new BufferedReader(new InputStreamReader(f));

            linea = entrada.readLine();
            Log.w("KEY_READING", linea);

            f.close();
        } catch (Exception e) {
            Log.w("KEY_READING: ", e.getMessage());
            return new byte[]{0x00};
        }
        return linea.getBytes();
    }

    public Date readLastDateLectureDate() {
        Date lastRead = new Date();
        String linea = "";
        try {
            FileInputStream f = context.openFileInput(FICHERO_LAST_DATE_LECTURE);
            BufferedReader entrada = new BufferedReader(new InputStreamReader(f));

            linea = entrada.readLine();
            Log.w("LAST_DATE_READ_READING", linea);

            f.close();
        } catch (FileNotFoundException e) {
            Log.e("LAST_DATE_READ_READING", e.getMessage());
            writeLastDateLecture(lastRead);
        } catch (IOException e) {
            Log.e("IOException", String.valueOf(e.getStackTrace()));
        }
        if(!linea.equals("")){
            try {
                 lastRead = formatter.parse(linea);

            } catch (ParseException pe){
                Log.e("LAST_DATE_READ_READING", pe.getMessage());
                return lastRead;
            }
        }

        return lastRead;
    }

    public String readLastDateLectureString() {
        String linea = "";
        try {
            FileInputStream f = context.openFileInput(FICHERO_LAST_DATE_LECTURE);
            BufferedReader entrada = new BufferedReader(new InputStreamReader(f));

            linea = entrada.readLine();
            Log.w("LAST_DATE_READ_READING", linea);

            f.close();
        } catch (Exception e) {
            Log.w("LAST_DATE_READ_READING", e.getMessage());
            return linea;
        }

        return linea;
    }


    public void writeLastDateLecture(Date lastDateLecture){
        try {
            FileOutputStream f = context.openFileOutput(FICHERO_LAST_DATE_LECTURE,
                    Context.MODE_PRIVATE);
            byte[] last_read = formatter.format(lastDateLecture).getBytes();
            f.write(last_read);
            Log.w("LAST_DATE_READ_WRITED:", String.valueOf(Arrays.toString(last_read)));
            f.close();

        } catch (Exception e) {
            Log.e("LAST_DATE_READ_WRITING:", e.getMessage(), e);
        }
    }

    public String readMacAddress() {
        Log.w(TAG, "readMacAdress");
        String linea = "";
        try {
            FileInputStream f = context.openFileInput(FICHERO_MAC_ADDRESS);
            BufferedReader entrada = new BufferedReader(new InputStreamReader(f));

            linea = entrada.readLine();
            Log.w(TAG, "MAC_READING: " +  linea);

            f.close();
        } catch (Exception e) {
            Log.e(TAG, "Exception: " + e.getMessage());
            return linea;
        }

        return linea;
    }


    public void writeMacAddress(String macAddress){
        try {
            FileOutputStream f = context.openFileOutput(FICHERO_MAC_ADDRESS,
                    Context.MODE_PRIVATE);
            //f.write(Integer.parseInt(macAddress));
            f.write(macAddress.getBytes());
            Log.w("MAC_WRITED:", String.valueOf(macAddress));
            f.close();

        } catch (Exception e) {
            Log.e("MAC_WRITING: ", e.getMessage(), e);
        }
    }
}
