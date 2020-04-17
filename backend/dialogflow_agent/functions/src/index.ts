// See https://github.com/dialogflow/dialogflow-fulfillment-nodejs
// for Dialogflow fulfillment library docs, samples, and to report issues
//
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
import * as functions from 'firebase-functions';
// Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp(functions.config().firebase);
const { WebhookClient } = require('dialogflow-fulfillment');

import { readFromDB } from './utils/db_manager';
import { writeUserMessage } from './handlers/handle.message';
import { handleGlobalSituations } from './handlers/handle.global_situations';

process.env.DEBUG = 'dialogflow:debug'; // enables lib debugging statements

export const dialogflowFulfillment = functions.https.onRequest(async (request, response) => {
    // Create an instance of the class that handles the communication 
    // with Dialogflow's webhook fulfillment 
    const agent = new WebhookClient({ request, response });
    console.log(agent.contexts)

    console.log('Dialogflow Request headers: ' + JSON.stringify(request.headers));
    console.log('Dialogflow Request body: ' + JSON.stringify(request.body));

    // Using pop() to get to the last item of the splitted string
    const session: string = agent.session.split("/").pop();
    const userId: string = (await readFromDB("dialogflow_sessions", session)).data()['user_id'];

    console.log(`agent properties. query: ${agent.query}; session: ${agent.session}; intent: ${agent.intent}; action: ${agent.action}; parameters: ${JSON.stringify(agent.parameters)}`);

    //await writeUserMessage(session, agent.query);


    async function handleRequest(agent) {
        if (agent.intent === 'identificar_situaciones.global') {
            // El agente habrá reconocido una serie de categorías ansiógenas
            // a las cuales podemos acceder mediante el parámetro "situacion_ansiogena".
            // Vamos a guardar todas ellas en una colección "session_situation", de forma
            // que el agente pueda ir explorando cada una de ellas para obtener información
            // más concreta sobre las situaciones que le producen ansiedad al usuario.
            //
            // Es posible que en esa lista de situaciones haya alguna duplicada. Por ejemplo, el agente 
            // relacionará "decidir un sitio en el que estacionar" y "realizar maniobras de estacionamiento"
            // con la misma categoría "estacionar". Hay que limpiar ese listado para que no haya situaciones
            // repetidas.
            let situations = [];
            agent.parameters['situacion_ansiogena'].forEach(element => {
                if (!situations.includes(element))
                    situations.push(element);
            });
            agent.parameters['situacion_ansiogena'] = situations;

            const currentSituation = await handleGlobalSituations(session, situations);
            console.log("currentSituation: " + currentSituation);

            addOriginalResponse();
            agent.add(`Vamos a empezar explorando más en detalle posibles situaciones ansiógenas relacionadas con ${currentSituation}`);
            let context = {'name': `identificar_situaciones_${currentSituation}`, 'lifespan': 3};
            agent.context.set(context);
        }
        else {
            console.log(agent.consoleMessages);
            addOriginalResponse();
        }
    }

    function addOriginalResponse() {
        agent.consoleMessages.forEach((message) => agent.add(message));
    }


    agent.handleRequest(handleRequest);



});
