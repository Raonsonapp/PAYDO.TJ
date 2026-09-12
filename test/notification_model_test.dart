import 'package:flutter_test/flutter_test.dart';
import 'package:paydo_tj/models/notification_model.dart';

void main() {
  group('NotificationModel', () {
    test('isRead пешфарз false аст', () {
      const n = NotificationModel(
        id: '1',
        recipientId: 'u1',
        type: NotificationType.newOrder,
        title: 'Test',
        body: 'Test',
      );
      expect(n.isRead, false);
    });

    test('fromMap намуди дурустро мехонад', () {
      final map = {
        'recipientId': 'u1',
        'type': 'courierAssigned',
        'title': 'Courier таъин шуд',
        'body': 'Далер фармоиши шуморо мерасонад.',
        'contextType': 'order',
        'contextId': 'o1',
      };
      final n = NotificationModel.fromMap('n1', map);

      expect(n.type, NotificationType.courierAssigned);
      expect(n.contextType, 'order');
    });

    test('намуди номаълум ба system fallback мекунад', () {
      expect(NotificationTypeX.fromString('unknown_type'), NotificationType.system);
    });

    test('ҳар намуд iconKey-и холинабуда дорад', () {
      for (final type in NotificationType.values) {
        expect(type.iconKey.isNotEmpty, true);
      }
    });
  });
}
