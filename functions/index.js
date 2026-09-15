/**
 * PAYDO.TJ — Cloud Functions
 *
 * PHASE 15 (Notifications): sendPushOnNotificationCreated
 * PHASE 16 (Reviews): recalculateRatingOnReviewCreated
 *
 * Чаро ду вазифаи алоҳида дар як файл: ҳарду хурданд ва
 * якмасъулиятӣ (single-responsibility) — ба ҷои сохтани project-и
 * алоҳида барои ҳар кадом, як `functions/index.js` бо 2 export кофист.
 *
 * ДЕПЛОЙ:
 *   cd functions && npm install
 *   firebase deploy --only functions
 *
 * ТАЛАБОТ: Firebase-и шумо бояд дар нақшаи Blaze (pay-as-you-go) бошад
 * — Cloud Functions (2nd gen) ин талаботи худи Google Cloud аст, ҳатто
 * агар истифодаи воқеӣ дар квотаи ройгон монад (барои барномаи хурд то
 * миёна маъмулан рояг). Тавзеҳи пурра: docs/notifications.md, docs/reviews.md
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

// Мутобиқати targetType (Dart enum ReviewTargetType.value) ба номи
// коллексия — бояд бо lib/models/review_model.dart (targetCollection
// getter) синхрон бошад.
const TARGET_COLLECTIONS = {
  product: "products",
  business: "businesses",
  serviceProvider: "services",
  courier: "couriers",
};

/**
 * PHASE 16 (Ratings/Reviews): ҳар вақте документи нав дар
 * `reviews/{reviewId}` сохта мешавад (аз client — ниг.
 * lib/features/reviews/data/review_repository_impl.dart), ин функсия
 * rating/reviewsCount-и target (маҳсулот/бизнес/хизматрасон/courier)-ро
 * дар транзаксия аз нав ҳисоб мекунад.
 *
 * Чаро дар Cloud Function, на дар client: Security Rules-и
 * products/businesses/services/couriers ФАҚАТ ба соҳиб иҷозати
 * "update" медиҳанд (ниг. firestore.rules) — агар мо client-ро
 * иҷозат медодем rating-ро бевосита нависад, ягон корбари бадният
 * метавонист rating-ро бе баҳои воқеӣ дасткорӣ кунад. Admin SDK-и
 * Cloud Function аз Security Rules мегузарад (боэътимод аст, зеро
 * коди сервер аст, на client), бинобар ин ин ягона ҷои дурусти
 * навсозии rating мебошад.
 */
exports.recalculateRatingOnReviewCreated = onDocumentCreated(
    "reviews/{reviewId}",
    async (event) => {
      const snap = event.data;
      if (!snap) return;

      const review = snap.data();
      const targetType = review.targetType;
      const targetId = review.targetId;
      const rating = review.rating;

      const collectionName = TARGET_COLLECTIONS[targetType];
      if (!collectionName || !targetId || typeof rating !== "number") {
        console.log(`Review-и нодуруст (${event.params.reviewId}) — сарфи назар карда шуд.`);
        return;
      }

      const targetRef = getFirestore().collection(collectionName).doc(targetId);

      await getFirestore().runTransaction(async (transaction) => {
        const targetSnap = await transaction.get(targetRef);
        if (!targetSnap.exists) {
          console.log(`Target ${collectionName}/${targetId} ёфт нашуд.`);
          return;
        }

        const data = targetSnap.data();
        const oldRating = typeof data.rating === "number" ? data.rating : 0;
        const oldCount = typeof data.reviewsCount === "number" ? data.reviewsCount : 0;

        const newCount = oldCount + 1;
        const newRating = ((oldRating * oldCount) + rating) / newCount;

        transaction.update(targetRef, {
          rating: Math.round(newRating * 100) / 100,
          reviewsCount: newCount,
        });
      });
    },
);
