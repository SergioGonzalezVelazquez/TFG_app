import { createTherapy, readUserId } from "./db_manager";

const { WebhookClient, Payload } = require('dialogflow-fulfillment');
const itineraries = require("../data/itinerary.json");
const situationsTaxonomy = require("../data/taxonomy_of_situations.json");

function clearOutgoingContexts(agent) {
    agent.contexts.forEach((context) => agent.context.set({ 'name': context.name, 'lifespan': 0 }));
}

export async function startIdentifySituations(agent, itinerary: number, neutral: string, anxiety: string) {
    console.log("start Identifity Situations");
    console.log(neutral);
    console.log(anxiety);
    const parameters = {};
    parameters['neutral'] = neutral;
    parameters['anxiety'] = anxiety;
    // Situaciones que el agente propondrá para ser incluidas
    parameters['available'] = setInitialSituations(itinerary, neutral, anxiety);
    // Listado de situaciones incluidas hasta el momento
    parameters['included'] = [];
    console.log("primeros parametros definidos");

    // Obtiene la primera situación que se propone al paciente
    const firstSituationData = getNextSituation(parameters['available']);
    console.log(firstSituationData)
    parameters['currentLevel'] = firstSituationData.level;
    parameters['currentSituation'] = firstSituationData.situationCode;
    parameters['currentVariant'] = firstSituationData.variantCode;
    parameters['currentItem'] = firstSituationData.itemCode;

    if (Object.keys(parameters['available']).length > 1) {
        agent.add('Vamos a empezar hablando sobre situaciones relacionadas con ' + firstSituationData.levelStr.toLowerCase());
    }
    else {
        agent.add('Nos vamos a centrar en situaciones relacionadas con ' + firstSituationData.levelStr.toLowerCase());
    }

    if (firstSituationData.level !== 'N1' && firstSituationData.level !== 'N2') {
        agent.add('Concretamente, sobre' + firstSituationData.situationStr.toLowerCase());
    }

    agent.add('¿Qué ansiedad te provoca "' + firstSituationData.itemStr + '"?');

    // Añadir sugerencias para repuesta rápida a la respuesta del agente
    const suggestions = [];
    suggestions.push({ text: 'Indiferente / No me produce nada de ansiedad', value: 'indiferente' });
    suggestions.push({ text: 'Me produce algo de ansiedad', value: 'poca_ansiedad' });
    suggestions.push({ text: 'Me produce bastante ansiedad', value: 'bastante_ansiedad' });
    agent.add(
        new Payload(agent.UNSPECIFIED, { suggestions: suggestions }, { rawPayload: true, sendAsMessage: true })
    );

    // Clear outgoing contexts and set new context with required params
    clearOutgoingContexts(agent);
    const context = { 'name': `identificar_situaciones-listado`, 'lifespan': 50, 'parameters': parameters };
    agent.context.set(context);
    console.log(agent.contexts)
}

