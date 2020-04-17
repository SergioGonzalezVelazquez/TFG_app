const admin = require('firebase-admin');

// Events messages will not be write
const events = [
    "FIRST_SESSION"
];

// As an admin, the app has access to read and write all data, 
// regardless of Security Rules
const db = admin.firestore();

// Todos los mensajes que recibe el agente son guardados en la BD de Firebase.
// La colección "messages" está organizada en base a un ID único de conversación 
// (dialogflow_session), y contiene todos los mensajes para una determinada conversación.
export async function writeUserMessage(session: string, queryText: string) {
    // Get the database collection reference and write document with documentId
    const collectionRef = db.collection('messages').doc(session).collection('message_item').doc();

    // Message document that will be saved
    const message = {
        source: "user",
        timestamp: Date.now(),
        text: queryText,
    };

    return db.runTransaction(t => {
        t.set(collectionRef, message);
        return Promise.resolve('Write complete');
    }).then(doc => {
        //console.log("mensaje guardado!!")
    }).catch(err => {
        console.log(`Error writing message to Firestore: ${err}`);
    });


}
