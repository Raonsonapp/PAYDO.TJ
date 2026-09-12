# Notifications — PHASE 15

## Меъморӣ: ду қабат

1. **In-app notification center** (кор мекунад фавран, бе танзими
   иловагӣ): ҳар амали муҳим (фармоиши нав, тағйири status, хабари
   чат, ариза, таъини courier, доставка) документи нав дар
   `notifications/{id}` месозад. `NotificationsScreen` онро real-time
   нишон медиҳад (мисли chat — Firestore listener, на push).

2. **Push-и воқеии FCM** (корбарро огоҳ мекунад ҳатто вақте барнома
   пӯшида аст): ба **Cloud Function** ниёз дорад, зеро Flutter client
   (SDK-и корбар) наметавонад push-ро ба корбари дигар бевосита
   фиристад — ин маҳдудияти амниятии худи Firebase аст (танҳо Admin
   SDK/backend метавонад). Ин Cloud Function дар `functions/index.js`
   тайёр аст: ба сохтани ҳар документи `notifications/{id}` гӯш
   медиҳад ва тавассути `firebase-admin/messaging` push мефиристад.

## Чаро ҳамин тарҳ (на чизи дигар)

Спецификатсия (banди 19) мегӯяд "Firebase Cloud Messaging", вале дар
ягон ҷои дигар аз Cloud Functions/backend ёдовар намешавад — тамоми
лоиҳа то ҳол 100% client+Firestore Rules буд. Бинобар ин:

- **In-app center** — ҳатмист, тамоми қисми "notification" (banди
  19-и рӯйхат)-ро дар дохили худи барнома иҷро мекунад, БЕ ниёз ба
  Cloud Functions. Агар шумо Cloud Function-ро деплой накунед ҳам,
  ин қисм пурра кор мекунад.
- **Cloud Function** — иловагӣ, барои push-и воқеӣ. Хурд (як файл),
  танҳо як масъулият (Firestore trigger → FCM send). Деплой кардани
  он ихтиёрист.

## Насб (қадамҳо, як бор)

```bash
cd functions
npm install
firebase deploy --only functions
```

**Талабот:** Firebase-и шумо бояд дар нақшаи **Blaze** (pay-as-you-go)
бошад — ин талаботи худи Cloud Functions (2nd gen) аст, новобаста аз
андозаи истифода (Google Cloud/Cloud Run-ро истифода мебарад). Барои
барномаи андозаи PAYDO.TJ дар аввали кор, истифода эҳтимол дар квотаи
ройгон мемонад, вале худи фаъол кардани Blaze маънои "картаи бонкӣ
илова кунед"-ро дорад (ҳатто агар пул нагиранд).

## Notification-ҳои дар PHASE 15 пайвастшуда

| Намуд (banди 19) | Триггер | Фиристода мешавад ба |
|---|---|---|
| New order | `CheckoutScreen` пас аз checkout | ҳар seller-и дар order |
| Order status changed | `SellerOrdersScreen` тугмаи status | customer |
| New message | `ChatDetailScreen` пас аз фиристодани хабар | ҳамсӯҳбат |
| Courier assigned | `DeliveryActionController.assignCourier` | customer |
| Delivery started | `DeliveryActionController.advanceDeliveryStatus` (→onTheWay) | customer |
| Delivery arrived | ҳамон ҷо (→delivered) | customer |
| Job application | `VacancyDetailsScreen._apply` | employer |

**Дар ин марҳила пайваст НАШУД** (сабаб дар ҳар банд):
- **New vacancy** — паём ба ҳама корҷӯёни мутобиқ ниёз ба query-и
  васеъ ва costly дорад (садҳо/ҳазорон корбар) — дар оянда бо
  Cloud Function-и алоҳида (batch) беҳтар анҷом мешавад, на дар
  client.
- **Review** — феҷаи Reviews ҳанӯз сохта нашудааст (PHASE 16).
- **Important system notification** — Admin Panel ҳанӯз нест (PHASE
  19); notification-и системавӣ аз он ҷо фиристода мешавад.

## Ризоят ва иҷозат

`FcmService.initializeForCurrentUser()` (даъват мешавад як бор пас аз
воридшавӣ, дар `RootShell.initState`) `requestPermission()`-и худи
Firebase-ро даъват мекунад — ин муколамаи стандартии OS (Android
13+/iOS)-ро нишон медиҳад. Агар корбар рад кунад, барнома бе push
идома меёбад (in-app center ҳамоно кор мекунад).

## Санҷиш

`flutter test` (CI) моделҳои notification-ро санҷад, вале FCM-и воқеӣ
ва Cloud Function-ро не (ниёз ба device/emulator воқеӣ ва Firebase-и
деплойшуда доранд). Санҷиши дастӣ: пас аз деплой, аз Firebase Console
→ Cloud Messaging → "Send test message" бо FCM token-и дастӣ гирифташуда.