export async function loopIdentitifySituations(agent) {
    const contextParameters = agent.context.get('identificar_situaciones-listado').parameters;
    const newParameters = {};
    newParameters['included'] = contextParameters['included'];
    console.log(contextParameters);

    const answer = agent.query;
    if (answer !== 'indiferente') {
        // Añade la situación al listado de situaciones elegidas
        newParameters['included'].push(contextParameters['currentItem']);

        // 16 situaciones: neutra, ansiogéna y 14 del listado
        if (newParameters['included'].length === 14) {
            agent.add('¡Completado! Ya tenemos un listado de 15 situaciones temidas');
            await endIdentifySituations(agent, contextParameters['neutral'], contextParameters['anxiety'], newParameters['included']);
            return;
            // TERMINAR CONVERSACIÓN
        }

        // Cada 3 situaciones elegidas, recuerda al usuario cuántas lleva
        else if (newParameters['included'].length % 3 === 0) {
            agent.add(situationsAddedMsg(contextParameters['included'].length));
        }
    }

    // Obtiene la siguiente situación que se propone al paciente
    const nextSituationData = getNextSituation(contextParameters['available']);
    if (nextSituationData['itemCode']) {
        if (contextParameters['currentLevel'] !== nextSituationData.level && contextParameters['currentSituation'] !== nextSituationData.situationCode) {
            agent.add('Hablemos ahora sobre situaciones relacionadas con ' + nextSituationData.situationStr.toLowerCase());
        }

        newParameters['neutral'] = contextParameters['neutral'];
        newParameters['anxiety'] = contextParameters['anxiety'];
        newParameters['currentLevel'] = nextSituationData.level;
        newParameters['currentSituation'] = nextSituationData.situationCode;
        newParameters['currentVariant'] = nextSituationData.variantCode;
        newParameters['currentItem'] = nextSituationData.itemCode;
        newParameters['available'] = nextSituationData.available;

        agent.add('¿Te produce ansiedad "' + nextSituationData.itemStr + '"?');
        const suggestions = [];
        suggestions.push({ text: 'Indiferente', value: 'indiferente' });
        suggestions.push({ text: 'Me produce algo de ansiedad', value: 'poca_ansiedad' });
        suggestions.push({ text: 'Me produce bastante ansiedad', value: 'bastante_ansiedad' });
        agent.add(
            new Payload(agent.UNSPECIFIED, { suggestions: suggestions }, { rawPayload: true, sendAsMessage: true })
        );
        console.log('new parameters');
        console.log(newParameters);
        const context = { 'name': `identificar_situaciones-listado`, 'lifespan': 50, 'parameters': newParameters };
        agent.context.set(context);
    }
    // Ya se han propuesto todas las situaciones para este itinerario
    else {
        const length = newParameters['included'].length;
        // 11 situaciones, ansiógena, neutra y 9 o más del listado
        if (length >= 9) {
            agent.add('¡Terminado! Ya tenemos un listado de ' + length + ' situaciones temidas');
            await endIdentifySituations(agent, contextParameters['neutral'], contextParameters['anxiety'], newParameters['included']);
        }
        else {
            agent.add('Te has machacado todas las situaciones y sólo tenemos ' + length + ' elegidas');
            // TERMINAR CONVERSACIÓN
        }
    }
}

async function endIdentifySituations(agent, neutral: string, anxiety: string, situations) {
    const session: string = agent.session.split("/").pop();
    const userId: string = await readUserId(session);
    await createTherapy(userId, { neutra: neutral, anxiety: anxiety, situations: situations });
}

function situationsAddedMsg(added: number): string {
    const possibleResponses = [
        '¡Muy bien! Ya hemos identificado ' + added + ' situaciones',
        '¡Perfecto! Ya tenemos ' + added + ' situaciones añadidas al listado',
        '¡Genial! Llevamos ' + added + ' situaciones identificadas'
    ];

    const pick = Math.floor(Math.random() * possibleResponses.length);

    return possibleResponses[pick];
}



function getNextSituation(availableSituations) {
    if (Object.keys(availableSituations).length === 0) {
        return {};
    }

    const levelCode = Object.keys(availableSituations)[0];
    const levelStr = situationsTaxonomy[levelCode]['category'];
    const situationCode = Object.keys(availableSituations[levelCode])[0];
    const situationStr = situationsTaxonomy[levelCode]['situations'][situationCode]['name'];
    const newAvailableSituations = availableSituations;
    let variantCode;
    let variantStr;
    let itemCode;
    let itemStr;

    if (levelCode === 'N1' || levelCode === 'N2') {
        itemCode = newAvailableSituations[levelCode][situationCode];
        itemStr = getSituationData(itemCode, levelCode)['item'];

        // Elimina la situación de disponibles
        delete newAvailableSituations[levelCode][situationCode];
    }
    else {
        variantCode = Object.keys(newAvailableSituations[levelCode][situationCode])[0];
        variantStr = situationsTaxonomy[levelCode]['situations'][situationCode]['variants'][variantCode]['name'];

        itemCode = newAvailableSituations[levelCode][situationCode][variantCode][0];
        itemStr = situationsTaxonomy[levelCode]['situations'][situationCode]['variants'][variantCode]['items'][itemCode];

        // Elimina la situación de disponibles
        newAvailableSituations[levelCode][situationCode][variantCode].shift();

        // Si no quedan más items, elimina esa variación
        if (Object.keys(newAvailableSituations[levelCode][situationCode][variantCode]).length === 0) {
            delete newAvailableSituations[levelCode][situationCode][variantCode];
        }

        // Si no quedan más variaciones, elimina esa situación
        if (Object.keys(newAvailableSituations[levelCode][situationCode]).length === 0) {
            delete newAvailableSituations[levelCode][situationCode];
        }
    }

    // Si no quedas más situaciones, elimina este nivel
    if (Object.keys(newAvailableSituations[levelCode]).length === 0) {
        delete newAvailableSituations[levelCode];
    }

    return {
        level: levelCode, levelStr: levelStr,
        situationCode: situationCode, situationStr: situationStr,
        variantCode: variantCode, variantStr: variantStr,
        itemCode: itemCode, itemStr: itemStr,
        available: newAvailableSituations
    }
}


