const admin = require("firebase-admin");
const express = require('express');
const bodyParser = require('body-parser');
const cpRoute = require('./cpRoute');
const paymentRoute = require('./paymentRoute');

const app = express();
const port = 3000;

app.use(bodyParser.json());

// Initialize Firebase Admin SDK with the service account
const serviceAccountPath = "/home/dom851013/ei-website-103a4-firebase-adminsdk-guayt-b6f81d0577.json";
const serviceAccount = require(serviceAccountPath);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://ei-website-103a4-default-rtdb.asia-southeast1.firebasedatabase.app"
});

// Firestore reference
const db = admin.firestore();

// Import cpRoute and pass the Firestore reference
const cpRouter = cpRoute(db);

// Use cpRouter for all endpoints
app.use('/', cpRouter);

// Use paymentRoute for all endpoints
app.use('/', paymentRoute);

// Start the server
app.listen(port, '0.0.0.0', () => {
  console.log(`Server is running on port ${port}`);
});

module.exports = app;
