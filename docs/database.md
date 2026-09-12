# Database — Cloud Firestore

## Ҳолати ҳозира (PHASE 1)

### `users/{uid}`

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| uid | string | = document id |
| name | string | аз Google profile |
| email | string | аз Google profile |
| phone | string? | ихтиёрӣ, PHASE 2 |
| age | int? | ихтиёрӣ, PHASE 2 |
| nickname | string? | PHASE 2 |
| photoUrl | string? | аз Google, баъдтар аз Storage (PHASE 2) |
| instagramUrl | string? | PHASE 2 |
| whatsapp | string? | PHASE 2 |
| city | string? | PHASE 2 |
| accountTypes | array\<string\> | зермаҷмӯи: user, business, worker, employer, courier, admin |
| phoneVisible | bool | privacy toggle (PHASE 2) |
| ageVisible | bool | privacy toggle (PHASE 2) |
| createdAt | timestamp | server timestamp, дар create танҳо |
| updatedAt | timestamp | server timestamp, дар ҳар навсозӣ |

### `products/{productId}` (PHASE 4)

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| sellerId | string | = Firebase Auth uid-и фурӯшанда |
| businessId | string? | агар аз тарафи бизнес гузошта шуда бошад (PHASE 5) |
| name, description | string | |
| price, oldPrice | number | oldPrice барои нишон додани discount |
| discount | int? | фоиз |
| images | array\<string\> | URL-ҳои Storage (боркунӣ дар PHASE 6) |
| category | string | аз `ProductCategories.all` |
| quantity | int | 0 = "Номавҷуд" |
| city | string | аз `TjCities.all` |
| location | geopoint? | барои Map (PHASE 13) |
| deliveryAvailable | bool | |
| rating, reviewsCount | number/int | навсозӣ мешавад дар PHASE 16 |
| isHidden | bool | true = аз feed пинҳон (PHASE 6) |
| createdAt, updatedAt | timestamp | |

**Index-ҳои лозимӣ (PHASE 21 пеш аз release тасдиқ карда шавад):**
`isHidden + category + createdAt`, `isHidden + city + createdAt`, `isHidden + createdAt`, `sellerId + createdAt` (барои "Маҳсулоти ман", PHASE 6), `businessId + isHidden + createdAt` (барои Business Profile → Products tab).

### `favorites/{uid}_{itemId}` (PHASE 4)

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| userId | string | |
| itemId | string | масалан productId |
| itemType | string | ҳоло танҳо `'product'`; PHASE 9/10 метавонанд `'job'`/`'service'` илова кунанд |
| createdAt | timestamp | |

Қарори тарроҳӣ: docId = `{uid}_{itemId}` (на auto-id), то "toggle" (илова/нест кардан) бе query иловагӣ иҷро шавад — мустақим `favorites/{uid}_{productId}` дастрас аст.

### `businesses/{ownerId}` (PHASE 5)

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| ownerId | string | = documentId, = Firebase Auth uid |
| businessName, description | string | |
| logoUrl, coverImageUrl | string? | Storage: `business_images/{ownerId}/logo.jpg` / `cover.jpg` |
| phone, whatsapp, instagramUrl | string? | |
| city, address | string | |
| location | geopoint? | PHASE 13 |
| deliveryAvailable | bool | |
| workingHours | string? | озод-матн, масалан "9:00 - 20:00" |
| rating, reviewsCount | number/int | PHASE 16 навсозӣ мекунад |
| isVerified | bool | admin verify, PHASE 19 |
| createdAt, updatedAt | timestamp | |

### `orders/{orderId}` (PHASE 7)

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| customerId | string | |
| customerName, customerPhone, customerCity, customerAddress | string | address танҳо агар deliveryType='delivery' |
| items | array\<map\> | **embedded** — ниг. эзоҳи тарроҳӣ дар `lib/models/order_model.dart` (на коллексияи алоҳидаи `order_items`) |
| deliveryType | string | `'delivery'` \| `'pickup'` |
| subtotal, deliveryFee, total | number | |
| status | string | pending→accepted→preparing→ready→shipped→delivering→completed (ё cancelled) |
| sellerIds | array\<string\> | денормализатсия барои query "orders барои ин seller" (array-contains) |
| createdAt, updatedAt | timestamp | |

