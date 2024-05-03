const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp();

const firestore = admin.firestore();

// sk_test_51P9IBQRwQJgokiPYPegZMeUdmsZdKCddCKLK4ftzP37H4Nqxhh2Cga365PIORCdc6Vo7645ICqbNC5oqOvfeRbnD00rj91dn4A
const stripe = require("stripe")("sk_test_51P9IBQRwQJgokiPYPegZMeUdmsZdKCddCKLK4ftzP37H4Nqxhh2Cga365PIORCdc6Vo7645ICqbNC5oqOvfeRbnD00rj91dn4A");
// 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


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
  const {token, notificationType, title, body, docId, name, isGroup, image,
    memberIds} = req.body;


  const message = {
    notification: {
      title: title,
      body: body,
    },
    data: {
      notificationType: notificationType,
      docId: docId,
      name: name,
      isGroup: isGroup.toString(),
      image: image,
      memberIds: JSON.stringify(memberIds),
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
    console.log("Successfully sent message:", req);
    console.error("Error sending message:", error);
    res.status(500).send("Error sending notification");
  }
});

exports.initPaymentSheet = functions.https.onRequest(async (data, res) => {
  try {
    const {amount, customerId} = data.body;
    const ephemeralKey = await stripe.ephemeralKeys.create({
      customer: customerId,
    }, {
      apiVersion: "2024-04-10",
    });

    const paymentIntent = await stripe.paymentIntents.create({
      amount: amount,
      currency: "usd",
      customer: customerId,
      automatic_payment_methods: {
        enabled: true,
      },
    });

    res.status(200).json({
      paymentIntent: paymentIntent,
      ephemeralKey: ephemeralKey.secret,
      customer: customerId,
      clientSecret: paymentIntent.client_secret,
    });
  } catch (error) {
    console.error("Error:", error.message);
    res.status(500).json({error: error.message});
  }
});

exports.createStripeCustomer = functions.https.onRequest(async (data, res) => {
  try {
    const email = data.body.email;
    const customer = await stripe.customers.create({
      email: email,
    });

    res.json({customerId: customer.id});
  } catch (err) {
    console.log(err);
    res.json({error: err});

    res.status(500).json({error: err.message});
  }
});

