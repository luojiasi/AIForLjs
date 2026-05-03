import 'package:ai_chat_app/core/services/network/request_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RequestLogger.nextRequestId', () {
    test('starts at 1 and increments', () {
      // Reset state by creating a fresh reference — since nextRequestId
      // is a static increment, we verify sequencing.
      expect(RequestLogger.nextRequestId(), greaterThan(0));
      final first = RequestLogger.nextRequestId();
      final second = RequestLogger.nextRequestId();
      expect(second, equals(first + 1));
    });
  });

  group('RequestLogger.encodeObject', () {
    test('encodes a map to indented JSON', () {
      final result = RequestLogger.encodeObject({'a': 1, 'b': 2});
      expect(result, contains('"a": 1'));
      expect(result, contains('"b": 2'));
      // Should be multi-line (indented)
      expect(result, contains('\n'));
    });

    test('encodes a list to indented JSON', () {
      final result = RequestLogger.encodeObject([1, 2, 3]);
      expect(result, contains('1'));
      expect(result, contains('3'));
    });

    test('returns "null" for null', () {
      // JsonEncoder converts null to the string 'null'
      expect(RequestLogger.encodeObject(null), equals('null'));
    });

    test('falls back to toString for non-JSON values', () {
      final result = RequestLogger.encodeObject(Object());
      expect(result, isNotEmpty);
    });
  });

  group('RequestLogger.safeDecodeUtf8', () {
    test('decodes valid UTF-8 bytes', () {
      final bytes = [0xE4, 0xBD, 0xA0, 0xE5, 0xA5, 0xBD]; // 你好
      expect(RequestLogger.safeDecodeUtf8(bytes), equals('你好'));
    });

    test('returns empty string on null input-like error', () {
      // Passing an empty list should return empty string
      expect(RequestLogger.safeDecodeUtf8([]), isEmpty);
    });

    test('handles malformed bytes without throwing', () {
      final malformed = [0xFF, 0xFE, 0x00];
      // Should not throw, allowMalformed means we may get replacement chars
      expect(
        () => RequestLogger.safeDecodeUtf8(malformed),
        returnsNormally,
      );
    });

    test('decodes ASCII bytes', () {
      final bytes = [72, 101, 108, 108, 111]; // Hello
      expect(RequestLogger.safeDecodeUtf8(bytes), equals('Hello'));
    });
  });

  group('RequestLogger.escape', () {
    test('escapes backslash', () {
      expect(RequestLogger.escape('a\\b'), equals('a\\\\b'));
    });

    test('escapes carriage return', () {
      expect(RequestLogger.escape('a\rb'), equals('a\\rb'));
    });

    test('escapes newline', () {
      expect(RequestLogger.escape('a\nb'), equals('a\\nb'));
    });

    test('escapes tab', () {
      expect(RequestLogger.escape('a\tb'), equals('a\\tb'));
    });

    test('escapes all special characters together', () {
      expect(
        RequestLogger.escape('a\\b\r\n\tc'),
        equals('a\\\\b\\r\\n\\tc'),
      );
    });

    test('returns original string when no special chars', () {
      expect(RequestLogger.escape('hello'), equals('hello'));
    });

    test('returns empty string for empty input', () {
      expect(RequestLogger.escape(''), isEmpty);
    });
  });
}