**Cart** (banди 11) дар Firestore нест — device-local, ниг. `lib/models/cart_item_model.dart`.

### `chats/{chatId}` ва `chats/{chatId}/messages/{messageId}` (PHASE 8)

| Майдон (chat) | Навъ | Тавзеҳ |
|---|---|---|
| id | string | = documentId = `{uid1}_{uid2}` (sorted, детерминистӣ) |
| participantIds | array\<string\> | ҳамеша 2 нафар дар PHASE 8 |
| participantNames, participantPhotos | map | денормализатсия барои намоиши рӯйхат бе N+1 read |
| lastMessageText/SenderId/At | string/timestamp | барои Chat List |
| unreadCounts | map\<uid,int\> | |
| contextType/Id/Title | string? | 'product'/'business'/... — аз куҷо чат сарчашма гирифт |

| Майдон (message) | Навъ | Тавзеҳ |
|---|---|---|
| senderId | string | |
| type | string | `'text'` \| `'image'` |
| text, imageUrl | string? | |
| timestamp | timestamp | |
| isRead | bool | (соддакардашуда — ҳисоб дар сатҳи chat, на паём, ниг. `unreadCounts`) |

### `jobs/{jobId}`, `worker_profiles/{uid}`, `job_applications/{jobId}_{workerId}` (PHASE 9)

| Коллексия | documentId | Тавзеҳ |
|---|---|---|
| `jobs` | auto-id | вакансия аз корфармо; `employerId` барои Security Rules |
| `worker_profiles` | `uid` | ҳамон нақшаи `businesses/{ownerId}` — як профил барои ҳар корбар |
| `job_applications` | `{jobId}_{workerId}` | детерминистӣ — пешгирии аризаи такрорӣ ба ҳамон вакансия |

`worker_profiles.isVisible=false` танҳо дар client-side query филтр мешавад (профил боз ҳам мустақим хонда мешавад бо ID — ниг. эзоҳ дар `firestore.rules`); ин барои MVP кофист, вале дар PHASE 20 мулоҳиза мешавад.

### `services/{uid}`, `service_orders/{orderId}` (PHASE 10)

Ҳамон нақшаи `worker_profiles`/`jobs` — `services` documentId=uid (як профил барои ҳар корбар), `service_orders` auto-id бо `customerId`/`providerId` барои Security Rules. `ServiceOrderStatus` соддатар аз `OrderStatus`-и marketplace (pending/accepted/completed/cancelled, на 8 ҳолат) — хизматрасонӣ pipeline-и логистикӣ (shipped/delivering) надорад.

### `debts/{debtId}`, `expenses/{expenseId}` (PHASE 11)

| Коллексия | Майдонҳои калидӣ | Тавзеҳ |
|---|---|---|
| `debts` | ownerId, customerName, phone, amount, paid, date, notes | `remaining` = amount − paid (ҳисоб дар client, на дар Firestore) |
| `expenses` | ownerId, title, amount, date, notes | |

**МУҲИМ (қарори тарроҳӣ):** `sales` ва `inventory` (номбаршуда дар banди 27) ҳамчун коллексияи алоҳида **сохта НАШУДАНД**. Сабаб: `orders` (PHASE 7, status=completed) аллакай ҳамаи маълумоти "фурӯш"-ро дорад, ва `products` (PHASE 6, бо майдони нави `purchasePrice`) аллакай ҳамаи маълумоти "inventory"-ро дорад. Сохтани коллексияи дуввум маънои ду манбаи ҳақиқат ва хатари desync-ро дошт — мустақим хилофи talab-и худи banди 27 ("Avoid unnecessary duplication"). Dashboard (`AccountingDashboardScreen`) статистикаро бевосита аз `sellerOrdersProvider` (Orders) ва `myProductsProvider` (Products) ҳисоб мекунад. Ниг. эзоҳи муфассал дар `lib/features/accounting/domain/accounting_repository.dart`.

