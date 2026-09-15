# Reviews — PHASE 16

## Пешгирии баҳои такрорӣ (banди 20)

`reviews/{reviewId}` documentId ДЕТЕРМИНИСТӢ аст:
`{contextId}_{targetType}_{targetId}` — contextId = orderId (маҳсулот/
бизнес/courier) ё serviceOrderId (хизматрасон)-и **анҷомёфта**. Азбаски
ҳар order/serviceOrder ба ЯК customerId тааллуқ дорад, ин ба таври
табиӣ "ин харидор аллакай барои ин фармоиш ба ин target баҳо додааст"
-ро пешгирӣ мекунад — ҳамон мантиқи `favorites`/`chats`/
`job_applications`/`deliveries` (docId-и детерминистӣ ба ҷои query).

## Ҳисоби миёнаи rating — чаро дар Cloud Function, на дар client

Қарори муҳими тарроҳӣ: **client ҳаргиз бевосита `rating`/
`reviewsCount`-и product/business/service/courier-ро наменависад.**

Агар менависонд, ҳама корбар (на танҳо соҳиби profile) бояд иҷозати
"update" дар Security Rules медошт — ки маънои онро дошт, ки ягон
корбари бадният метавонист rating-ро бе ягон баҳои воқеӣ (масалан
`rating: 5.0, reviewsCount: 999`) бевосита бинависад, зеро Security
Rules наметавонанд санҷанд "ин навсозӣ воқеан аз як documenти
`reviews` мустақил меояд".

Бинобар ин:

1. **Client** (`ReviewRepositoryImpl.submitReview`) танҳо документи
   `reviews/{id}`-ро месозад. Ҳамин қадар.
2. **Cloud Function** `recalculateRatingOnReviewCreated`
   (`functions/index.js`) ба сохтани ҳар review гӯш медиҳад, бо
   **Admin SDK** (ки аз Security Rules мегузарад — коди боэътимоди
   сервер) rating/reviewsCount-и targetро дар транзаксия аз нав ҳисоб
   мекунад.
3. `firestore.rules`-и `products`/`businesses`/`services`/`couriers`
   **бетағйир монданд** (танҳо соҳиб метавонад "update" кунад) — client
   ҳеҷ гоҳ роҳи қонунӣ барои навсозии rating надорад, ба ҷуз аз
   тариқи фиристодани review-и воқеӣ.

Ин ҳамон намуди қарор аст, ки дар PHASE 15 барои push (Cloud Function
ҳамчун "пул"-и боэътимод байни client ва амали ҳассос) гирифта шуда
буд.

## Формулаи ҳисоб

```
newRating = ((oldRating × oldCount) + newReviewRating) / (oldCount + 1)
newCount  = oldCount + 1
```

Дар транзаксия (race condition-safe — агар 2 корбар ҳамзамон баҳо
диҳанд, Firestore транзаксияро такрор мекунад то бе низоъ анҷом ёбад).

## Насб

Cloud Function-и нав дар ҳамон `functions/index.js`-и PHASE 15 аст —
насби иловагӣ лозим нест агар шумо аллакай `firebase deploy --only
functions`-ро иҷро карда бошед (ниг. `docs/notifications.md`). Пас аз
илова кардани ин функсия, боз як бор деплой кунед:

```bash
firebase deploy --only functions
```

## Ҳадафҳои баҳо (banди 20)

| Ҳадаф | targetId = | Ҷои "Баҳо додан" |
|---|---|---|
| Маҳсулот | productId | `OrderHistoryScreen` (order анҷомёфта) |
| Бизнес | businessId (= ownerId) | ҳамон ҷо, агар маҳсулот ба бизнес тааллуқ дошта бошад |
| Хизматрасон | provider uid | `MyServiceOrdersScreen` (дархости анҷомёфта) |
| Courier | courier uid | `OrderHistoryScreen`, агар delivery.status=delivered |

"Seller" (бе Business Profile) баҳо намегирад — танҳо худи маҳсулоти
ӯ (ниг. эзоҳи тарроҳӣ дар `lib/models/review_model.dart`).
