package es.uclm.esi.mami.emovi.behaviour;

import android.bluetooth.BluetoothAdapter;
import android.bluetooth.BluetoothDevice;
import android.content.Context;
import android.content.IntentFilter;
import android.util.Log;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Date;

import es.uclm.esi.mami.doctorautomaton.MooreMachine;
import es.uclm.esi.mami.doctorautomaton.Transition;
import es.uclm.esi.mami.emovi.managers.DatabaseManager;
import es.uclm.esi.mami.emovi.managers.InputOutputManagement;
import es.uclm.esi.mami.emovi.managers.MiBandServiceManager;
import es.uclm.esi.mami.emovi.managers.PhyActivityManager;
import es.uclm.esi.mami.mibandlib.MiBand;
import es.uclm.esi.mami.mibandlib.listenters.NotifyListener;
import es.uclm.esi.mami.mibandlib.model.PhyActivity;
import es.uclm.esi.mami.mibandlib.model.Profile;

public class AutomatonMiBandManager extends MooreMachine {
    /**
     * Create a blank MooreMachine with the given name (which is arbitrary).
     *
     * @param name
     */

    private MiBand mibandToManage;
    private InputOutputManagement inputOutputManager;
    private PhyActivityManager phyActivityManager;
    private MiBandServiceManager miBandServiceManager;
    private ArrayList<PhyActivity> recollectedActivities;
    private int counterPackage;
    private DatabaseManager databaseManager;

    private final String TAG = "AutomatonMiBandManager";

    public AutomatonMiBandManager(String name, MiBandServiceManager miBandServiceManager, Context context) {
        super(name);
        Log.w(TAG, "AutomatonMiBandManager constructor");
        this.miBandServiceManager = miBandServiceManager;
        this.mibandToManage = miBandServiceManager.getMiBand();
        this.inputOutputManager = miBandServiceManager.getInputOutputManager();
        this.phyActivityManager = miBandServiceManager.getPhyActivityManager();
        this.recollectedActivities = new ArrayList<>();
        this.databaseManager = new DatabaseManager(context);

    }

