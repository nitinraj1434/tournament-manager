const { Client, LocalAuth, MessageMedia } = require('whatsapp-web.js');
const qrcode = require('qrcode-terminal');
const admin = require('firebase-admin');
const path = require('path');
require('dotenv').config();

// Initialize Express for Render/Railway Port Binding
const express = require('express');
const app = express();
const port = process.env.PORT || 8080;

// Global state for Pairing Code (for Render Web View)
let currentPairingCode = null;

app.get('/', (req, res) => {
    if (currentPairingCode) {
        res.send(`
            <div style="font-family: sans-serif; text-align: center; padding: 50px; background: #121212; color: white; height: 100vh;">
                <h1 style="color: #25D366;">WhatsApp Bot Pairing</h1>
                <p>Enter this code on your phone:</p>
                <div style="font-size: 48px; font-weight: bold; background: #1e1e1e; display: inline-block; padding: 20px 40px; border-radius: 10px; border: 2px solid #25D366; margin: 20px 0; letter-spacing: 5px;">
                    ${currentPairingCode}
                </div>
                <div style="text-align: left; max-width: 400px; margin: 0 auto; line-height: 1.6;">
                    <p>1. Open WhatsApp > Linked Devices</p>
                    <p>2. Link a Device > <b>Link with phone number instead</b></p>
                    <p>3. Enter the code above.</p>
                </div>
                <p style="margin-top: 30px; font-size: 12px; color: #888;">Refreshing in 30 seconds...</p>
                <script>setTimeout(() => location.reload(), 30000);</script>
            </div>
        `);
    } else {
        res.send(`
            <div style="font-family: sans-serif; text-align: center; padding: 50px; background: #121212; color: white; height: 100vh;">
                <h1 style="color: #25D366;">OP ESPORTS Bot</h1>
                <p>Status: ${client?.info?.wid ? '✅ Connected' : '⏳ Waiting for connection...'}</p>
                <p>If you are linking for the first time, check logs or wait for the pairing code to appear here.</p>
                <script>setTimeout(() => location.reload(), 10000);</script>
            </div>
        `);
    }
});

app.listen(port, () => {
    console.log(`[SERVER] listening on port ${port}`);
});

// Initialize Firebase Admin
const serviceAccount = require("./serviceAccountKey.json");
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount),
    // databaseURL: "https://harsh-b7193-default-rtdb.firebaseio.com" // RTDB not needed for Firestore
});
const db = admin.firestore();

// Admin configuration
const ADMIN_NUMBER = '+919798365598'; // Admin number from profile screenshot

const client = new Client({
    authStrategy: new LocalAuth(),
    puppeteer: {
        args: [
            '--no-sandbox',
            '--disable-setuid-sandbox',
            '--disable-dev-shm-usage',
            '--disable-accelerated-2d-canvas',
            '--no-first-run',
            '--no-zygote',
            '--single-process', // <- Reduces memory usage significantly
            '--disable-gpu'
        ],
        headless: true
    }
});

// Use Pairing Code for Web/Render deployments (Easier than QR)
const usePairingCode = true; // Force pairing code

let isPairingRequested = false;
client.on('qr', async (qr) => {
    if (usePairingCode) {
        if (!isPairingRequested) {
            isPairingRequested = true;
            console.log('------------------------------------------------');
            console.log('QR Received. Attempting to generate Pairing Code for:', ADMIN_NUMBER);
            console.log('Please wait about 6 seconds...');
            console.log('------------------------------------------------');

            // Wait a bit (6s) for the client to be ready for pairing code request
            setTimeout(async () => {
                try {
                    console.log('Requesting Pairing Code now...');
                    const cleanNumber = ADMIN_NUMBER.replace(/\D/g, '');
                    const code = await client.requestPairingCode(cleanNumber);

                    // SAVE TO GLOBAL FOR WEB VIEW
                    currentPairingCode = code;

                    console.log('\n================================================');
                    console.log('      YOUR PAIRING CODE: ' + code);
                    console.log('================================================\n');
                    console.log('1. Open WhatsApp on your phone');
                    console.log('2. Tap Menu or Settings > Linked Devices');
                    console.log('3. Tap Link a Device > Link with phone number instead');
                    console.log('4. Enter the code above');
                    console.log('------------------------------------------------\n');
                } catch (e) {
                    console.error('Failed to get pairing code:', e.message);
                    console.log('FALLBACK: Showing QR Code instead...');
                    qrcode.generate(qr, { small: true });
                }
            }, 6000);
        }
    } else {
        console.log('SCAN THIS QR CODE WITH YOUR WHATSAPP:');
        qrcode.generate(qr, { small: true });
    }
});

