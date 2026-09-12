import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/delivery_model.dart';

void main() {
  group('DeliveryModel (PHASE 14 — Live Tracking)', () {
    test('courierLocation пешфарз null аст (GPS ҳанӯз фаъол нашуд)', () {
      const delivery = DeliveryModel(
        id: '1',
        orderId: 'o1',
        courierId: 'c1',
        courierName: 'Далер',
        customerId: 'u1',
        customerName: 'Алишер',
        customerAddress: 'Кӯчаи Рӯдакӣ',
        customerCity: 'Душанбе',
        pickupCity: 'Душанбе',
      );
      expect(delivery.courierLocation, null);
    });

    test('fromMap courierLocation-ро дуруст мехонад', () {
      final map = {
        'orderId': 'o1',
        'courierId': 'c1',
        'courierName': 'Далер',
        'customerId': 'u1',
        'customerName': 'Алишер',
        'customerAddress': 'Кӯчаи Рӯдакӣ',
        'customerCity': 'Душанбе',
        'pickupCity': 'Хуҷанд',
        'courierLocation': const GeoPoint(38.56, 68.78),
      };
      final delivery = DeliveryModel.fromMap('1', map);

      expect(delivery.courierLocation?.latitude, 38.56);
      expect(delivery.pickupCity, 'Хуҷанд');
    });

    test('pickupCity fallback ба customerCity агар дода нашуда бошад', () {
      final map = {
        'orderId': 'o1',
        'courierId': 'c1',
        'courierName': 'Далер',
        'customerId': 'u1',
        'customerName': 'Алишер',
        'customerAddress': 'Кӯчаи Рӯдакӣ',
        'customerCity': 'Кӯлоб',
      };
      final delivery = DeliveryModel.fromMap('1', map);
      expect(delivery.pickupCity, 'Кӯлоб');
    });
  });
}
