const admin = require('firebase-admin');
const functions = require('firebase-functions');



// As an admin, the app has access to read and write all data, 
// regardless of Security Rules
const db = admin.firestore();

export async function writeMessage(isAgent: boolean, text: string, sessionId: string, index: number) {
    console.log("write message: " + index);
    console.log(text);
    const collection = db.collection('dialogflow_sessions').doc(sessionId).collection('messages').doc();
    // Atomically add a new message to the "messages" array field.
    await writeInDB(collection, {
        text: text, type: isAgent ? "bot" : "user", index: index, timestamp: admin.firestore.FieldValue.serverTimestamp()
    });
}

export async function createTherapy(userId: string, data) {
    data['active'] = true;
    const collection = db.collection('patient').doc(userId).collection('userTherapies').doc();
    await writeInDB(collection, data);

    // Update patient status
    const patientCollection = db.collection('patient').doc(userId);
    await writeInDB(patientCollection, { status: 'hierarchy_pending' }, true);
}

export async function updatePatient(userId: string, data) {
    const collection = db.collection('patient').doc(userId);
    await writeInDB(collection, data, true);
}

export async function readUserId(sessionId: string): Promise<string> {
    const collection = db.collection('dialogflow_sessions').doc(sessionId);
    const userId: string = (await readFromDB(collection)).data()['user_id'];
    return userId;
}

export async function readPatient(sessionId: string, userId: string) {
    const collection = db.collection('patient').doc(userId);
    const patientData = (await readFromDB(collection)).data();
    return patientData;
}

async function readFromDB(collection) {
    // Get the database collection reference and read document with documentId
    const documentSnapshot = await collection.get();
    return documentSnapshot;
}


export async function writeInDB(collection, data, update: boolean = false) {
    // Get the database collection reference and read document with documentId
    if (update) {
        await collection.update(data);
    }
    else {
        await collection.set(data);
    }
}