// Clear pairing code on connection
client.on('authenticated', () => {
    console.log('Authenticated successfully!');
    currentPairingCode = null;
});




client.on('ready', () => {
    console.log('WhatsApp Bot is ready and connected!');

    // Listen for new App-based Wallet Requests
    db.collection('wallet_requests')
        .where('status', '==', 'pending')
        .onSnapshot(snapshot => {
            snapshot.docChanges().forEach(async (change) => {
                if (change.type === 'added') {
                    const data = change.doc.data();

                    // Skip if already notified (handled by bot flow or previous run)
                    if (data.adminNotified) return;

                    console.log(`[FIRESTORE] New pending request detected: ${data.utr}`);

                    // Fetch User Details to get Phone Number
                    let userPhone = data.phoneNumber;
                    let userName = 'App User';

                    if (!userPhone && data.userId) {
                        try {
                            const userDoc = await db.collection('users').doc(data.userId).get();
                            if (userDoc.exists) {
                                const userData = userDoc.data();
                                userPhone = normalizePhoneNumber(userData.phoneNumber || userData.phone);
                                userName = userData.name || 'App User';
                                // Store phone for notification later
                                await change.doc.ref.update({ phoneNumber: userPhone });
                            }
                        } catch (e) {
                            console.error("Error fetching user for request:", e);
                        }
                    }

                    // Notify Admin
                    const caption = `📱 *New App Deposit Request*\n\n👤 Name: ${userName}\n📞 Phone: ${userPhone || 'N/A'}\n💰 Amount: ₹${data.amount}\n🔑 UTR: ${data.utr}\n\nReply with:\n*Approve ${data.utr}*\n*Reject ${data.utr}*`;

                    try {
                        const adminId = normalizePhoneNumber(ADMIN_NUMBER);
                        await client.sendMessage(adminId + '@c.us', caption);
                        // Mark as notified
                        await change.doc.ref.update({ adminNotified: true });
                        console.log(`[FIRESTORE] Admin notified for UTR: ${data.utr}`);
                    } catch (e) {
                        console.error("Failed to notify admin for app request:", e);
                    }
                }
            });
        });
});

// Listen for New Withdrawal Requests
db.collection('withdrawal_requests')
    .where('status', '==', 'pending')
    .onSnapshot(snapshot => {
        snapshot.docChanges().forEach(async (change) => {
            if (change.type === 'added') {
                const data = change.doc.data();
                if (data.adminNotified) return;

                let userPhone = data.phoneNumber;
                let userName = 'App User';

                if (!userPhone && data.userId) {
                    try {
                        const userDoc = await db.collection('users').doc(data.userId).get();
                        if (userDoc.exists) {
                            const userData = userDoc.data();
                            userPhone = normalizePhoneNumber(userData.phoneNumber || userData.phone);
                            userName = userData.name || 'App User';
                            await change.doc.ref.update({ phoneNumber: userPhone });
                        }
                    } catch (e) { console.error(e); }
                }

                const msgText = `💸 *New Withdrawal Request*\n\n👤 User: ${userName}\n📞 Phone: ${userPhone || 'N/A'}\n💰 Amount: ₹${data.amount}\nUPI/Details: ${data.details}\n\n🆔 ReqID: ${change.doc.id}\n\nReply to this message with:\n*Paid <UTR>*\n*RejectW <Reason>*`;

                try {
                    const adminId = normalizePhoneNumber(ADMIN_NUMBER);
                    await client.sendMessage(adminId + '@c.us', msgText);
                    await change.doc.ref.update({ adminNotified: true });
                } catch (e) { console.error(e); }
            }
        });
    });

