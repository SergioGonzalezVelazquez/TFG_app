import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import * as jsonLogic from 'json-logic-js';

import { getSituationData } from './utils/situations';
import * as patientTypes from '../../data/patient_type.json';

const patientRef = 'patient/{userId}';
const SUCCESS_CODE = 0;

enum PatientStatus {
    pretest_pending = "pretest_pending",
    pretest_in_progress = "pretest_in_progress",
    pretest_completed = "pretest_completed",
    identify_categories_pending = "identify_categories_pending",
    identify_categories_in_progress = "identify_categories_in_progress",
    identify_situations_pending = "identify_situations_pending",
    identify_situations_in_progress = "identify_situations_in_progress",
    hierarchy_pending = "hierarchy_pending",
    hierarchy_completed = "hierarchy_completed",
    in_exercise = "in_exercise"
}

// Event handler that fires every time a 'patient' document is updated.
export const onUpdatePatient = functions.firestore
    .document(patientRef)
    .onUpdate(async (change, context) => {
        const userId = context.params.userId;
        const patient = change.after.data();

        console.log(`UPDATED patient para el usuario: ${userId} `);

        // Calculate type of patient
        console.log(patient['status']);
        if (patient['status'] === PatientStatus.pretest_completed.toString()) {
            // Get pretest response of this patient
            const doc = await admin.firestore()
                .collection("pretest_questionnaire_response")
                .doc(userId)
                .get();

            if (doc.exists) {
                const data = doc.data();
                const patientType = findPatientTypeDFS(data, patientTypes);

                if (patientType) {
                    if (patientType['type'].startsWith("1") || patientType['type'].startsWith("2")) {
                        patientType['status'] = PatientStatus.identify_situations_pending;
                    }
                    else {
                        patientType['status'] = PatientStatus.identify_categories_in_progress;
                    }
                    if (!patient['itinerary']) {
                        delete patient['itinerary'];
                    }
                    console.log(patientType)
                    await admin.firestore()
                        .collection("patient")
                        .doc(userId)
                        .update(patientType);
                }
            }
        }
        else if (patient['status'] === PatientStatus.hierarchy_completed.toString()) {

            // Obtener la jerarquía de situaciones que ha construido el paciente
            const snapshot = await admin.firestore()
                .collection("patient")
                .doc(userId)
                .collection("userTherapies")
                .where('active', '==', true)
                .limit(1)
                .get();

            if (!snapshot.empty) {
                const doc = snapshot.docs[0];
                const hierarchy = doc.data()['hierarchy'];

                // For each situation in hierarchy, create an exercise
                hierarchy.forEach(async (situation, index) => {
                    const data = getSituationData(situation['itemCode']);
                    data['itemCode'] = situation['itemCode'];
                    console.log(data);

                    Object.keys(data).forEach(key => {
                        if (data[key] === undefined) {
                            delete data[key];
                        }
                    });

                    // Add hierarchy usas as currentUsas
                    data['originalUSAs'] = situation['usas'];
                    delete data['usas'];
                    data['index'] = index;
                    data['status'] = index === 0 ? 'in_progress' : 'waiting'

                    await admin.firestore()
                        .collection("patient")
                        .doc(userId)
                        .collection("userTherapies")
                        .doc(doc.id)
                        .collection("exercises")
                        .doc()
                        .set(data);
                });
            }
            else {
                console.log("is empty");
            }


            await admin.firestore()
                .collection("patient")
                .doc(userId)
                .update({ status: PatientStatus.in_exercise.toString() });
       

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