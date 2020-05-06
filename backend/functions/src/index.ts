import * as admin from 'firebase-admin';
admin.initializeApp();

exports.patient = require('./patient');

exports.driving_event_detection = require('./driving_events_detection');