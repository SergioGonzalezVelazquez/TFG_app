const admin = require('firebase-admin');
const functions = require('firebase-functions');

// As an admin, the app has access to read and write all data, 
// regardless of Security Rules
const db = admin.firestore();

export async function readFromDB(collection: string, documentId) {
    // Get the database collection reference and read document with documentId
    const documentSnapshot = await db.collection(collection).doc(documentId).get();
    return documentSnapshot;
}
