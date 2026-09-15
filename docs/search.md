# Search and filters — PHASE 17

## Технология: Firestore prefix-search

Firestore full-text/fuzzy search-и native надорад (акс аз Algolia/
Elasticsearch). Бинобар ин мо аз **prefix-search** истифода мебарем:

```
products.where('nameLower', >=, query).where('nameLower', <, query + '\uf8ff')
```

Ин "ҷустуҷӯи аз аввали калима" аст:
- ✅ "тел" → "Телефон Samsung" (мувофиқат мекунад)
- ❌ "фон" → "Телефон Samsung" (МУВОФИҚАТ НАМЕКУНАД — "фон" на дар
  аввали ҳеҷ калима нест)

Ҳар модел (Product/Business/Service/Vacancy) майдони иловагии
`nameLower`/`titleLower`-ро дар `toMap()` худкор месозад (аз `name`/
`businessName`/`title`-и худаш, `.toLowerCase()`) — UI-и форма-ҳо
(Add/Edit Product ва ғ.) ТАҒЙИР НАЁФТАНД, зеро ин майдон танҳо барои
навиштан аст, на барои корбар намоён.

## Маҳдудият ва "scalable" (banди 21)

Спецификатсия мегӯяд "Search should be scalable" — prefix-search-и
Firestore ба маънои "миллионҳо маҳсулот" **scalable** аст (индекси
воқеӣ, на full-collection scan), вале аз ҷиҳати **сифати натиҷа**
маҳдуд аст (танҳо prefix, на fuzzy/substring/хатогии имлоӣ).

Агар дар оянда ҷустуҷӯи воқеан fuzzy (масалан хатогии имлоӣ, ҷустуҷӯ
дар мобайни калима, ranking аз рӯи relevance) лозим шавад, роҳи дуруст
хизмати алоҳидаи search (Algolia, Meilisearch, ё Typesense-и
self-hosted) аст, ки бо як Cloud Function (Firestore trigger → sync ба
он хизмат) пайваст мешавад. Ин қасдан берун аз доираи MVP-и free-tier
монд (banди 25).

## Debounce

`SearchScreen` 400мс интизор мемонад пас аз охирин ҳарфи чопшуда, пеш
аз фиристодани query ба Firestore — то ҳар зарбаи калидбай як
Firestore read-и алоҳида напартояд (хароҷоти free-tier).

## "users" аз рӯйхати banди 21

Спецификатсия мегӯяд "products, shops, services, jobs, users/
businesses". Дар ин лоиҳа "users" ба таври ҷудогона ҷустуҷӯ намешавад
— сабабҳо:
1. **Хусусият (privacy):** феҳристи умумии "ҳама корбарон" набояд бе
   мақсади мушаххас ҷустуҷӯшаванда бошад.
2. **Дучандӣ:** "users/businesses" аллакай тавассути category-и
   "Дӯконҳо" (businesses) пӯшонида мешавад — profile-и ҷамъиятии
   корбар маҳз Business Profile аст.
3. Ҷустуҷӯи корҷӯ (worker_profiles) аллакай дар PHASE 9 (Jobs →
   таби "Корҷӯён") мавҷуд аст — такрор дар Global Search лозим набуд.

## Filter-ҳо (banди 21) аз рӯи category

| Filter | Маҳсулот | Дӯкон | Хизмат | Кор |
|---|---|---|---|---|
| city | ✅ | ✅ | ✅ | ✅ |
| category | ✅ (ProductCategories) | — | ✅ (ServiceCategories) | — |
| price | ✅ (min/max) | — | ✅ (min/max) | ✅ (маош аз) |
| rating | ✅ | ✅ | ✅ | — |
| delivery | ✅ | ✅ | — | — |

`city`/`category` ҳамчун Firestore `where()` (бо composite index, ниг.
`firestore.indexes.json`); `price`/`rating`/`delivery` дар client баъд
аз хондани натиҷа (Firestore рухсат намедиҳад якчанд range-filter-и
ҳамзамон дар майдонҳои гуногун бе маҳдудияти иловагӣ — соддатар ва
бехатартар дар client filter кардан).