### `couriers/{uid}`, `deliveries/{orderId}` (PHASE 12)

| Коллексия | documentId | Тавзеҳ |
|---|---|---|
| `couriers` | `uid` | ҳамон нақшаи profile-per-user (businesses/worker_profiles/services) |
| `deliveries` | `orderId` (детерминистӣ) | як order — як delivery; пешгирии таъини дучандӣ |

`DeliveryStatus` (assigned/pickedUp/onTheWay/delivered) аз `OrderStatus`-и marketplace (PHASE 7) ҷудост — якум марҳилаи логистикии ба courier вобаста, дуввум тамоми pipeline-и тиҷоратист. Composition байни ин ду (масалан "delivered" → order.status="completed") дар сатҳи Riverpod controller (`DeliveryActionController`) анҷом дода мешавад, на дар дохили худи repository-ҳо — ниг. `docs/architecture.md`.

**PHASE 14 (Live Tracking)** ба `deliveries/{orderId}` ин майдонҳоро илова кард:

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| `courierLocation` | geopoint? | GPS-и зиндаи courier; null то tracking фаъол шавад |
| `courierLocationUpdatedAt` | timestamp? | |
| `pickupCity` | string | шаҳри бизнеси seller-и таъинкунанда (fallback: customerCity) |
| `pickupLocation` | geopoint? | аз `businesses.location`, агар бошад |

Ягон қоидаи нави Security Rule лозим нашуд — майдонҳои нав тавассути ҳамон "update"-и мавҷуда (courierId==auth.uid) навсозӣ мешаванд.

### PHASE 13 (Map)

Ягон коллексияи нав сохта нашуд. Ниг. `docs/maps.md` барои тавзеҳи пурра
— маркерҳо бевосита аз `businesses`/`services`/`jobs`/`couriers` хонда
мешаванд.

### `notifications/{id}` (PHASE 15)

| Майдон | Навъ | Тавзеҳ |
|---|---|---|
| recipientId | string | |
| type | string | newOrder/orderStatusChanged/newMessage/courierAssigned/deliveryStarted/deliveryArrived/jobApplication/newVacancy/review/system |
| title, body | string | |
| contextType, contextId | string? | 'order'/'chat'/'job'/'business' — барои навигатсия ҳангоми tap |
| isRead | bool | |
| createdAt | timestamp | |

Push-и воқеӣ (FCM) тавассути Cloud Function-и `functions/index.js`
фиристода мешавад — ниг. `docs/notifications.md`.

## Феҳристи коллексияҳои банақшагирифташуда (аз спецификация, банди 27)

Ин рӯйхат дар `lib/core/constants/firestore_paths.dart` аллакай ҳамчун constant мавҷуд аст (то ном дар кодбоза дучандиягӣ надошта бошад), вале худи схема дар марҳилаи феҷаи дахлдор муайян карда мешавад:

- `categories` — placeholder (ҳоло `ProductCategories` static, PHASE 19 динамикӣ мешавад)
- `accounting` — истифода намешавад (dashboard бевосита аз orders/products ҳисоб мешавад, ниг. боло); `sales`, `inventory` низ сохта нашудаанд, ҳамон сабаб
- `reviews` — PHASE 16
- `reports`, `advertisements` — PHASE 18/19
- `cities` — PHASE 13 (ё static list, санҷиш дар PHASE 13)

## Қоидаи умумӣ

- ID-ҳо ҳамеша auto-id-и Firestore, ба ҷуз `users/{uid}` (= Firebase Auth uid).
- Ҳар коллексия, ки ба корбар/бизнес тааллуқ дорад, майдони `ownerId`/`sellerId`/`businessId`-ро барои Security Rules нигоҳ медорад (ниг. `docs/security.md`).
- Duplicate-ро то ҳадди имкон канорагирӣ мекунем; агар barои query денормализатсия лозим шавад (масалан номи seller дар product барои нашон додани list бе join), ин дар феҷаи дахлдор ҳуҷҷатгузорӣ мешавад.
