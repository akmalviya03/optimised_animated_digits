import 'package:flutter_test/flutter_test.dart';
import 'package:optimised_animated_digits/digits_extractor.dart';

void main() {
  test(
    'successful digits extract',
    () {
      final StartColourIndex digitsExtractor =
          StartColourIndex(numericValue: 12.3456);
      expect(
        digitsExtractor.isFractional,
        true,
        reason: "Should be fractional",
      );
      expect(
        digitsExtractor.list,
        ["1", "2", ".", "3", "4"],
        reason: "Should be precise up to two digits",
      );
    },
  );
}
