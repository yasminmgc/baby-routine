import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/errors/app_exception.dart';

void main() {
  group('AppException', () {
    test('should create with message only', () {
      final exception = AppException('Something went wrong');
      expect(exception.message, 'Something went wrong');
      expect(exception.statusCode, isNull);
      expect(exception.toString(), 'Something went wrong');
    });

    test('should create with message and statusCode', () {
      final exception = AppException('Not found', statusCode: 404);
      expect(exception.message, 'Not found');
      expect(exception.statusCode, 404);
    });

    test('should implement Exception interface', () {
      final exception = AppException('Error');
      expect(exception, isA<Exception>());
    });
  });
}
