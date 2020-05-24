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
const { WebhookClient, Payload } = require('dialogflow-fulfillment');

import { readUserId, readPatient } from './utils/db_manager';
import { getAnxietySuggestionsPayload, getSituationData, loopIdentitifySituations, startIdentifySituations } from './utils/situations';

process.env.DEBUG = 'dialogflow:debug'; // enables lib debugging statements

export const dialogflowFulfillment = functions.https.onRequest(async (request, response) => {
    // Create an instance of the class that handles the communication 
    // with Dialogflow's webhook fulfillment 
    const agent = new WebhookClient({ request, response });
    console.log("contexts:")
    console.log(agent.contexts)

    console.log('Dialogflow Request headers: ' + JSON.stringify(request.headers));
    console.log('Dialogflow Request body: ' + JSON.stringify(request.body));

    // Using pop() to get to the last item of the splitted string
    const session: string = agent.session.split("/").pop();


    // console.log(`agent properties. query: ${agent.query}; session: ${agent.session}; intent: ${agent.intent}; action: ${agent.action}; parameters: ${JSON.stringify(agent.parameters)}`);

    //await writeUserMessage(session, agent.query);


    async function handleRequest(agent) {
        // El intent 'primera_sesion' es activado por la app móvil cuándo el usuario 
        // entra por primera vez en un chat con el agente. La respuesta debe ser contarle al usuario
        // lo que el agente es capaz de hacer, y en función del tipo de paciente, añadir un contexto u otro.
        console.log("intent: " + agent.intent);
        if (agent.intent === 'primera_sesion') {

            addOriginalResponse();

            // Read patient type from db
            const session: string = agent.session.split("/").pop();
            const patientType = (await readPatient(session))['type'];

            if (patientType.startsWith("1")) {
                agent.add('La aplicación de la Desensibilización Sistemática requiere de unos pasos iniciales antes de empezar con las sesiones de exposición.');
                agent.add('¿Empezamos?');

                const context = { 'name': `identificar_situaciones-followup`, 'lifespan': 2 };
                agent.context.set(context);

            }
            else if (patientType.startsWith("2")) {
                agent.add('Gracias a tus respuestas en el cuestionario inicial hemos podido encontrar el tipo de terapia más apropiada');
                agent.add('¿Empezamos?');
            }
            // Pacientes de tipo 3
            else {
                agent.add('Gracias a tus respuestas en el cuestionario inicial sabemos que conduces actualmente (o has dejado de hacerlo en un período corto de tiempo)');
                agent.add('Sin embargo, necesitamos conocerte un poco más y saber qué situaciones te provocan ansiedad');
                agent.add('¿Empezamos?');
            }
        }
        else if (agent.intent.startsWith("identificar_situaciones-neutra")) {
            let situation = agent.intent.split("-")[2];
            const confirm = agent.intent.split("-")[3];
            addOriginalResponse();
            if (confirm === 'yes') {
                situation = situation.slice(0, 2) + "-" + situation.slice(2);
                console.log("situation neutra: " + situation)

                // Read itinerary from patient document
                const session: string = agent.session.split("/").pop();
                const itinerary = (await readPatient(session))['itinerary'];

                console.log(itinerary)
                const payload = getAnxietySuggestionsPayload(itinerary);
                console.log(payload);

                agent.add(
                    new Payload(agent.UNSPECIFIED, payload, { rawPayload: true, sendAsMessage: true })
                );
                console.log("añadido")

                // Custom parameters to pass with context
                const parameters = {
                    neutral: situation,
                    itinerary: itinerary
                };
                const context = { 'name': `identificar_situaciones-ansiogena`, 'lifespan': 10, 'parameters': parameters };
                agent.context.set(context);


            }
        } else if (agent.intent.startsWith("identificar_situaciones-ansiogena")) {
            if (agent.intent === 'identificar_situaciones-ansiogena-yes') {
                addOriginalResponse();
                const contextParameters = agent.context.get('identificar_situaciones-ansiogena').parameters;
                console.log("contextParameters")
                console.log(contextParameters);
                await startIdentifySituations(agent, contextParameters.itinerary, contextParameters.neutral, contextParameters.anxiety);
            }
            else {
                const ansiogena = agent.query;
                //await writeInDB("dialogflow_sessions", session, { ansiogena: ansiogena });
                //let doc = (await readFromDB("dialogflow_sessions", session)).data()
                const contextParameters = agent.context.get('identificar_situaciones-ansiogena').parameters;
                const neutraCode = contextParameters.neutral;
                console.log("neutraCode: " + neutraCode);
                const neutraStr = getSituationData(neutraCode)['item'];
                const ansiogenaStr = getSituationData(ansiogena)['item'];
                agent.add('¡Entendido! Ya verás como con un trabajo continuo eres capaz de enfrentarte a esa situación sin ningún tipo de miedo.');
                agent.add('Hasta ahora, hemos definido "' + neutraStr + '" cómo una situación que no te produce ansiedad.');
                agent.add('Y, "' + ansiogenaStr + '" como la situación que mayor ansiedad te produce');
                addOriginalResponse();

                // Custom parameters to pass with context
                const parameters = {
                    neutral: contextParameters.neutral,
                    itinerary: contextParameters.itinerary,
                    anxiety: ansiogena
                };
                const context = { 'name': `identificar_situaciones-ansiogena`, 'lifespan': 5, 'parameters': parameters };
                agent.context.set(context);
                agent.context.set({ 'name': `identificar_situaciones-ansiogena-followup`, 'lifespan': 5 });
            }
        }
        else if (agent.intent.startsWith("identificar_situaciones-listado")) {
            addOriginalResponse();
            await loopIdentitifySituations(agent);

        }
        else {
            addOriginalResponse();
        }
    }

    function addOriginalResponse() {
        agent.consoleMessages.forEach((message) => agent.add(message));
    }

    function clearOutgoingContexts() {
        agent.contexts.forEach((context) => agent.context.set({ 'name': context.name, 'lifespan': 0 }));
    }


    agent.handleRequest(handleRequest);

});

