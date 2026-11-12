import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:baby_routine_app/shared/providers/storage_provider.dart';
import 'package:baby_routine_app/core/storage/secure_storage.dart';

void main() {
  group('secureStorageProvider', () {
    test('provides a SecureStorage instance', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final storage = container.read(secureStorageProvider);
      expect(storage, isA<SecureStorage>());
    });
  });
}
