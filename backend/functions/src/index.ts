import * as admin from 'firebase-admin';
admin.initializeApp();

exports.patient = require('./patient');
exports.dialogflow = require('./dialogflow');
exports.driving_event_detection = require('./driving_events_detection');