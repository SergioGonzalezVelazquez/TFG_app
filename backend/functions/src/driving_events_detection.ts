import * as functions from 'firebase-functions';
import getDistance from 'geolib/es/getDistance';
import nodeGeocoder from 'node-geocoder';
import * as admin from 'firebase-admin';

const drivingActivityRef = 'driving_activity/{userId}/user_driving_activity/{driveId}';
const SUCCESS_CODE = 0;

const geocoderOptions = {
    provider: 'openstreetmap'
}

export const onCreateDrivingActivity = functions.firestore
    .document(drivingActivityRef)
    .onCreate(async (snap, context) => {
        const start_location = snap.data().start_location;

        // Reverse Geocode for start driving location
        const geoCoder = nodeGeocoder(geocoderOptions);
        await geoCoder.reverse({ lat: start_location.latitude, lon: start_location.longitude })
            .then(async (res) => {
                const reverse = res[0];
                Object.keys(reverse).forEach(key => reverse[key] === undefined && delete reverse[key]);
                const userId = context.params.userId;
                const driveId = context.params.driveId;
                await admin.firestore()
                    .collection("driving_activity")
                    .doc(userId)
                    .collection("user_driving_activity")
                    .doc(driveId)
                    .update({ start_location_details: reverse });
            })
            .catch((err) => {
                console.log(err);
            });

        return Promise.resolve(SUCCESS_CODE);
    });

// Event handler that fires every time driving activity document is updated.
// In fact, when stop driving event is detected.
export const onUpdateDrivingActivity = functions.firestore
    .document(drivingActivityRef)
    .onUpdate(async (change, context) => {
        const updated = change.after.data();
        
        // Calculate distance in meters
        if (updated['end_location'] && !updated['distance']) {
            const start_location = updated.start_location;
            const end_location = updated.end_location;

            const distance = getDistance(
                { latitude: start_location.latitude, longitude: start_location.longitude },
                { latitude: end_location.latitude, longitude: end_location.longitude }
            );

            if (distance) {
                const userId = context.params.userId;
                const driveId = context.params.driveId;
                await admin.firestore()
                    .collection("driving_activity")
                    .doc(userId)
                    .collection("user_driving_activity")
                    .doc(driveId)
                    .update({ distance: distance });
            }
        }
        // Reverse Geocode for end driving location
        else if (updated['end_location'] && !updated['end_location_details']) {
            const end_location = updated.end_location;
            const geoCoder = nodeGeocoder(geocoderOptions);
            await geoCoder.reverse({ lat: end_location.latitude, lon: end_location.longitude })
                .then(async (res) => {
                    const reverse = res[0];
                    Object.keys(reverse).forEach(key => reverse[key] === undefined && delete reverse[key]);

                    const userId = context.params.userId;
                    const driveId = context.params.driveId;
                    await admin.firestore()
                        .collection("driving_activity")
                        .doc(userId)
                        .collection("user_driving_activity")
                        .doc(driveId)
                        .update({ end_location_details: reverse });
                })
                .catch((err) => {
                    console.log(err);
                });

        }
        // Calculates the distance between start and end geo coordinates.
        return Promise.resolve(SUCCESS_CODE);
    });
