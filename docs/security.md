# Security — PAYDO.TJ

Мутобиқи banди 24 спецификация. Ин файл дар ҳар PHASE-и нав навсозӣ мешавад.

## Ҳолати ҳозира (PHASE 1–17)

- `firestore.rules`: коллексияи `users` — корбар танҳо документи худро сохта/навишта метавонад; хондан барои ҳар корбари ворид шуда кушода аст (барои профили ҷамъиятӣ дар оянда). Ҳама коллексияи дигар **default-deny** аст, то вақте ки феҷаи дахлдор онро кушояд.
- `firestore.rules` → `products`: хондан барои ҳама (marketplace бояд бе воридшавӣ ҳам намоён бошад — қарор), навиштан/тағйир/нест кардан танҳо барои `sellerId == auth.uid`.
- `firestore.rules` → `favorites`: хондан/навиштан/нест кардан танҳо барои `userId == auth.uid`-и худи документ.
- `firestore.rules` → `businesses`: documentId = ownerId; хондан кушода (профили ҷамъиятӣ), навиштан танҳо барои `auth.uid == ownerId`; нест кардан бастааст (танҳо тавассути admin panel, PHASE 19).
- `firestore.rules` → `orders`: хондан барои харидор ё яке аз seller-ҳои дар `sellerIds`; сохтан танҳо аз номи худи харидор (`customerId == auth.uid`); тағйир (status) барои харидор ё seller-и дахлдор; нест кардан бастааст.
- `firestore.rules` → `chats`/`messages`: танҳо 2 иштирокчии дар `participantIds` метавонанд хонанд/нависанд; хабарҳо баъд аз фиристодан ивазнашаванда/нестнашавандаанд.
- `firestore.rules` → `jobs`: хондан кушода, навиштан/тағйир/нест кардан танҳо барои `employerId == auth.uid`.
- `firestore.rules` → `worker_profiles`: documentId = uid; хондан кушода (мисли businesses), навиштан танҳо барои соҳиб.
- `firestore.rules` → `job_applications`: хондан барои корҷӳ ё корфармои дахлдор; сохтан танҳо аз номи корҷӳ; тағйир (қабул/рад) танҳо барои корфармо.
- `firestore.rules` → `services`: documentId = uid; хондан кушода (мисли worker_profiles), навиштан танҳо барои соҳиб.
- `firestore.rules` → `service_orders`: хондан/тағйир барои харидор ё хизматрасони дахлдор; сохтан танҳо аз номи харидор.
- `firestore.rules` → `debts`/`expenses`: пурра хусусӣ — танҳо `ownerId == auth.uid`.
- `firestore.rules` → `couriers`: documentId = uid; хондан барои ҳар корбари ворид шуда (Business бояд courier-ҳои озодро бинад), навиштан танҳо барои соҳиб.
- `firestore.rules` → `deliveries`: documentId = orderId; хондан/тағйир барои courier-и таъиншуда ё харидор; сохтан бе санҷиши "фиристанда seller аст" (маҳдудияти MVP — ниг. TODO поён).
- `firestore.rules`: PHASE 13 (Map) коллексияи нав ИЛОВА НАКАРД — танҳо `businesses`/`services`/`jobs`/`couriers`-и аллакай кушодаро мехонад (ниг. `docs/maps.md`).
- `firestore.rules`: PHASE 14 (Live Tracking) низ коллексияи нав ё қоидаи нав илова НАКАРД — `deliveries.courierLocation` тавассути ҳамон қоидаи "update" (courierId==auth.uid, PHASE 12) навсозӣ мешавад.
- `firestore.rules` → `notifications`: хондан/mark-as-read танҳо барои гиранда (`recipientId == auth.uid`); сохтан барои ҳар корбари ворид шуда кушода аст (фиристанда одатан на худи гиранда аст) — маҳдудияти MVP, мисли `deliveries.create`.
- `firestore.rules` → `reviews`: хондан кушода барои ҳар корбари ворид шуда; сохтан танҳо аз номи худи муаллиф (`authorId == auth.uid`); тағйир/нест кардан бастаанд. `products`/`businesses`/`services`/`couriers` **бетағйир монданд** (танҳо соҳиб "update" мекунад) — rating тавассути Cloud Function (Admin SDK, аз rules мегузарад) навсозӣ мешавад, на бевосита аз client (ниг. `docs/reviews.md`).
- `firestore.rules`: PHASE 17 (Search) қоидаи нав ИЛОВА НАКАРД — танҳо коллексияҳои аллакай кушода (products/businesses/services/jobs) мехонад бо майдони иловагии `nameLower`/`titleLower` (ниг. `docs/search.md`).
- `storage.rules`: `profile_photos/{uid}.jpg`, `business_images/{ownerId}/{logo,cover}.jpg`, `product_images/{sellerId}/{uuid}.jpg` — ҳар корбар танҳо файли худро бор/нест карда метавонад. `chat_images/{chatId}/{uuid}.jpg` — **МУВАҚҚАТӢ** танҳо authentication санҷида мешавад (ниг. эзоҳ дар `storage.rules`, мустаҳкамкунӣ дар PHASE 20). Хондан барои ҳама кушода аст (ба ҷуз chat).
- API secret/private key дар коди Flutter нест.
- Google Sign-In credential-ҳо танҳо ба воситаи Firebase SDK коркард мешаванд (client-side secret нест).

## Қоидаҳои умумӣ (барои ҳар PHASE-и оянда)

- Seller метавонад танҳо `products`-и худро идора кунад (`resource.data.sellerId == request.auth.uid`).
- Business метавонад танҳо `orders`-и марбут ба худро бинад/идора кунад.
- Customer метавонад танҳо `orders`-и худро бинад.
- Chat: танҳо иштирокчиёни он `chat` (array `participantIds`) метавонанд `messages`-ро хонанд/нависанд.
- `accounting`, `debts`, `inventory`, `sales`, `expenses` — танҳо соҳиби бизнес (`ownerId == request.auth.uid`).
- Коллексияҳои admin-only (масалан `reports`, feature flags) — санҷиши `accountTypes` дар документи `users/{uid}` бо `admin`.

## Тест кардани Security Rules

Тавсия: Firebase Emulator Suite (`firebase emulators:start`) + `@firebase/rules-unit-testing` барои unit-test-и rules пеш аз deploy (PHASE 20/21).

## TODO пеш аз release (PHASE 20)

- [ ] `storage.rules` → `chat_images`: мустаҳкам кардани санҳиши "танҳо иштирокчии чат" (ҳозир танҳо `request.auth != null`).
- [ ] `firestore.rules` → `deliveries` (create): санҷидан, ки фиристанда воқеан яке аз seller-ҳои order (`sellerIds`) аст, на танҳо "authenticated" (ниг. эзоҳ дар `firestore.rules`).
- [ ] `firestore.rules` → `notifications` (create): санҷидани мутобиқати "фиристанда ҳаққи ин намуди notification-ро дорад" (ҳозир ҳар корбари ворид шуда метавонад барои дигар корбар notification созад).
- [ ] Санҳиши пурраи `firestore.rules` бо Firebase Emulator барои ҳама коллексия (users, products, favorites, businesses, orders, chats/messages, jobs, worker_profiles, job_applications, services, service_orders, debts, expenses, couriers, deliveries).
