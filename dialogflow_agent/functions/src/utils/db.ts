const admin = require('firebase-admin');
const functions = require('firebase-functions');

export async function writeToDB(agent, collection: string, document: string, databaseEntry) {
    const db = admin.firestore();

    // Get the database collection 'dialogflow_context' and document 'agent' and store
    // the document  {entry: "<value of database entry>"} in the 'agent' document
    const dialogflowAgentRef = db.collection(collection).doc(document);

    return db.runTransaction(t => {
        t.set(dialogflowAgentRef, databaseEntry);
        return Promise.resolve('Write complete');
    }).then(doc => {
        console.log("Wrote to the Firestore");
        agent.add(`Wrote "${databaseEntry}" to the Firestore database.`);
    }).catch(err => {
        console.log(`Error writing to Firestore: ${err}`);
        agent.add(`Failed to write "${databaseEntry}" to the Firestore database.`);
    });

}