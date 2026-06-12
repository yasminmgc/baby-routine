import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';

void main() {
  group('selectedBabyProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final baby = container.read(selectedBabyProvider);
      expect(baby, isNull);
    });

    test('can set and read a value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      const testBaby = {'id': '123', 'name': 'Test'};
      container.read(selectedBabyProvider.notifier).state = testBaby;

      final baby = container.read(selectedBabyProvider);
      expect(baby, testBaby);
    });
  });
}
