import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/constants/app_colors.dart';

void main() {
  group('AppColors', () {
    test('should have 12 color constants defined', () {
      expect(AppColors.lilac.value, 0xFFB39DDB);
      expect(AppColors.lilacDark.value, 0xFF7E57C2);
      expect(AppColors.mint.value, 0xFF80CBC4);
      expect(AppColors.peach.value, 0xFFFCE4D6);
      expect(AppColors.lavender.value, 0xFFE8EAF6);
      expect(AppColors.white.value, 0xFFFFFFFF);
      expect(AppColors.lightGray.value, 0xFFF5F5F5);
      expect(AppColors.textGray.value, 0xFF757575);
      expect(AppColors.textDark.value, 0xFF212121);
      expect(AppColors.success.value, 0xFF66BB6A);
      expect(AppColors.error.value, 0xFFEF5350);
      expect(AppColors.warning.value, 0xFFFFA726);
    });
  });
}
