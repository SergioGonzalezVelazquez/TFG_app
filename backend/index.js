// Import JSON data to firebase cloud firestore
//
// References:
// https://medium.com/lucas-moyer/how-to-import-json-data-into-firestore-2b370486b622
// https://stackoverflow.com/questions/46640981/how-to-import-csv-or-json-to-firebase-cloud-firestore
// https://stackoverflow.com/questions/4351521/how-do-i-pass-command-line-arguments-to-a-node-js-program

// Required for side-effects
require("firebase/firestore");

// Initialize Cloud Firestore through Firebase
const admin = require("firebase-admin");
const serviceAccount = require("./service-key.json");
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    databaseURL: "https://stopmiedo-ikiqvp.firebaseio.com",
});

const data = require(process.argv[2]);

async function upload(data, path) {
    return await admin.firestore()
        .doc(path.join('/'))
        .set(data)
        .then(() => console.log(`Document ${path.join('/')} uploaded.`))
        .catch((error) => console.error(error + ` Could not write document ${path.join('/')}.`));
}

/**
 * Data is a collection if
 *  - contains only objects or contains no objects.
 */
function isCollection(data) {
    if (
        typeof data != 'object' ||
        data == null ||
        data.length === 0 || 
        isEmpty(data) ||
        Array.isArray(data)
    ) {

        return false;
    }
    for (const key in data) {
        if (typeof data[key] != 'object' || data[key] == null) {
            // If there is at least one non-object item in the data then it cannot be collection.
            return false;
        }
    }

    return true;
}

// Checks if object is empty.
function isEmpty(obj) {
    for (const key in obj) {
        if (obj.hasOwnProperty(key)) {
            return false;
        }
    }
    return true;
}

/**
 *
 */
async function resolve(data, path = []) {
    if (path.length > 0 && path.length % 2 == 0) {
        // Document's length of path is always even, however, one of keys can actually be a collection.
        // Copy an object.
        const documentData = Object.assign({}, data);

        for (const key in data) {
            // Resolve each collection and remove it from document data.
            if (isCollection(data[key], [...path, key])) {
                // Remove a collection from the document data.
                delete documentData[key];
                // Resolve a colleciton.
                resolve(data[key], [...path, key]);
            }
        }

        // If document is empty then it means it only consisted of collections.
        if (!isEmpty(documentData)) {
            // Upload a document free of collections.
            await upload(documentData, path);
        }
    } else {
        // Collection's length of is always odd.
        for (const key in data) {
            // Resolve each collection.
            await resolve(data[key], [...path, key]);
        }
    }
}

resolve(data);