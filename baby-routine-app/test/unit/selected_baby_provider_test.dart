import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:baby_routine_app/shared/providers/selected_baby_provider.dart';
import 'package:baby_routine_app/features/babies/models/baby.dart';

void main() {
  group('selectedBabyProvider', () {
    test('initial value is null', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final baby = container.read(selectedBabyProvider);
      expect(baby, isNull);
    });

    test('can set and read a Baby value', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final testBaby = Baby(
        id: '123',
        name: 'Test',
        birthDate: DateTime.parse('2025-01-01'),
        currentUserRole: 'owner',
      );
      container.read(selectedBabyProvider.notifier).state = testBaby;

      final baby = container.read(selectedBabyProvider);
      expect(baby, testBaby);
    });
  });
}
