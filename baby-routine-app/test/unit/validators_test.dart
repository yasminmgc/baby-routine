import 'package:flutter_test/flutter_test.dart';

import 'package:baby_routine_app/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('required', () {
      test('should return null for non-empty value', () {
        expect(Validators.required('Hello'), isNull);
      });

      test('should return error for empty string', () {
        expect(Validators.required(''), isNotNull);
      });

      test('should return error for whitespace-only string', () {
        expect(Validators.required('   '), isNotNull);
      });

      test('should return error for null', () {
        expect(Validators.required(null), isNotNull);
      });
    });

    group('email', () {
      test('should return null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
      });

      test('should return error for empty value', () {
        expect(Validators.email(''), isNotNull);
      });

      test('should return error for missing @', () {
        expect(Validators.email('userexample.com'), isNotNull);
      });

      test('should return error for missing domain', () {
        expect(Validators.email('user@'), isNotNull);
      });

      test('should return error for null', () {
        expect(Validators.email(null), isNotNull);
      });
    });

    group('password', () {
      test('should return null for valid password', () {
        expect(Validators.password('Abcdefg1'), isNull);
      });

      test('should return error for password shorter than 8 chars', () {
        expect(Validators.password('Abc1'), isNotNull);
      });

      test('should return error for password without uppercase', () {
        expect(Validators.password('abcdefg1'), isNotNull);
      });

      test('should return error for password without number', () {
        expect(Validators.password('Abcdefgh'), isNotNull);
      });

      test('should return error for empty password', () {
        expect(Validators.password(''), isNotNull);
      });

      test('should return error for null password', () {
        expect(Validators.password(null), isNotNull);
      });
    });
  });
}
