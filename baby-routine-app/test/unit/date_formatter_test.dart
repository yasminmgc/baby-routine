import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/utils/date_formatter.dart';

void main() {
  group('DateFormatter', () {
    final testDate = DateTime(2024, 3, 15, 14, 30);

    test('formatDate should return dd/MM/yyyy', () {
      expect(DateFormatter.formatDate(testDate), '15/03/2024');
    });

    test('formatDateTime should include time', () {
      final result = DateFormatter.formatDateTime(testDate);
      expect(result, contains('15/03/2024'));
      expect(result, contains('14:30'));
    });

    test('formatTime should return HH:mm', () {
      expect(DateFormatter.formatTime(testDate), '14:30');
    });

    test('formatMonthYear should return month and year', () {
      final result = DateFormatter.formatMonthYear(testDate);
      expect(result, contains('2024'));
    });

    test('formatWeekday should return weekday name in pt-BR', () {
      // 2024-03-15 is a Friday
      expect(DateFormatter.formatWeekday(testDate), isNotEmpty);
    });

    test('formatRelativeDate should return Hoje for today', () {
      expect(DateFormatter.formatRelativeDate(DateTime.now()), 'Hoje');
    });

    test('formatRelativeDate should return Ontem for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      expect(DateFormatter.formatRelativeDate(yesterday), 'Ontem');
    });
  });
}
