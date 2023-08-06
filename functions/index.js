/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onRequest} = require("firebase-functions/v2/https");
// const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });

exports.deleteLastCheckedIn = functions.pubsub.schedule("every 5 minutes")
    .onRun((context) => {
      const currentTime = new Date();

      firestore.collection("USER").get()
          .then((querySnapshot) => {
            const batch = firestore.batch();

            querySnapshot.forEach((doc) => {
              const lastCheckedIn = doc.get("lastCheckedIn");

              if (lastCheckedIn) {
                const lastCheckedInTime = lastCheckedIn.toDate();
                const hoursSinceLastCheckedIn = Math.abs(currentTime -
                  lastCheckedInTime) / (1000 * 60 * 60);

                if (hoursSinceLastCheckedIn >= 12) {
                  // Delete the lastCheckedIn field
                  batch.update(doc.ref,
                      {lastCheckedIn: admin.firestore.FieldValue.delete()});

                  // Set the checkedIn field to false
                  batch.update(doc.ref, {checkedIn: false});
                }
              }
            });

            // Commit the batch
            return batch.commit();
          })
          .then(() => {
            console.log("Function successfully ran!");
            return null;
          })
          .catch((error) => {
            console.error("Error getting documents:", error);
          });
    });


