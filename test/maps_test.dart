import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/core/constants/tj_city_coordinates.dart';
import 'package:paydo_tj/features/maps/domain/map_marker.dart';

void main() {
  group('TjCityCoordinates', () {
    test('координатаи Душанбе дуруст бармегардад', () {
      final coord = TjCityCoordinates.of('Душанбе');
      expect(coord.lat, closeTo(38.5598, 0.01));
      expect(coord.lng, closeTo(68.7870, 0.01));
    });

    test('шаҳри номаълум ба маркази кишвар fallback мекунад', () {
      final coord = TjCityCoordinates.of('НомиНомаълум');
      expect(coord.lat, TjCityCoordinates.country.lat);
      expect(coord.lng, TjCityCoordinates.country.lng);
    });

    test('ҳамаи 14 шаҳр координата доранд', () {
      expect(TjCityCoordinates.all.length, 14);
    });
  });

  group('MapMarkerType', () {
    test('ҳар навъ ранги худро дорад', () {
      final colors = MapMarkerType.values.map((t) => t.colorHex).toSet();
      expect(colors.length, MapMarkerType.values.length); // ҳама фарқ мекунанд
    });

    test('label-ҳо холӣ нестанд', () {
      for (final type in MapMarkerType.values) {
        expect(type.label.isNotEmpty, true);
      }
    });
  });

  group('MapMarkerModel', () {
    test('isPreciseLocation пешфарз false аст', () {
      final marker = MapMarkerModel(
        id: '1',
        type: MapMarkerType.business,
        title: 'Test',
        subtitle: 'Test',
        coordinate: TjCityCoordinates.of('Душанбе'),
      );
      expect(marker.isPreciseLocation, false);
    });
  });
}
