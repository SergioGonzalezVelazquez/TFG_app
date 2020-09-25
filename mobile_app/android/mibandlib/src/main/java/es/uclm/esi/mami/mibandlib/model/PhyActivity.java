package es.uclm.esi.mami.mibandlib.model;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.Map;
import java.util.Objects;

public class PhyActivity {

    private int steps;
    private int heartRate;
    private int kindRaw;
    private int intensity;
    private int counterPackage;
    private int intraCounterPackage;
    private Timestamp activityTimestamp;


    public PhyActivity(int steps, int heartRate, int kindRaw, int intensity, int counterPackage, int intraCounterPackage) {
        this.steps = steps;
        this.heartRate = heartRate;
        this.kindRaw = kindRaw;
        this.intensity = intensity;
        this.counterPackage = counterPackage;
        this.intraCounterPackage = intraCounterPackage;
    }

    public Map<String, Object> toMap() {
        Map<String, Object> map = new HashMap<>();
        map.put("heartRate", this.heartRate);
        map.put("intensity", this.intensity);
        map.put("timestamp", this.activityTimestamp);
        return map;
    }

    public int getSteps() {
        return steps;
    }

    public void setSteps(int steps) {
        this.steps = steps;
    }

    public int getHeartRate() {
        return heartRate;
    }

    public void setHeartRate(int heartRate) {
        this.heartRate = heartRate;
    }

    public int getKindRaw() {
        return kindRaw;
    }

    public void setKindRaw(int kindRaw) {
        this.kindRaw = kindRaw;
    }

    public int getIntensity() {
        return intensity;
    }

    public void setIntensity(int intensity) {
        this.intensity = intensity;
    }

    public Timestamp getActivityTimestamp() {
        return activityTimestamp;
    }

    public void setActivityTimestamp(Timestamp activityTimestamp) {
        this.activityTimestamp = activityTimestamp;
    }

    public int getCounterPackage() {
        return counterPackage;
    }

    public void setCounterPackage(int counterPackage) {
        this.counterPackage = counterPackage;
    }

    public int getIntraCounterPackage() {
        return intraCounterPackage;
    }

    public void setIntraCounterPackage(int intraCounterPackage) {
        this.intraCounterPackage = intraCounterPackage;
    }

    @Override
    public String toString() {
        return "PhyActivity{" +
                "Steps: " + steps +
                ", heartRate: " + heartRate +
                ", kindRaw: " + kindRaw +
                ", intensity: " + intensity +
                ", activityTimestamp: " + activityTimestamp.toString() +
                '}';
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof PhyActivity)) return false;
        PhyActivity phyActivity = (PhyActivity) o;
        return getSteps() == phyActivity.getSteps() &&
                getHeartRate() == phyActivity.getHeartRate() &&
                getKindRaw() == phyActivity.getKindRaw() &&
                getIntensity() == phyActivity.getIntensity() &&
                Objects.equals(getActivityTimestamp(), phyActivity.getActivityTimestamp());
    }

    @Override
    public int hashCode() {
        return Objects.hash(getSteps(), getHeartRate(), getKindRaw(), getIntensity(), getActivityTimestamp());
    }

}