    public void automatonInit(){
        // ACCIONES DE ENTRADA DE LOS ESTADOS
        Runnable entr_state_disc = () -> {
            Log.w("STATE_DISC", "Entrando en estado desconectado");
        };

        Runnable entr_state_con = () -> {
            BluetoothAdapter adapter = BluetoothAdapter.getDefaultAdapter();

            Log.w("STATE_CON", "Entrando en estado conectado");
            BluetoothDevice device_to_connect = adapter.getRemoteDevice(miBandServiceManager.getMacAddress());
//                    BluetoothDevice device = devices.get("MI Band 2|EF:D0:57:A5:4D:36");

            mibandToManage.connect(device_to_connect).subscribe(miBandServiceManager.handleConnectResult(), miBandServiceManager.handleError());
        };

        Runnable entr_state_pair = () -> {
            Log.w("STATE_PAIR", "Entrando en estado de pairing");

            if(!miBandServiceManager.isActuallyPaired()){
                Log.w("STATE_PAIR", "NOT miBandServiceManager.isActuallyPaired()");
                mibandToManage.pair().subscribe(miBandServiceManager.handlePairResult(), miBandServiceManager.handleError());


                try {
                    mibandToManage.setPairingNotifyListener(new NotifyListener() {
                        @Override
                        public void onNotify(byte[] data) {
                            Log.w("PairingNotifyListener:", Arrays.toString(data));
                        }
                    });
                } catch (InterruptedException e) {
                    e.printStackTrace();
                }
            } else {
                Log.w("STATE_PAIR", "miBandServiceManager.isActuallyPaired()");
                try {
                    miBandServiceManager.continueWithPairedDevice();
                } catch (InterruptedException e){
                    Log.w("Exception OCCURRED", e.getMessage());

                }
            }
        };
        /*
        Runnable entr_state_scan = () -> {
            Log.d("STATE_SCAN", "Entrando en estado de escaneo");
            Log.d("CLASS: ", String.valueOf(this.getClass()));

            IntentFilter intentFilter = new IntentFilter();
            intentFilter.addAction("STOP_SCANNING");

            Log.i("MainActivity", "Scanning started...");

            Log.d("STATE_SCAN", "Iniciando escaneo");

            mibandToManage.startScan().subscribe(miBandServiceManager.handleScanResult(), miBandServiceManager.handleError());

        };
        */

        Runnable entr_state_heart = () -> {
            Log.w("STATE_HEART", "Entrando en estado de heart rate measurement");

            mibandToManage.measuringHeartRate().subscribe(miBandServiceManager.handleHeartRateMeasurementResult(), miBandServiceManager.handleError());

//          Esto esta comentando, porque esta caracteristica no notifica nada.
//            try {
//                mibandToManage.setHeartRateMeasureNotifyListener(new NotifyListener() {
//                    @Override
//                    public void onNotify(byte[] data) {
//                        Log.w("HeartRateListener:", Arrays.toString(data));
//
//                    }
//                });
//            } catch (InterruptedException e) {
//                e.printStackTrace();
//            }

        };

        Runnable entr_state_time = () -> {
            Log.w("STATE_TIME", "Entrando en estado de set timing");

            mibandToManage.setTimeActivity().subscribe(miBandServiceManager.handleSetTimeResult(), miBandServiceManager.handleError());
            try {
                mibandToManage.setTimeActivityNotifyListener(new NotifyListener() {
                    @Override
                    public void onNotify(byte[] data) {
                        Log.w("TimingListener:", Arrays.toString(data));

                    }
                });
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        };

        Runnable entr_state_fetch = () -> {
            Log.w("STATE_FETCH", "Entrando en estado de fetching");

            mibandToManage.enableFetchingNotifications().subscribe(miBandServiceManager.handleEnableFetchingResult(), miBandServiceManager.handleError());

            try {
                mibandToManage.setFetchingNotifyListener(new NotifyListener() {
                    @Override
                    public void onNotify(byte[] data) {
                        Log.w("FetchingNotifyListener:", Arrays.toString(data));

                        if (data.length == 3 && data[0] == 16 && data[1] == 3 && data[2] == 1){
                            Log.w("STATE_FETCH", "if: " + recollectedActivities.size());
                            if (recollectedActivities.size() > 0) {
                                // Agregar actividades a registro y actualizar ultima fecha de recoleccion
                                phyActivityManager.addActivitiesToRegister(recollectedActivities);
                                Date newLastRead = phyActivityManager.getLastSamplePicked();
                                inputOutputManager.writeLastDateLecture(newLastRead);
                                recollectedActivities = new ArrayList<>();

                            }
                            miBandServiceManager.continueWithFetchedDevice();

                        }   else if(data.length == 3 && data[0] == 16 && data[1] == 2 && data[2] == 1){
                            Log.w("STATE_FETCH", "else if: setActuallyEnableFetchAndCharAct " );
                            miBandServiceManager.setActuallyEnableFetchAndCharAct(true);
                        } else{
                            Log.w("FETCH_RESULT", "else: "  + String.valueOf(data));
                        }


                    }
                });
            } catch (InterruptedException e) {
                e.printStackTrace();
            }

        };

        Runnable entr_state_char_act = () -> {
            Log.w("STATE_CHAR_ACT", "Entrando en estado de char_act");
            counterPackage = 0;
            mibandToManage.enableCharActivityNotifications().subscribe(miBandServiceManager.handleEnableCharActivityResult(), miBandServiceManager.handleError());

            try {
                mibandToManage.setCharActivityNotifyListener(new NotifyListener() {
                    @Override
                    public void onNotify(byte[] data) {
                        Log.w("StartCharActNotif:", Arrays.toString(data));
                        if (data.length == 17){
                            counterPackage += 1;
                            int intraPckCounter = 0;
                            for (int i = 1; i < data.length; i += 4) {
                                intraPckCounter += 1;
                                // Como al final no me he aclarado con algunos codigos de los que te devuelve, he decidido probar a reconstruir mi rutina de esta mañana para dar sentido a los
                                // codigos de categoria
                                // 112 -> Sueño ligero
                                // 121 -> Sueño profundo
                                // 80 -> Estar parado sentado
                                // 1 -> Andar
                                // 16 -> Bajar escaleras
                                // 17 -> Subir escaleras
                                // 96 -> Estar parado de pie

                                int kindActivity = data[i] & 0xFF;
                                int intensity = data[i + 1] & 0xFF;
                                int steps = data[i + 2] & 0xFF;
                                int heartRate = data[i + 3] & 0xFF;

                                recollectedActivities.add(new PhyActivity(steps, heartRate, kindActivity, intensity, counterPackage, intraPckCounter));

                            }
                        }

                    }
                });
            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        };

        Runnable entr_state_st_rec = () -> {
            Log.w("STATE_ST_REC", "Entrando en estado de starting receiving");

            Date lastReadDate = null;
            try {

                lastReadDate = inputOutputManager.readLastDateLectureDate();
                phyActivityManager.setLastSamplePicked(lastReadDate);

                mibandToManage.startFetchingActivity(lastReadDate).subscribe(miBandServiceManager.handleStartFetchingActivityResult(), miBandServiceManager.handleError());

            } catch (Exception e) {
                e.printStackTrace();
            }
        };

        Runnable entr_state_rec = () -> {
            Log.w("STATE_REC", "Entrando en estado de receiving");

            try {
                mibandToManage.fetchingPastData().subscribe(miBandServiceManager.handleFetchingPastDataResult(), miBandServiceManager.handleError());

            } catch (Exception e) {
                e.printStackTrace();
            }
        };

        Runnable entr_state_wait = () -> {
            Log.w("STATE_WAIT", "Entrando en estado de wait");
            try {
                Thread.sleep(60000);

            } catch (InterruptedException e) {
                e.printStackTrace();
            }
        };

        Runnable entr_state_send = () -> {
            Log.w("STATE_SEND", "Entrando en estado de send");
            Log.w("SEND", "Enviar movidas (WIP)");
            Log.w("SEND", "tamaño a guardar: " + phyActivityManager.getActivitiesRegister().size());

            ArrayList<PhyActivity> samplesToRemove = new ArrayList<>();
            ArrayList<PhyActivity> phyActivities = phyActivityManager.getActivitiesRegister();

            for (PhyActivity phyActivity: phyActivityManager.getActivitiesRegister()){
                Log.w("PHYACT_SEND", phyActivity.toString());
                databaseManager.storePhyActivity(phyActivity);
                samplesToRemove.add(phyActivity);
            }

            for (int i = 0; i < samplesToRemove.size(); i++){
                Log.w("PHYACT_SEND", "Remove " + i);
                PhyActivity phyActivity = samplesToRemove.get(i);
                phyActivityManager.removeRegisterActivity(phyActivity);
            }


            Log.w("SEND", "tamaño después de guardar: " + phyActivityManager.getActivitiesRegister().size());
        };

        // ACCIONES DE SALIDA DE LOS ESTADOS
        Runnable sal_state_disc = () -> {
            Log.w("SAL_STATE", "Saliendo en estado desconectado");
        };

        Runnable sal_state_con = () -> {
            Log.w("SAL_STATE","Saliendo en estado conectado");
        };

        Runnable sal_state_pair = () -> {
            Log.w("SAL_STATE","Saliendo en estado de pairing");

        };

        Runnable sal_state_heart = () -> {
            Log.w("SAL_HEART","Saliendo en estado de heart");

        };

        Runnable sal_state_time = () -> {
            Log.w("SAL_TIME","Saliendo en estado de time");
//            mibandToManage.getBluetoothIO().removeNotifyListener(Profile.UUID_SERVICE_FETCH, Profile.UUID_CHAR_CURRENT_TIME);

        };

        Runnable sal_state_fetch = () -> {
            Log.w("SAL_STATE","Saliendo en estado de fetching");

        };

        Runnable sal_state_char_act = () -> {
            Log.w("SAL_STATE","Saliendo en estado de char_act");
        };

        Runnable sal_state_st_rec = () -> {
            Log.w("SAL_STATE","Saliendo en estado de starting receiving");

        };

        Runnable sal_state_rec = () -> {
            Log.w("SAL_STATE","Saliendo en estado de receiving");

        };

        Runnable sal_state_wait = () -> {
            Log.w("SAL_STATE","Saliendo en estado de wait");
        };

        Runnable sal_state_send = () -> {
            Log.w("SAL_STATE","Saliendo en estado de send");
        };

        // ACCIONES CUANDO EL ESTADO SEA FINAL
        Runnable final_state_disc = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Disconected");
        };

        Runnable final_state_con = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Connected");
        };

        Runnable final_state_pair = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Pair");
        };

