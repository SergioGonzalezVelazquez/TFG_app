import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as jsonLogic from 'json-logic-js';

admin.initializeApp();

import * as patientTypes from '../../data/patient_type.json';

const patientRef = 'patient/{userId}';
const SUCCESS_CODE = 0;


// Event handler that fires every time a 'patient' document is created.
export const onCreatePatient = functions.firestore
    .document(patientRef)
    .onCreate(async (snap, context) => {
        const userId = context.params.userId;
        console.log(`NUEVO patient creado para el usuario: ${userId} `);


        // Get pretest response of this patient
        const doc = await admin.firestore()
            .collection("pretest_questionnaire_response")
            .doc(userId)
            .get();

        if (doc.exists) {
            const data = doc.data();
            const patientType = findPatientTypeDFS(data, patientTypes);

            if (patientType) {
                console.log(patientType)
                await admin.firestore()
                    .collection("patient")
                    .doc(userId)
                    .update(patientType);
            }
        }
        return Promise.resolve(SUCCESS_CODE);

    });

function findPatientTypeDFS(response, tree, description = '') {
    let itinerary;
    let solution;

    for (const node in tree) {
        const conditions = tree[node]['conditions'];
        if (jsonLogic.apply(conditions, response)) {

            const newDescription = description + tree[node]['description'] + ". ";
            if (tree[node]['subtypes']) {
                solution = findPatientTypeDFS(response, tree[node]['subtypes'], newDescription);
            }
            else {
                itinerary = tree[node]['itinerary']
                solution = { type: node, description: newDescription, itinerary: itinerary }
            }
            break;
        }
    }
    return solution;
}