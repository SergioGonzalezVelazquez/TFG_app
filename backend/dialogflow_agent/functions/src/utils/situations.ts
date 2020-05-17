const itineraries = require("../data/itinerary.json");
const situationsTaxonomy = require("../data/taxonomy_of_situations.json");


// Para un itinerario dado, obtiene un listado de las situaciones
// que más ansiedad producen en la mayoría de los pacientes. 
// Con el listado de estas situaciones, construye el payload para que el 
// agente responda al usuario.
export function getAnxietySuggestionsPayload(itinerary: number) {
    const situations = itineraries[itinerary]['greatest_anxiety'];
    const suggestions = [];

    situations.forEach((situation) => {
        const situationData = getSituationData(situation);
        suggestions.push({ value: situation, text: situationData['item'] });
    });

    return { suggestions: suggestions }
}

export function setInitialSituations(itinerary: number, neutral: string, anxiety: string) {
    let document = {};
    document['neutral'] = neutral;
    document['anxiety'] = neutral;
    document['remain'] = 15;
    document['available_situations'] = [];

    const situationsDocs = [];
    // Create subcollection with document for each available situation
    //var batch = db.batch();
    for (let level in itineraries[itinerary]['situations']) {
        itineraries[itinerary]['situations'][level].forEach(element => {
            const doc = getSituationData(element, level);
            console.log(doc);
        });
    }
    //batch.commit()
}


function getSituationData(itemCode: string, level?: string) {
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
