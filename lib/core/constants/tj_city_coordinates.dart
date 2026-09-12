/// Координатаи соддаи lat/lng — қасдан вобаста ба ягон package-и map
/// (масалан MapLibre-и `LatLng`) нест, то core layer аз плагини
/// мушаххас озод бошад (Clean Architecture — ниг. docs/architecture.md).
/// Table-и виҷет (features/maps) ин-ро ба `LatLng`-и худи package
/// табдил медиҳад.
class GeoCoordinate {
  final double lat;
  final double lng;
  const GeoCoordinate(this.lat, this.lng);
}

/// Координатаҳои тахминии маркази шаҳрҳои Тоҷикистон (banди 17).
/// Дақиқ набояд бошанд — танҳо барои "камера ба шаҳр равад" ва
/// "маркери бе GeoPoint-и дақиқ дар маркази шаҳраш нишон дода шавад".
class TjCityCoordinates {
  TjCityCoordinates._();

  /// Марказ ва zoom-и пешфарз барои тамоми Тоҷикистон.
  static const country = GeoCoordinate(38.5, 71.0);
  static const countryZoom = 6.2;
  static const cityZoom = 12.0;

  static const Map<String, GeoCoordinate> all = {
    'Душанбе': GeoCoordinate(38.5598, 68.7870),
    'Хуҷанд': GeoCoordinate(40.2833, 69.6333),
    'Бохтар': GeoCoordinate(37.8342, 68.7803),
    'Кӯлоб': GeoCoordinate(37.9138, 69.7822),
    'Истаравшан': GeoCoordinate(39.9086, 69.0067),
    'Панҷакент': GeoCoordinate(39.4939, 67.6111),
    'Айнӣ': GeoCoordinate(39.3667, 68.5333),
    'Вахдат': GeoCoordinate(38.5539, 69.0231),
    'Турсунзода': GeoCoordinate(38.5017, 68.2214),
    'Конибодом': GeoCoordinate(40.2914, 70.4189),
    'Исфара': GeoCoordinate(40.1214, 70.6317),
    'Хоруғ': GeoCoordinate(37.4913, 71.7501),
    'Данғара': GeoCoordinate(38.1000, 69.3333),
    'Ҳисор': GeoCoordinate(38.5306, 68.5583),
  };

  static GeoCoordinate of(String city) => all[city] ?? country;
}
