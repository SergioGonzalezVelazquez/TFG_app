import { readFromDB } from "../utils/db_manager";
import { getNextSituation } from "../situations";


const admin = require('firebase-admin');

// As an admin, the app has access to read and write all data, 
// regardless of Security Rules
const db = admin.firestore();

//
export async function handleGlobalSituations2(session: string, situations: string[]) {
    // Get the database collection reference and write document with documentId
    const collectionRef = db.collection('session_identify_situations').doc(session);
    const documents  = [];
    for (const situation of situations) {
        const situationRef = collectionRef.collection(situation).doc();
        const doc = {
            current: false,
            pending: (await readFromDB("categorias_ansiogenas", situation)).data()['level'],
            name: situation,
        }
        documents.push(doc);
        console.log("document pushed")
        await db.runTransaction(t => {
            t.set(situationRef, doc);
            console.log("document " + situation + " saved")
        }).then(docSaved => {
            //console.log("mensaje guardado!!")
        }).catch(err => {
            console.log(`Error writing message to Firestore: ${err}`);
        });
    };
    console.log("documents returned: ")
    console.log(documents.length)
    return documents;
}

export async function handleGlobalSituations(session: string, situations: string[]) {
    // Get the database collection reference and write document with documentId
    const collectionRef = db.collection('session_identify_situations').doc(session);

    const current = getNextSituation(situations);
    const doc = {
        current: current,
        pending: situations
    }

    await db.runTransaction(t => {
        t.set(collectionRef, doc);
        return Promise.resolve();
    }).then(docSaved => {
        //console.log("mensaje guardado!!")
    }).catch(err => {
        console.log(`Error writing message to Firestore: ${err}`);
    });

    return current;
}
