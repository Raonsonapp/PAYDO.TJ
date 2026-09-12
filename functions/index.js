/**
 * PAYDO.TJ — Cloud Functions (PHASE 15: Notifications)
 *
 * ЯГОНА масъулияти ин файл: вақте документи нав дар `notifications/{id}`
 * сохта мешавад (аз client, ниг. lib/features/notifications/), fcmToken-и
 * гирандаро аз `users/{recipientId}` хонда, паёми воқеии FCM push
 * мефиристад.
 *
 * Чаро ин лозим аст: Flutter client (SDK-и corbар) наметавонад push-ро
 * ба корбари ДИГАР бевосита фиристад — ин коре аст, ки танҳо
 * backend/Admin SDK карда метавонад (санади амниятии худи Firebase).
 * Бинобар ин ин Cloud Function "пул" аст: Firestore write (аз client,
 * ройгон) → Cloud Function (сервер) → FCM push.
 *
 * ДЕПЛОЙ:
 *   cd functions && npm install
 *   firebase deploy --only functions
 *
 * ТАЛАБОТ: Firebase-и шумо бояд дар нақшаи Blaze (pay-as-you-go) бошад
 * — Cloud Functions (2nd gen) ин талаботи худи Google Cloud аст, ҳатто
 * агар истифодаи воқеӣ дар квотаи ройгон монад (барои барномаи хурд то
 * миёна маъмулан рояг). Тавзеҳи пурра: docs/notifications.md
 */

const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");

initializeApp();

exports.sendPushOnNotificationCreated = onDocumentCreated(
    "notifications/{notificationId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;

      const notification = snap.data();
      const recipientId = notification.recipientId;
      if (!recipientId) return;

      // fcmToken-и гиранда аз профили корбар (PHASE 15: UserModel.fcmToken).
      const userDoc = await getFirestore()
          .collection("users")
          .doc(recipientId)
          .get();

      const fcmToken = userDoc.exists ? userDoc.data().fcmToken : null;
      if (!fcmToken) {
        console.log(`Корбари ${recipientId} fcmToken надорад — push нест.`);
        return;
      }

      try {
        await getMessaging().send({
          token: fcmToken,
          notification: {
            title: notification.title || "PAYDO.TJ",
            body: notification.body || "",
          },
          data: {
            contextType: notification.contextType || "",
            contextId: notification.contextId || "",
            type: notification.type || "system",
          },
          android: {priority: "high"},
          apns: {
            payload: {
              aps: {sound: "default"},
            },
          },
        });
      } catch (error) {
        // Хатогии маъмултарин: fcmToken-и кӯҳна/бекоршуда (корбар
        // барномаро uninstall кардааст). Критикӣ нест — сабт мекунем.
        console.error(`Хатогии фиристодани push ба ${recipientId}:`, error);
      }
    },
);
