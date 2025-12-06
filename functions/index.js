const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

// 1. Notify all users when a new tournament is created
exports.onTournamentCreated = functions.firestore
    .document("tournaments/{tournamentId}")
    .onCreate((snap, context) => {
        const tournament = snap.data();
        const payload = {
            notification: {
                title: "New Tournament Alert! 🎮",
                body: `${tournament.title} is now open for registration!`,
            },
            topic: "all_users",
        };

        return admin.messaging().send(payload)
            .then((response) => {
                console.log("Successfully sent message:", response);
            })
            .catch((error) => {
                console.log("Error sending message:", error);
            });
    });

// 2. Notify Admin when a new Wallet Request is created
exports.onWalletRequestCreated = functions.firestore
    .document("wallet_requests/{requestId}")
    .onCreate((snap, context) => {
        const request = snap.data();
        const payload = {
            notification: {
                title: "New Wallet Request 💰",
                body: `User requested ₹${request.amount} top-up via UTR: ${request.utr}`,
            },
            topic: "admin_notifications",
        };

        return admin.messaging().send(payload)
            .then((response) => {
                console.log("Successfully sent message:", response);
            })
            .catch((error) => {
                console.log("Error sending message:", error);
            });
    });

// 3. Notify Admin when a new Withdrawal Request is created
exports.onWithdrawalRequestCreated = functions.firestore
    .document("withdrawal_requests/{requestId}")
    .onCreate((snap, context) => {
        const request = snap.data();
        const payload = {
            notification: {
                title: "New Withdrawal Request 💸",
                body: `User requested withdrawal of ₹${request.amount}`,
            },
            topic: "admin_notifications",
        };

        return admin.messaging().send(payload)
            .then((response) => {
                console.log("Successfully sent message:", response);
            })
            .catch((error) => {
                console.log("Error sending message:", error);
            });
    });

// 4. Notify User when Wallet Request status changes
exports.onWalletRequestUpdated = functions.firestore
    .document("wallet_requests/{requestId}")
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const previousData = change.before.data();

        if (newData.status === previousData.status) return null;

        const userId = newData.userId;
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
            console.log("No FCM token for user:", userId);
            return null;
        }

        const payload = {
            notification: {
                title: "Wallet Request Update",
                body: `Your wallet request for ₹${newData.amount} has been ${newData.status}.`,
            },
            token: fcmToken,
        };

        return admin.messaging().send(payload)
            .then((response) => {
                console.log("Successfully sent message:", response);
            })
            .catch((error) => {
                console.log("Error sending message:", error);
            });
    });

// 5. Notify User when Withdrawal Request status changes
exports.onWithdrawalRequestUpdated = functions.firestore
    .document("withdrawal_requests/{requestId}")
    .onUpdate(async (change, context) => {
        const newData = change.after.data();
        const previousData = change.before.data();

        if (newData.status === previousData.status) return null;

        const userId = newData.userId;
        const userDoc = await admin.firestore().collection("users").doc(userId).get();
        const fcmToken = userDoc.data().fcmToken;

        if (!fcmToken) {
            console.log("No FCM token for user:", userId);
            return null;
        }

        const payload = {
            notification: {
                title: "Withdrawal Request Update",
                body: `Your withdrawal request for ₹${newData.amount} has been ${newData.status}.`,
            },
            token: fcmToken,
        };

        return admin.messaging().send(payload)
            .then((response) => {
                console.log("Successfully sent message:", response);
            })
            .catch((error) => {
                console.log("Error sending message:", error);
            });
    });
