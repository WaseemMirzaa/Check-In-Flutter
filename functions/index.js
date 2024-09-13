const functions = require("firebase-functions");
const admin = require("firebase-admin");
const nodemailer = require("nodemailer");

admin.initializeApp();

const firestore = admin.firestore();

// sk_test_51P9IBQRwQJgokiPYPegZMeUdmsZdKCddCKLK4ftzP37H4Nqxhh2Cga365PIORCdc6Vo7645ICqbNC5oqOvfeRbnD00rj91dn4A
const stripe = require("stripe")("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");
// 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


exports.deleteLastCheckedIn = functions.pubsub.schedule("every 60 minutes").onRun((context) => {
    const currentTime = new Date();

    return firestore.collection("USER").get()  // Added 'return' here
        .then((querySnapshot) => {
            const batch = firestore.batch();

            querySnapshot.forEach((doc) => {
                const lastCheckin = doc.get("lastCheckin");

                if (lastCheckin) {
                    const lastCheckedInTime = lastCheckin.toDate();
                    const hoursSinceLastCheckedIn = Math.abs(currentTime - lastCheckedInTime) / (1000 * 60 * 60);

                    if (hoursSinceLastCheckedIn >= 3) {
                        console.log("CheckedOut email:" + doc.get("email"));

                        // Delete the lastCheckedIn field
                        batch.update(doc.ref, { lastCheckin: admin.firestore.FieldValue.delete() });

                        // Set the checkedIn field to false
                        batch.update(doc.ref, { checkedIn: false });
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
            throw new Error("Error getting documents: " + error);
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



var host = "smtp.gmail.com";
var port = 587;
var secure = false;
var user = "developlogix.dev@gmail.com";
var password = 'plwvrfjgullvjtgx';
var senderEmail = 'info@bookbuilder.com';

// Configure the SMTP server (example with Gmail)
const transporter = nodemailer.createTransport({
  host: host,
  port: port,
  secure: secure, // true for 465, false for other ports
  auth: {
    user: user,
    pass: password,
  },
});

// Cloud Function to trigger on new report
exports.sendReportEmail = functions.firestore
    .document("reportPosts/{reportId}")
    .onCreate((snapshot, context) => {
        const reportData = snapshot.data();
        const reportId = context.params.reportId;

        const mailOptions = {
            from: "developlogix.dev@gmail.com",
            to: "shehzadraheem.sr38@gmail.com",  // Recipient email
            subject: `New Post Report Received - ID: ${reportId}`,
            text: `A new post report has been filed.\n\nDetails:\nReport ID: ${reportId}\nPost ID: ${reportData.postId}\nReported By: ${reportData.reportedBy}\nReason: ${reportData.reason}\nTimestamp: ${reportData.timestamp.toDate()}`,
        };

        return transporter.sendMail(mailOptions)
            .then(() => console.log(`Email sent for report: ${reportId}`))
            .catch(error => console.error("Error sending email:", error));
    });


    // Cloud Function to trigger on new profile report
exports.sendReportEmail = functions.firestore
.document("reportProfiles/{reportId}")
.onCreate((snapshot, context) => {
    const reportData = snapshot.data();
    const reportId = context.params.reportId;

    const mailOptions = {
        from: "developlogix.dev@gmail.com",
        to: "shehzadraheem.sr38@gmail.com",  // Recipient email
        subject: `New Profile Report Received - ID: ${reportId}`,
        text: `A new profile report has been filed.\n\nDetails:\nReport ID: ${reportId}\nProfile ID: ${reportData.profileId}\nReported By: ${reportData.reportedBy}\nReason: ${reportData.reason}\nTimestamp: ${reportData.timestamp.toDate()}`,
    };

    return transporter.sendMail(mailOptions)
        .then(() => console.log(`Email sent for report: ${reportId}`))
        .catch(error => console.error("Error sending email:", error));
});


    // Cloud Function to trigger on new profile report
    exports.sendReportEmail = functions.firestore
    .document("reportMessage/{reportId}")
    .onCreate((snapshot, context) => {
        const reportData = snapshot.data();
        const reportId = context.params.reportId;
    
        const mailOptions = {
            from: "developlogix.dev@gmail.com",
            to: "shehzadraheem.sr38@gmail.com",  // Recipient email
            subject: `New Message Report Received - ID: ${reportId}`,
            text: `A new message report has been filed.\n\nDetails:\nReport ID: ${reportId}\nChat ID: ${reportData.docId}\nMessage ID: ${reportData.messageId}\nReported By: ${reportData.reportedBy}\nReason: ${reportData.reason}\nTimestamp: ${reportData.timestamp.toDate()}`,
        };
    
        return transporter.sendMail(mailOptions)
            .then(() => console.log(`Email sent for report: ${reportId}`))
            .catch(error => console.error("Error sending email:", error));
    });


    exports.addUserToFollowers = functions.firestore
      .document("USER/{uid}")
      .onCreate(async (snap, context) => {
        // Get the userId of the newly created user
        const newUserId = context.params.uid;

        // Reference to the followers document
        const followersDocId = "u19X1PhO6LNyEOa3skVtKU07hir2"; // Your provided doc ID for the followers collection
        const followersRef = admin.firestore().collection("followers").doc(followersDocId);

        try {
          // Add the new user ID to the followers array
          await followersRef.update({
            followers: admin.firestore.FieldValue.arrayUnion(newUserId)
          });
          console.log(`User ${newUserId} added to followers.`);
        } catch (error) {
          console.error("Error adding user to followers: ", error);
        }
      });