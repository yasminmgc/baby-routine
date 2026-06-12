import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/services/notification_service.dart';

// Verify the top-level background handler exists.
// Cannot test Firebase initialization in unit test environment,
// but we verify the exported symbol and function signature.

void main() {
  group('NotificationService', () {
    test('should create NotificationService instance', () {
      final service = NotificationService();
      expect(service, isNotNull);
      expect(service, isA<NotificationService>());
    });

    test('should accept notification tap callback', () {
      final service = NotificationService();

      bool wasTapped = false;
      service.onNotificationTap = (data) {
        wasTapped = true;
      };

      service.onNotificationTap?.call({'key': 'value'});
      expect(wasTapped, isTrue);
    });

    test('should handle null notification tap callback', () {
      final service = NotificationService();
      // Should not throw when onNotificationTap is null
      expect(service.onNotificationTap, isNull);
    });

    test('notification tap callback receives data map', () {
      final service = NotificationService();
      Map<String, dynamic>? receivedData;

      service.onNotificationTap = (data) {
        receivedData = data;
      };

      final testData = {
        'route': '/feeding',
        'babyId': 'baby-123',
        'eventType': 'feeding',
      };

      service.onNotificationTap?.call(testData);
      expect(receivedData, isNotNull);
      expect(receivedData!['route'], '/feeding');
      expect(receivedData!['babyId'], 'baby-123');
      expect(receivedData!['eventType'], 'feeding');
    });
  });

  group('firebaseMessagingBackgroundHandler', () {
    test('should be exported as top-level function', () {
      // Verify the handler is a callable top-level function
      expect(firebaseMessagingBackgroundHandler, isNotNull);
      expect(firebaseMessagingBackgroundHandler, isA<Function>());
    });
  });

  group('NotificationService getToken', () {
    test('should return null when Firebase is not initialized', () async {
      final service = NotificationService();
      final token = await service.getToken();
      // In test environment without Firebase, returns null
      expect(token, isNull);
    });
  });
}
