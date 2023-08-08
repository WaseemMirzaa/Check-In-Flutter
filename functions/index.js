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

exports.deleteLastCheckedIn = functions.pubsub.schedule("every 60 minutes")
    .onRun((context) => {
      const currentTime = new Date();

      firestore.collection("USER").get()
          .then((querySnapshot) => {
            const batch = firestore.batch();

            querySnapshot.forEach((doc) => {
              const lastCheckin = doc.get("lastCheckin");
              // console.log("lastCheckin:" + lastCheckin);
              // console.log("checkedIn:" + doc.get("checkedIn"));

              if (lastCheckin) {
                const lastCheckedInTime = lastCheckin.toDate();
                // console.log("lastCheckedInTime:" + lastCheckedInTime);

                const hoursSinceLastCheckedIn = Math.abs(currentTime -
                  lastCheckedInTime) / (1000 * 60 * 60);

                // eslint-disable-next-line max-len
                // console.log("hoursSinceLastCheckedIn:" + hoursSinceLastCheckedIn);

                if (hoursSinceLastCheckedIn >= 12) {
                  console.log("CheckedOut email:" + doc.get("email"));

                  // Delete the lastCheckedIn field
                  batch.update(doc.ref,
                      {lastCheckin: admin.firestore.FieldValue.delete()});

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


