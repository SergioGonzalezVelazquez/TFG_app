// See https://github.com/dialogflow/dialogflow-fulfillment-nodejs
// for Dialogflow fulfillment library docs, samples, and to report issues
//
// Start writing Firebase Functions
// https://firebase.google.com/docs/functions/typescript

// Cloud Functions for Firebase SDK to create Cloud Functions and setup triggers.
import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';

// Firebase Admin SDK to access the Firebase Realtime Database.

const { WebhookClient, Payload } = require('dialogflow-fulfillment');

import { readUserId, readPatient, writeMessage } from './utils/db_manager';
import { getAnxietySuggestionsPayload, getSituationData, loopIdentitifySituations, startIdentifySituations } from './utils/situations';

process.env.DEBUG = 'dialogflow:debug'; // enables lib debugging statements

export const dialogflowFulfillment = functions.https.onRequest(async (request, response) => {
    // Create an instance of the class that handles the communication 
    // with Dialogflow's webhook fulfillment 
    const agent = new WebhookClient({ request, response });
    console.log('Dialogflow Request headers: ' + JSON.stringify(request.headers));
    console.log('Dialogflow Request body: ' + JSON.stringify(request.body));

    // Using pop() to get to the last item of the splitted string
    const session: string = agent.session.split("/").pop();


    // console.log(`agent properties. query: ${agent.query}; session: ${agent.session}; intent: ${agent.intent}; action: ${agent.action}; parameters: ${JSON.stringify(agent.parameters)}`);

    async function handleRequest(agent) {
        // El intent 'primera_sesion' es activado por la app móvil cuándo el usuario 
        // entra por primera vez en un chat con el agente. La respuesta debe ser contarle al usuario
        // lo que el agente es capaz de hacer, y en función del tipo de paciente, añadir un contexto u otro.
        if (agent.intent === 'primera_sesion') {

            // Read patient type from db
            const session: string = agent.session.split("/").pop();
            const userId: string = await readUserId(session);
            const patient = (await readPatient(session, userId));
            const patientType = patient['type'];

            // Initialize global context with patient type, messages count and userId
            const globalParameters = {
                userId: userId,
                patient: patient,
                messagesCount: 0
            };


            // Write bot original messages
            const currentIndex = globalParameters.messagesCount;
            globalParameters.messagesCount += agent.consoleMessages.length;
            await addOriginalResponse(currentIndex);


            if (patientType.startsWith("1")) {
                await addResponse('La aplicación de la Desensibilización Sistemática requiere de unos pasos iniciales antes de empezar con las sesiones de exposición.', ++globalParameters.messagesCount);
                await addResponse('¿Empezamos?', ++globalParameters.messagesCount);
                const context = { 'name': `identificar_situaciones-followup`, 'lifespan': 2 };
                agent.context.set(context);

            }
            else if (patientType.startsWith("2")) {
                await addResponse('Gracias a tus respuestas en el cuestionario inicial hemos podido encontrar el tipo de terapia más apropiada', ++globalParameters.messagesCount);
                await addResponse('¿Empezamos?', ++globalParameters.messagesCount);
            }
            // Pacientes de tipo 3
            else {
                await addResponse('Gracias a tus respuestas en el cuestionario inicial sabemos que conduces actualmente (o has dejado de hacerlo en un período corto de tiempo)', ++globalParameters.messagesCount);
                await addResponse('Sin embargo, necesitamos conocerte un poco más y saber qué situaciones te provocan ansiedad', ++globalParameters.messagesCount);
                await addResponse('¿Empezamos?', ++globalParameters.messagesCount);
            }

            const global = { 'name': `global_context`, 'lifespan': 20, 'parameters': globalParameters };
            agent.context.set(global);
        }
        else {
            const globalParameters = agent.context.get('global_context').parameters;
            if (agent.intent.startsWith("identificar_situaciones-neutra")) {
                let situation = agent.intent.split("-")[2];
                const confirm = agent.intent.split("-")[3];

                if (confirm === 'yes') {
                    situation = situation.slice(0, 2) + "-" + situation.slice(2);
                    const itinerary = globalParameters.patient['itinerary'];
                    const payload = getAnxietySuggestionsPayload(itinerary);

                    agent.add(
                        new Payload(agent.UNSPECIFIED, payload, { rawPayload: true, sendAsMessage: true })
                    );

                    // Custom parameters to pass with context
                    const parameters = {
                        neutral: situation,
                        itinerary: itinerary
                    };
                    const context = { 'name': `identificar_situaciones-ansiogena`, 'lifespan': 10, 'parameters': parameters };
                    agent.context.set(context);

                }

                // Write user messages
                await writeMessage(false, agent.query, session, ++globalParameters.messagesCount);


                // Write bot original messages
                const currentIndex = globalParameters.messagesCount;
                globalParameters.messagesCount += agent.consoleMessages.length;
                await addOriginalResponse(currentIndex);

                const global = { 'name': `global_context`, 'lifespan': 20, 'parameters': globalParameters };
                agent.context.set(global);


            } else if (agent.intent.startsWith("identificar_situaciones-ansiogena")) {

                if (agent.intent === 'identificar_situaciones-ansiogena-yes') {
                    // Write user messages
                    await writeMessage(false, agent.query, session, ++globalParameters.messagesCount);

                    // Write bot original messages
                    const currentIndex = globalParameters.messagesCount;
                    globalParameters.messagesCount += agent.consoleMessages.length;
                    await addOriginalResponse(currentIndex);

                    const contextParameters = agent.context.get('identificar_situaciones-ansiogena').parameters;
                    await startIdentifySituations(agent, contextParameters.itinerary, contextParameters.neutral, contextParameters.anxiety, globalParameters);
                }
                else {
                    const ansiogena = agent.query;
                    //await writeInDB("dialogflow_sessions", session, { ansiogena: ansiogena });
                    //let doc = (await readFromDB("dialogflow_sessions", session)).data()
                    const contextParameters = agent.context.get('identificar_situaciones-ansiogena').parameters;
                    const neutraCode = contextParameters.neutral;
                    const neutraStr = getSituationData(neutraCode)['item'];
                    const ansiogenaStr = getSituationData(ansiogena)['item'];
                    await writeMessage(false, ansiogenaStr, session, ++globalParameters.messagesCount);
                    await addResponse('¡Entendido! Ya verás como con un trabajo continuo eres capaz de enfrentarte a esa situación sin ningún tipo de miedo.', ++globalParameters.messagesCount);
                    await addResponse('Hasta ahora, hemos definido "' + neutraStr + '" cómo una situación que no te produce ansiedad.', ++globalParameters.messagesCount);
                    await addResponse('Y, "' + ansiogenaStr + '" como la situación que mayor ansiedad te produce', ++globalParameters.messagesCount);


                    // Write bot original messages
                    const currentIndex = globalParameters.messagesCount;
                    globalParameters.messagesCount += agent.consoleMessages.length;
                    await addOriginalResponse(currentIndex);

                    // Custom parameters to pass with context
                    const parameters = {
                        neutral: contextParameters.neutral,
                        itinerary: contextParameters.itinerary,
                        anxiety: ansiogena
                    };
                    const context = { 'name': `identificar_situaciones-ansiogena`, 'lifespan': 5, 'parameters': parameters };
                    agent.context.set(context);
                    agent.context.set({ 'name': `identificar_situaciones-ansiogena-followup`, 'lifespan': 5 });

                    const global = { 'name': `global_context`, 'lifespan': 20, 'parameters': globalParameters };
                    agent.context.set(global);
                }
            }
            else if (agent.intent.startsWith("identificar_situaciones-listado")) {
                // Write user messages
                let queryStr: string = '';
                if (agent.query === 'indiferente') {
                    queryStr = 'Indiferente';
                }
                else if (agent.query === 'poca_ansiedad') {
                    queryStr = 'Me produce algo de ansiedad';
                }
                else {
                    queryStr = 'Me produce bastante ansiedad';
                }

                // Write user messages
                await writeMessage(false, queryStr, session, ++globalParameters.messagesCount);

                // Write bot original messages
                const currentIndex = globalParameters.messagesCount;
                globalParameters.messagesCount += agent.consoleMessages.length;
                await addOriginalResponse(currentIndex);

                await loopIdentitifySituations(agent, globalParameters);

            }
            else {
                // Write user messages
                await writeMessage(false, agent.query, session, ++globalParameters.messagesCount);

                // Write bot original messages
                const currentIndex = globalParameters.messagesCount;
                globalParameters.messagesCount += agent.consoleMessages.length;
                await addOriginalResponse(currentIndex);

                const global = { 'name': `global_context`, 'lifespan': 20, 'parameters': globalParameters };
                agent.context.set(global);
            }
        }
    }

    async function addResponse(message: string, index: number) {
        agent.add(message);
        await writeMessage(true, message, session, index);
    }

    async function addOriginalResponse(index: number) {
        agent.consoleMessages.forEach(async (message) => {
            await addResponse(message['text'], ++index);
        });
    }


    /*
    async function writeAgentMessages() {
        await agent.consoleMessages.forEach(async (message, index) => {
            console.log(message['text'])
            await writeMessage(true, message['text'], session, index)
        });
    }
    */

    // Write bot messages
    //await writeAgentMessages();

    agent.handleRequest(handleRequest);

});