// Simple session store for deposit flow
const userSessions = {};

// Helper to normalize phone numbers
const normalizePhoneNumber = (num) => {
    if (!num) return "";
    let clean = num.replace(/\D/g, ''); // Keep only numbers
    // Heuristic for India: If 10 digits, add 91. If 12 digits starting with 91, keep it.
    if (clean.length === 10) {
        clean = '91' + clean;
    }
    return clean;
};

// Helper: Send Message with Logging
const sendToUser = async (number, content) => {
    try {
        const cleanNumber = normalizePhoneNumber(number);
        console.log(`[NOTIFY] Attempting to send to: ${cleanNumber}@c.us`);
        if (!cleanNumber || cleanNumber.length < 10) {
            console.error(`[NOTIFY] Invalid number: ${number}`);
            return;
        }
        await client.sendMessage(cleanNumber + '@c.us', content);
        console.log(`[NOTIFY] Success!`);
    } catch (e) {
        console.error(`[NOTIFY] Failed to send to ${number}:`, e);
    }
};

client.on('message', async (msg) => {
    if (msg.fromMe) return; // Don't respond to self

    try {
        const chat = await msg.getChat();
        const contact = await msg.getContact();
        const isGroup = chat.isGroup;

        // Identify actual sender number (robust for @lid)
        const senderNumber = normalizePhoneNumber(contact.number || (isGroup ? (msg.author || msg.from) : msg.from).split('@')[0]);
        const adminNumberNorm = normalizePhoneNumber(ADMIN_NUMBER);
        const text = msg.body.toLowerCase().trim();

        const isAdmin = senderNumber === adminNumberNorm;

        const websiteLink = "https://harsh-b7193.web.app/";

        // Helper to reply (Replies in PM if command came from group for privacy)
        const smartReply = async (message) => {
            if (isGroup) {
                await client.sendMessage(msg.author || msg.from, message);
                await msg.reply("🔒 *Privacy Mode:* I've sent the details to your Private Message.");
            } else {
                await msg.reply(message);
            }
        };

        // Variations logic for finding user
        const findUserByNumber = async (number) => {
            console.log(`[FIREBASE] Looking for user: ${number}`);
            const usersRef = db.collection('users');
            const variations = [
                number,
                `+${number}`,
                number.replace('+', ''),
                number.length >= 10 ? number.slice(-10) : number
            ];
            for (const variation of variations) {
                const q = await usersRef.where('phoneNumber', '==', variation).get();
                if (!q.empty) {
                    console.log(`[FIREBASE] FOUND user with variation: ${variation}`);
                    return { ref: q.docs[0].ref, data: q.docs[0].data(), id: q.docs[0].id };
                }
            }
            console.log(`[FIREBASE] User NOT found for: ${number}`);
            return null;
        };

        // State Machine / Session Handling
        const session = userSessions[senderNumber];
        console.log(`[DEBUG] Incoming message from ${senderNumber}. Type: ${msg.type}, hasMedia: ${msg.hasMedia}, Body: ${text.substring(0, 20)}...`);

        // 1. Handle Images (Potential Screenshots)
        if (msg.hasMedia || msg.type === 'image') {
            console.log(`[DEBUG] Attempting to process image from ${senderNumber}`);
            const user = await findUserByNumber(senderNumber);

            if (!user) {
                console.log(`[DEBUG] User NOT found for number: ${senderNumber}`);
                await msg.reply(`📸 *Photo Received!* \n\nLekin aapka number (${senderNumber}) humare system mein registered nahi hai. \n\nKripya app Download karein aur apne profile mein number update karein: ${websiteLink}`);
                return;
            }

            console.log(`[DEBUG] User found: ${user.id}. Attempting media download...`);
            try {
                const media = await msg.downloadMedia();
                if (media) {
                    console.log(`[DEBUG] Media downloaded. Mimetype: ${media.mimetype}`);
                    userSessions[senderNumber] = {
                        state: 'AWAITING_UTR',
                        media: media,
                        timestamp: Date.now()
                    };
                    await msg.reply("✅ *Screenshot Recorded!* \n\nAb kripya is payment ka *Transaction ID (UTR)* type karke bhejein.");
                } else {
                    console.log(`[DEBUG] downloadMedia() returned null or undefined`);
                    await msg.reply("⚠️ Photo download nahi ho saki. Kripya use as a 'Document' na bhejien, normal 'Photos' ki tarah bhejien.");
                }
                return;
            } catch (e) {
                console.error("[DEBUG] Media download CRASH:", e);
                await msg.reply("⚠️ Technical error: Screenshot download nahi ho saka. Kripya dobara bhejien.");
                return;
            }
        }

        // 2. Handle Flow States (UTR -> AMOUNT)
        if (session) {
            if (session.state === 'AWAITING_UTR') {
                const utr = text.toUpperCase();
                if (utr.length < 6) {
                    await msg.reply("❌ Invalid UTR. Please enter a valid Transaction ID.");
                } else {
                    session.utr = utr;
                    session.state = 'AWAITING_AMOUNT';
                    await msg.reply("💰 Almost done! Please enter the *Amount* you paid (e.g., 50).");
                }
                return;
            }
            else if (session.state === 'AWAITING_AMOUNT') {
                const amount = parseFloat(text);
                if (isNaN(amount) || amount < 5) {
                    await msg.reply("❌ Please enter a valid amount (Minimum ₹5).");
                } else {
                    const user = await findUserByNumber(senderNumber);
                    const utr = session.utr;

                    // Create Wallet Request
                    await db.collection('wallet_requests').add({
                        userId: user.id || senderNumber,
                        amount: amount,
                        utr: utr,
                        status: 'pending',
                        timestamp: new Date(),
                        via: 'whatsapp',
                        phoneNumber: senderNumber,
                        adminNotified: true // Mark as notified since we send msg below
                    });

                    // Forward to Admin
                    const caption = `📌 *New Deposit Request*\n\n👤 User: @${senderNumber}\n💰 Amount: ₹${amount}\n🔑 UTR: ${utr}\n\nReview screenshot below.\n\nReply with:\n*Approve ${utr}*\n*Reject ${utr}*`;
                    await client.sendMessage(ADMIN_NUMBER.replace('+', '') + '@c.us', session.media, { caption: caption });

                    delete userSessions[senderNumber];
                    await msg.reply(`✅ *Request Submitted!* \n\nAmount: ₹${amount}\nUTR: ${utr}\n\nBot ne screenshot admin ko bhej diya hai. 5-30 mins mein verify ho jayega.`);
                }
                return;
            } else if (session.state === 'WITHDRAW_AMOUNT') {
                const amount = parseFloat(text);
                if (isNaN(amount) || amount < 10) {
                    await msg.reply("❌ Invalid Amount. Minimum withdrawal is ₹10.");
                } else {
                    const user = await findUserByNumber(senderNumber);
                    const currentBalance = user.data.walletBalance || 0;
                    if (amount > currentBalance) {
                        await msg.reply(`❌ *Insufficient Funds!* \nYour Balance: ₹${currentBalance}`);
                        delete userSessions[senderNumber];
                    } else {
                        session.amount = amount;
                        session.state = 'WITHDRAW_DETAILS';
                        await msg.reply("🏧 Please enter your *UPI ID* or *Bank Details* for the transfer.");
                    }
                }
                return;
            } else if (session.state === 'WITHDRAW_DETAILS') {
                const details = msg.body.trim();
                const amount = session.amount;
                const user = await findUserByNumber(senderNumber);

                // Deduct Balance & Create Request
                try {
                    await db.runTransaction(async (t) => {
                        const userRef = user.ref;
                        const userDoc = await t.get(userRef);
                        const newBalance = (userDoc.data().walletBalance || 0) - amount;

                        if (newBalance < 0) throw new Error("Insufficient Funds during transaction");

                        t.update(userRef, { walletBalance: newBalance });
                        const reqRef = db.collection('withdrawal_requests').doc();
                        t.set(reqRef, {
                            userId: user.id || senderNumber,
                            amount: amount,
                            details: details,
                            status: 'pending',
                            timestamp: new Date(),
                            via: 'whatsapp',
                            phoneNumber: senderNumber,
                            adminNotified: true
                        });
                        // Retrieve ID for notification
                        session.reqId = reqRef.id;
                    });

                    await msg.reply(`✅ *Withdrawal Requested!* \nChecking Balance... Deducted!\n\n₹${amount} will be wired to ${details}.\nPlease wait for Admin processing.`);

                    // Notify Admin
                    try {
                        const adminId = normalizePhoneNumber(ADMIN_NUMBER);
                        const msgText = `💸 *New Withdrawal Request (WA)*\n\n👤 User: @${senderNumber}\n💰 Amount: ₹${amount}\nUPI: ${details}\n\n🆔 ReqID: ${session.reqId}\n\nReply with:\n*Paid <UTR>*\n*RejectW <Reason>*`;
                        await client.sendMessage(adminId + '@c.us', msgText);
                    } catch (e) { console.error(e); }

                    delete userSessions[senderNumber];

                } catch (e) {
                    console.error(e);
                    await msg.reply("❌ Error processing withdrawal. Please try again.");
                    delete userSessions[senderNumber];
                }
                return;
            }
        }

        // Handle Admin Commands (Approve/Reject)
        if (isAdmin) {
            console.log(`[ADMIN] Command attempt: '${text}'`);

            // Handle "Approve" without UTR
            if (text === 'approve') {
                await msg.reply("⚠️ Please specify the UTR.\nFormat: *Approve <UTR>*");
                return;
            }

            if (text.startsWith('approve')) { // Removed space to catch 'approve123' etc too
                const utr = text.replace('approve', '').trim().toUpperCase();
                console.log(`[ADMIN] Processing approval for UTR: ${utr}`);

                if (!utr) {
                    await msg.reply("⚠️ Missing UTR. Usage: *Approve <UTR>*");
                    return;
                }

                const requestsRef = db.collection('wallet_requests');
                const q = await requestsRef.where('utr', '==', utr).where('status', '==', 'pending').get();

                if (q.empty) {
                    await msg.reply(`❌ No pending request found with UTR: ${utr}`);
                } else {
                    const reqDoc = q.docs[0];
                    const reqData = reqDoc.data();

                    await db.runTransaction(async (transaction) => {
                        const userRef = db.collection('users').doc(reqData.userId);
                        const userSnap = await transaction.get(userRef);
                        const currentBalance = userSnap.data().walletBalance || 0;

                        transaction.update(reqDoc.ref, { status: 'approved' });
                        transaction.update(userRef, { walletBalance: currentBalance + reqData.amount });

                        const txnRef = db.collection('transactions').doc();
                        transaction.set(txnRef, {
                            userId: reqData.userId,
                            amount: reqData.amount,
                            type: 'credit',
                            status: 'success',
                            timestamp: admin.firestore.FieldValue.serverTimestamp(),
                            label: 'Wallet Topup (WA)',
                        });
                    });

                    await msg.reply(`✅ Approved! ₹${reqData.amount} added to user's wallet.`);
                    // Notify User
                    try {
                        const targetNumber = normalizePhoneNumber(reqData.phoneNumber || reqData.userId);
                        await client.sendMessage(targetNumber + '@c.us', `🎉 *Deposit Approved!* \n\n₹${reqData.amount} has been successfully added to your wallet.\n\nHappy Gaming! 🎮`);
                    } catch (e) {
                        console.error("Failed to notify user:", e);
                    }
                }
                return;
            }
            if (text.startsWith('reject ')) {
                const utr = text.replace('reject ', '').trim().toUpperCase();
                const q = await db.collection('wallet_requests').where('utr', '==', utr).get();
                if (!q.empty) {
                    const reqDoc = q.docs[0];
                    const reqData = reqDoc.data();

                    await reqDoc.ref.update({ status: 'rejected' });
                    await msg.reply(`❌ Request ${utr} rejected.`);

                    // Notify User
                    try {
                        const targetNumber = normalizePhoneNumber(reqData.phoneNumber || reqData.userId);
                        await client.sendMessage(targetNumber + '@c.us', `❌ *Deposit Rejected* \n\nTransaction ID: ${utr}\nReason: Invalid UTR or Screenshot.\n\nPlease contact support if this is a mistake.`);
                    } catch (e) {
                        console.error("Failed to notify user:", e);
                    }
                }
                return;
            }

            // Handle Withdrawal Admin Logic (Paid/RejectW)
            // Handle Withdrawal Admin Logic (Paid/RejectW)
            if (text.startsWith('paid ') || text.startsWith('rejectw ')) {
                if (!msg.hasQuotedMsg) {
                    await msg.reply("⚠️ Please reply to the *Withdrawal Request* message when using this command.");
                    return;
                }
                const quotedMsg = await msg.getQuotedMessage();
                const match = quotedMsg.body.match(/ReqID: (\w+)/);

                if (!match || !match[1]) {
                    await msg.reply("⚠️ Could not find Request ID in the quoted message.");
                    return;
                }

                const reqId = match[1];
                const wRef = db.collection('withdrawal_requests').doc(reqId);

                if (text.startsWith('paid ')) {
                    const utr = text.replace('paid ', '').trim();
                    const wDoc = await wRef.get();

                    if (wDoc.exists && wDoc.data().status === 'pending') {
                        await wRef.update({ status: 'approved', adminNote: utr });
                        await msg.reply(`✅ Withdrawal marked as PAID. UTR: ${utr}`);

                        // Notify User
                        const wData = wDoc.data();
                        let targetNumber = normalizePhoneNumber(wData.phoneNumber || wData.phone);

                        // Fallback logic
                        if (!targetNumber || targetNumber.length < 10) {
                            console.log(`[NOTIFY] Phone missing in request ${reqId}, fetching user profile...`);
                            try {
                                const u = await db.collection('users').doc(wData.userId).get();
                                if (u.exists) {
                                    targetNumber = normalizePhoneNumber(u.data().phoneNumber || u.data().phone);
                                }
                            } catch (e) { console.error("Profile fetch fail", e); }
                        }

                        if (targetNumber) {
                            await sendToUser(targetNumber, `🏧 *Withdrawal Processed!* \n\nAmount: ₹${wData.amount}\nUTR: ${utr}\n\nMoney sent to your account. Enjoy! 💸`);
                        } else {
                            console.error(`[NOTIFY] Could not find any number for user ${wData.userId}`);
                            await msg.reply("⚠️ Warning: Could not find user number to notify.");
                        }

                    } else {
                        await msg.reply("⚠️ Request not found or already processed.");
                    }
                }
                else if (text.startsWith('rejectw ')) {
                    const reason = text.replace('rejectw ', '').trim();
                    const wDoc = await wRef.get();

                    if (wDoc.exists && wDoc.data().status === 'pending') {
                        const wData = wDoc.data(); // Capture data before update just in case

                        await db.runTransaction(async (t) => {
                            const userRef = db.collection('users').doc(wData.userId);
                            const userDoc = await t.get(userRef);
                            const currentBal = userDoc.data().walletBalance || 0;
                            t.update(userRef, { walletBalance: currentBal + wData.amount });
                            t.update(wRef, { status: 'rejected', adminNote: reason });
                        });
                        await msg.reply("✅ Withdrawal Message Rejected & Refunded.");

                        // Notify User
                        let targetNumber = normalizePhoneNumber(wData.phoneNumber);
                        if (!targetNumber || targetNumber.length < 10) {
                            try {
                                const u = await db.collection('users').doc(wData.userId).get();
                                if (u.exists) {
                                    targetNumber = normalizePhoneNumber(u.data().phoneNumber || u.data().phone);
                                }
                            } catch (e) { }
                        }

                        if (targetNumber) {
                            await sendToUser(targetNumber, `❌ *Withdrawal Rejected* \n\nAmount: ₹${wData.amount}\nReason: ${reason}\n\nAmount refunded to wallet.`);
                        }
                    }
                }
                return;
            }
        }

        // Handle Specific Commands
        if (text === '1' || text === 'balance') {
            const user = await findUserByNumber(senderNumber);
            if (user) {
                const balance = user.data.walletBalance || 0;
                await smartReply(`💰 *User:* ${user.data.name || 'Gamer'}\n📏 *Game ID:* ${user.data.gameUid || 'Not Set'}\n💰 *Balance:* ₹${balance}\n\nKeep playing and winning! 🏆\n\n🌐 *Download App:* ${websiteLink}`);
            } else {
                await msg.reply(`❌ Sorry, I couldn't find a user registered with ${senderNumber} on our App.\n\nKripya Play Store se "OP ESPORTS" download karein.`);
            }
        }
        else if (text === '4' || text === 'withdrawal' || text === 'withdraw') {
            const user = await findUserByNumber(senderNumber);
            if (user) {
                await msg.reply(`🏧 *Withdrawal Request*\n\nYour Balance: ₹${user.data.walletBalance || 0}\n\nPlease enter the *Amount* you want to withdraw.`);
                userSessions[senderNumber] = { state: 'WITHDRAW_AMOUNT' };
            } else {
                await msg.reply("❌ Profile not found.");
            }
        }
        else if (text === '2' || text === 'tournaments') {
            try {
                const tournamentsRef = db.collection('tournaments');
                const snapshot = await tournamentsRef.where('status', '==', 'published').get();

                if (snapshot.empty) {
                    await msg.reply(`📅 No upcoming tournaments found.\n\n🌐 *Download App:* ${websiteLink}`);
                } else {
                    const tournaments = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
                    tournaments.sort((a, b) => (a.date?.seconds || 0) - (b.date?.seconds || 0));

                    let tournamentList = '*Upcoming Tournaments:* 🎮\n\n';
                    tournaments.slice(0, 5).forEach((data, index) => {
                        const date = data.date ? new Date(data.date.seconds * 1000).toLocaleString() : 'TBD';
                        const availableSlots = (data.slots || 0);
                        tournamentList += `${index + 1}. *${data.title}*\n   📅 Date: ${date}\n   💰 Prize: ₹${data.prize || 'TBD'}\n   🎟️ Fee: ₹${data.entryFee || 0}\n   👥 Slots Left: *${availableSlots}*\n   📝 Reply *Join ${index + 1}* to participate.\n\n`;
                    });
                    tournamentList += `🌐 *Download App:* ${websiteLink}`;
                    await smartReply(tournamentList);
                    // Save for Join command
                    userSessions[senderNumber] = { type: 'TOURNAMENT_LIST', data: tournaments.slice(0, 5) };
                }
            } catch (error) {
                console.error('Tournament Fetch Error:', error);
                throw error;
            }
        }
        else if (text.startsWith('join ')) {
            const index = parseInt(text.replace('join ', '')) - 1;
            const session = userSessions[senderNumber];

            if (session && session.type === 'TOURNAMENT_LIST' && session.data[index]) {
                const tournament = session.data[index];
                const user = await findUserByNumber(senderNumber);

                if (!user) {
                    await msg.reply("❌ User not found. Please register in the app first.");
                    return;
                }

                if (user.data.walletBalance < tournament.entryFee) {
                    await msg.reply(`❌ *Insufficient Balance!* \n\nEntry Fee: ₹${tournament.entryFee}\nYour Balance: ₹${user.data.walletBalance}\n\nType *Deposit* to add funds.`);
                } else if (tournament.slots <= 0) {
                    await msg.reply("❌ Sorry, this tournament is already full!");
                } else if (user.data.gameUid === "" || user.data.gameName === "") {
                    await msg.reply("❌ *Profile Incomplete!* \n\nPlease update your Game UID and Name in the app profile before joining.");
                } else {
                    // Start Join Transaction
                    try {
                        await db.runTransaction(async (transaction) => {
                            const tRef = db.collection('tournaments').doc(tournament.id);
                            const tSnap = await transaction.get(tRef);
                            const currentSlots = tSnap.data().slots || 0;
                            const participants = tSnap.data().participants || [];

                            if (participants.includes(user.id)) throw new Error("ALREADY_JOINED");
                            if (currentSlots <= 0) throw new Error("FULL");

                            transaction.update(tRef, {
                                slots: currentSlots - 1,
                                participants: admin.firestore.FieldValue.arrayUnion(user.id)
                            });

                            transaction.update(user.ref, {
                                walletBalance: user.data.walletBalance - tournament.entryFee
                            });

                            const entryRef = db.collection('entries').doc(`${tournament.id}_${user.id}`);
                            transaction.set(entryRef, {
                                tournamentId: tournament.id,
                                userId: user.id,
                                status: 'confirmed',
                                paidAmount: tournament.entryFee,
                                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                            });

                            const txnRef = db.collection('transactions').doc();
                            transaction.set(txnRef, {
                                userId: user.id,
                                amount: tournament.entryFee,
                                type: 'debit',
                                status: 'success',
                                timestamp: admin.firestore.FieldValue.serverTimestamp(),
                                label: `Entry: ${tournament.title}`,
                            });
                        });
                        await msg.reply(`🎉 *Success!* \n\nYou have joined *${tournament.title}*.\n\nRoom Details will be shared in the app 15 mins before the match.`);
                    } catch (e) {
                        if (e.message === "ALREADY_JOINED") await msg.reply("✅ You have already joined this tournament!");
                        else if (e.message === "FULL") await msg.reply("❌ Oops! The tournament just became full.");
                        else throw e;
                    }
                }
            } else {
                await msg.reply("❌ Invalid selection. Please check the tournament list again.");
            }
        }
        else if (text === '3' || text === 'deposit') {
            try {
                const qrPath = path.resolve(__dirname, '../assets/images/payment_qr.jpg');
                const media = MessageMedia.fromFilePath(qrPath);
                await client.sendMessage(msg.from, media, { caption: "💸 *Deposit Funds*\n\n1. Scan this QR to pay.\n2. Send a screenshot of the payment here.\n3. Type your Transaction ID (UTR).\n\nMin Deposit: ₹10" });
            } catch (e) {
                console.error("Failed to send QR:", e);
                await msg.reply("⚠️ Sorry, I couldn't load the payment QR right now. Please check the app.");
            }
        }
        else if (text === '5' || text === 'support') {
            await msg.reply(`I have notified our support team. An agent will get back to you shortly. ⏳\n\nFor faster response, please describe your issue here.\n\n🌐 *Download App:* ${websiteLink}`);
            console.log(`Support requested by ${senderNumber}`);
        }
        // Universal Responder
        else {
            if (isAdmin) return; // Don't show menu to admin for unknown commands to avoid spamming self logic
            const helpMenu = `
*Available Commands:*
1. *Balance* - Check your wallet balance
2. *Tournaments* - See upcoming tournaments
3. *Deposit* - Add money to wallet
4. *Withdrawal* - Information about withdrawals
5. *Support* - Connect with an agent

🌐 *Download App:* ${websiteLink}

Reply with the command name or number.
            `;
            const welcomeMsg = `Hello! 👋 Welcome to *OP ESPORTS* Support.\n\n` + helpMenu;
            await msg.reply(welcomeMsg);
        }

    } catch (error) {
        console.error('Critical Error in Bot Logic:', error);
        try {
            await msg.reply("Sorry, I'm experiencing some technical difficulties. Please try again or visit our website: https://harsh-b7193.web.app/");
        } catch (e) {
            console.error('Failed to send error fallback:', e);
        }
    }
});

client.initialize();