        Runnable final_state_heart = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Heart");
        };

        Runnable final_state_time = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Time");
        };

        Runnable final_state_fetch = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Fetch");
        };

        Runnable final_state_char_act = () -> {
            Log.w("FINAL_STATE","(FINAL) estado char_act");
        };

        Runnable final_state_st_rec = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Starting Receive");
        };

        Runnable final_state_rec = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Receive");
        };

        Runnable final_state_wait = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Wait");
        };

        Runnable final_state_send = () -> {
            Log.w("FINAL_STATE","(FINAL) estado Send");
        };

        // DISC STATE TRANSITIONS
        this.addState("DISC", entr_state_disc, sal_state_disc, final_state_disc);

        Transition disc_to_scan = new Transition("go to scan", "DISC", "SCAN");
        Transition disc_to_con = new Transition("go to con", "DISC", "CON");

        this.addTransition(disc_to_scan);
        this.addTransition(disc_to_con);

//        // SCAN STATE TRANSITIONS
//        this.addState("SCAN", entr_state_scan, sal_state_scan, final_state_scan);
//
//        Transition scan_to_look_at  = new Transition("go to look_at", "SCAN", "LOOK_AT");
//
//        this.addTransition(scan_to_look_at);

        // CON STATE TRANSITIONS
        this.addState("CON", entr_state_con, sal_state_con, final_state_con);

        Transition con_to_pair = new Transition("go to pair", "CON", "PAIR");
        Transition con_to_wait = new Transition("go to wait", "CON", "WAIT");

        this.addTransition(con_to_pair);
        this.addTransition(con_to_wait);

        // PAIR STATE TRANSITIONS
        this.addState("PAIR", entr_state_pair, sal_state_pair, final_state_pair);

        Transition pair_to_fetch = new Transition("go to fetch", "PAIR", "FETCH");
        Transition pair_to_st_rec = new Transition("go to st_rec", "PAIR", "ST_REC");
        Transition pair_to_heart = new Transition("go to heart", "PAIR", "HEART");
        Transition pair_to_wait  = new Transition("go to wait", "PAIR", "WAIT");

        this.addTransition(pair_to_fetch);
        this.addTransition(pair_to_st_rec);
        this.addTransition(pair_to_heart);
        this.addTransition(pair_to_wait);

        // HEART RATE MEASUREMENT CONTROL TRANSITIONS
        this.addState("HEART", entr_state_heart, sal_state_heart, final_state_heart);

        Transition heart_to_time = new Transition("go to time", "HEART", "TIME");

        this.addTransition(heart_to_time);

        // TIME TRANSITIONS
        this.addState("TIME", entr_state_time, sal_state_time, final_state_time);

        Transition time_to_pair = new Transition("go to pair", "TIME", "PAIR");

        this.addTransition(time_to_pair);

        // FETCH STATE TRANSITIONS
        this.addState("FETCH", entr_state_fetch, sal_state_fetch, final_state_fetch);

        Transition fetch_to_char_act    = new Transition("go to char_act", "FETCH", "CHAR_ACT");
        Transition fetch_to_pair        = new Transition("go to pair", "FETCH", "PAIR");
        Transition fetch_to_wait        = new Transition("go to wait", "FETCH", "WAIT");

        this.addTransition(fetch_to_char_act);
        this.addTransition(fetch_to_pair);
        this.addTransition(fetch_to_wait);

        // CHAR_ACT STATE TRANSITIONS
        this.addState("CHAR_ACT", entr_state_char_act, sal_state_char_act, final_state_char_act);

        Transition char_act_to_st_rec    = new Transition("go to st_rec", "CHAR_ACT", "ST_REC");
        Transition char_act_to_wait    = new Transition("go to wait", "CHAR_ACT", "WAIT");

        this.addTransition(char_act_to_st_rec);
        this.addTransition(char_act_to_wait);

        // ST_REC STATE TRANSITIONS
        this.addState("ST_REC", entr_state_st_rec, sal_state_st_rec, final_state_st_rec);

        Transition st_rec_to_rec = new Transition("go to rec", "ST_REC", "REC");
        Transition st_rec_to_wait = new Transition("go to wait", "ST_REC", "WAIT");

        this.addTransition(st_rec_to_rec);
        this.addTransition(st_rec_to_wait);

        // REC STATE TRANSITIONS
        this.addState("REC", entr_state_rec, sal_state_rec, final_state_rec);

        Transition rec_to_pair = new Transition("go to pair", "REC", "PAIR");
        Transition rec_to_wait = new Transition("go to wait", "REC", "WAIT");
        Transition rec_to_send = new Transition("go to send", "REC", "SEND");

        this.addTransition(rec_to_pair);
        this.addTransition(rec_to_wait);
        this.addTransition(rec_to_send);

        // WAIT STATE TRANSITIONS
        this.addState("WAIT", entr_state_wait, sal_state_wait, final_state_wait);

        Transition wait_to_scan = new Transition("go to scan", "WAIT", "SCAN");
        Transition wait_to_con = new Transition("go to con", "WAIT", "CON");
        Transition wait_to_pair = new Transition("go to pair", "WAIT", "PAIR");
        Transition wait_to_st_rec = new Transition("go to st_rec", "WAIT", "ST_REC");

        this.addTransition(wait_to_con);
        this.addTransition(wait_to_st_rec);
        this.addTransition(wait_to_pair);


        this.addState("SEND", entr_state_send, sal_state_send, final_state_send);

        Transition send_to_wait = new Transition("go to wait", "SEND", "WAIT");

        this.addTransition(send_to_wait);

    }
}
