/* eslint-disable require-jsdoc */
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

                if (hoursSinceLastCheckedIn >= 3) {
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


// Function to create a record in AdditionalLocationsLog collection
async function logAdditionalLocationChange(change, context) {
  const newValue = change.after.data();
  const previousValue = change.before.data();

  console.log("change: " + change);
  console.log("newValue: " + newValue);
  console.log("previousValue: " + previousValue);

  const additionalLocationId = context.params.locationId;

  if (!previousValue && newValue) {
    // Document added
    await firestore.collection("AdditionalLocationsLog").add({
      action: "added",
      locationId: additionalLocationId,
      title: newValue.title,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  } else if (previousValue && !newValue) {
    // Document deleted
    await firestore.collection("AdditionalLocationsLog").add({
      action: "deleted",
      locationId: additionalLocationId,
      title: previousValue.title,
      timestamp: admin.firestore.FieldValue.serverTimestamp(),
    });
  }
}

// Cloud Function to trigger on document write in AdditionalLocations collection
exports.onAdditionalLocationWrite = functions.firestore
    .document("AdditionalLocations/{locationId}")
    .onWrite(logAdditionalLocationChange);

// Cloud Function for push notification
exports.sendNotification = functions.https.onRequest(async (req, res) => {
  const {token, notificationType, title, body, transactionId, peer} = req.body;

  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      notificationType: notificationType,
      peer: peer,
      transactionId: transactionId,
    },
    apns: {
      payload: {
        aps: {
          sound: "default",
        },
      },
      headers: {
        "apns-priority": "10",
      },
    },

    token: token,
  };

  try {
    const response = await admin.messaging().send(message);
    console.log("Successfully sent message:", response);
    res.status(200).send("Notification sent");
  } catch (error) {
    console.error("Error sending message:", error);
    res.status(500).send("Error sending notification");
  }
});
