// See https://github.com/dialogflow/dialogflow-fulfillment-nodejs
// for Dialogflow fulfillment library docs, samples, and to report issues
//
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript
import * as functions from 'firebase-functions';
import { handleIdentifyingSituations } from './situations';
import { writeToDB } from './utils/db';

const admin = require('firebase-admin');
const { WebhookClient } = require('dialogflow-fulfillment');

process.env.DEBUG = 'dialogflow:debug'; // enables lib debugging statements

admin.initializeApp(functions.config().firebase);
const db = admin.firestore();

export const dialogflowFulfillment = functions.https.onRequest(async (request, response) => {
    // class that handles the communication with Dialogflow's webhook fulfillment 
    const agent = new WebhookClient({ request, response });
    console.log('Dialogflow Request headers: ' + JSON.stringify(request.headers));
    console.log('Dialogflow Request body: ' + JSON.stringify(request.body));

    // Get current contexts as a list of strings
    const contexts: string[] = agent.contexts.map(context => context.name);

    if (agent.intent === 'identificar_situaciones.comienzo') {
        console.log("handl identificar_situaciones.comienzo");

        // Get parameter from Dialogflow with the string to add to the database
        const databaseEntry = {status: "identificar_situaciones_ansiogenas"};

        await writeToDB(agent, 'dialogflow_context', 'MyGHXv1mnSTSVL1SSDlojRztW143', databaseEntry);
    }

    // Dialogflow agent and patient are identifying anxiety situations
    // context: identificar_situaciones_ansiogenas
    if (contexts.includes('identificar_situaciones_ansiogenas')) {
        await handleIdentifyingSituations(agent, contexts);
    }

});
