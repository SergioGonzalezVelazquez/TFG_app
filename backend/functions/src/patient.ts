import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as jsonLogic from 'json-logic-js';

import * as patientTypes from '../../data/patient_type.json';

const patientRef = 'patient/{userId}';
const SUCCESS_CODE = 0;


// Event handler that fires every time a 'patient' document is created.
export const onCreatePatient = functions.firestore
    .document(patientRef)
    .onCreate(async (snap, context) => {
        const userId = context.params.userId;
        console.log(`NUEVO4 patient creado para el usuario: ${userId} `)


        // Get pretest response of this patient
        let doc = await admin.firestore()
            .collection("pretest_questionnaire_response")
            .doc(userId)
            .get();

        if (doc.exists) {
            const data = doc.data();
            const type = evaluatePatientType(data);

            if (type) {
                console.log("type: " + type)
                await admin.firestore()
                    .collection("patient")
                    .doc(userId)
                    .update({ "type": type });
            }
        }
        return Promise.resolve(SUCCESS_CODE);

    });

function evaluatePatientType(data) {
    for (let element in patientTypes) {
        const type = patientTypes[element];
        const rules = type['conditions']

        let result = jsonLogic.apply(rules, data);

        if (result) return element;
    }
}