// Para un itinerario dado, obtiene un listado de las situaciones
// que más ansiedad producen en la mayoría de los pacientes. 
// Con el listado de estas situaciones, construye el payload para que el 
// agente proponga estas situaciones al usuario.
export function getAnxietySuggestionsPayload(itinerary: number) {
    const situations = itineraries[itinerary]['greatest_anxiety'];
    const suggestions = [];

    situations.forEach((situation) => {
        const situationData = getSituationData(situation);
        suggestions.push({ value: situation, text: situationData['item'] });
    });

    return { suggestions: suggestions }
}

// Función utilizada cuándo comienza el bucle para identificar situaciones. 
// Dado el itinerario a seguir, y la situación que se ha definido cómo neutra, 
// devuelve un "itinerario reducido" en el que se han eliminado algunas situaciones.

function setInitialSituations(itinerary: number, neutralItem: string, anxietyItem: string) {
    const availableSituations = itineraries[itinerary]['situations'];
    const neutralData = getSituationData(neutralItem);

    // Si la situación neutra es la más alta del nivel 1, suponemos que las 
    // situaciones de N1 ('aproximación al vehículo están') superadas
    if (neutralData['level'] === 'N1') {
        if (neutralItem === 'C1-S2') {
            delete availableSituations['N1'];
        }
        else if (neutralItem === 'C1-S1') {
            delete availableSituations['N1']['S1'];
        }
    }
    // Si la situación neutra es del nivel N2, suponemos que las 
    // situaciones de N1 ('aproximación al vehículo están superadas')
    else if (neutralData['level'] === 'N2') {
        delete availableSituations['N1'];
        const situation = neutralItem.split("-")[1];
        delete availableSituations['N2'][situation];
    }
    // Si la situación neutra no es del nivel N2 ni N1, entonces suponemos
    // que las situaciones de N1 y N2 están superadas
    else {
        delete availableSituations['N1'];
        delete availableSituations['N2'];
        const neutralSituation = neutralItem.split("-")[1];
        const neutralVariant = neutralItem.split("-")[2].slice(0, -1);
        const index = availableSituations[neutralData['level']][neutralSituation][neutralVariant].indexOf(neutralItem);
        if (index > -1) {
            availableSituations[neutralData['level']][neutralSituation][neutralVariant].splice(index, 1);
        }
    }

    // Borra la situación que mayor ansiedad produce
    const anxietyData = getSituationData(anxietyItem);
    const anxietySituation = anxietyItem.split("-")[1];
    const anxietyVariant = anxietyItem.split("-")[2].slice(0, -1);
    const index = availableSituations[anxietyData['level']][anxietySituation][anxietyVariant].indexOf(anxietyItem);
    if (index > -1) {
        availableSituations[anxietyData['level']][anxietySituation][anxietyVariant].splice(index, 1);
    }


    return availableSituations;
}

export function getSituationData(itemCode: string, level?: string) {
    const situation: string = itemCode.split("-")[1];

    if (!level) {
        level = getSituationLevel(itemCode);
    }

    let itemStr: string = '';

    const situationTaxonomy = situationsTaxonomy[level]["situations"][situation];

    if (situationTaxonomy['variants']) {
        let variant: string = itemCode.split("-")[2];
        variant = variant.substring(0, variant.length - 1);
        itemStr = situationTaxonomy['variants'][variant]['items'][itemCode];
    }
    else {
        itemStr = situationTaxonomy['items'][itemCode];
    }

    return { level: level, item: itemStr };
}

function getSituationLevel(itemCode: string): string {
    const category: string = itemCode.split("-")[0];
    if (["C1", "C2", "C3"].includes(category)) return "N" + category.substring(1);
    else if (category === "C4") {
        const variant: string = itemCode.split("-")[1];
        return (variant === "S1") ? "N4" : "N5";
    }
    else if (category === "C5") {
        const variant: string = itemCode.split("-")[1];
        return (variant === "S1") ? "N6" : "N7";
    }
}
