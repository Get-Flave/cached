import 'package:test/test.dart';
import '../utils/test_utils.dart';
import 'simple/cached_test_simple.dart';

void main() {
  group('SimpleCache', () {
    late TestDataProvider _dataProvider;

    setUp(() {
      _dataProvider = TestDataProvider();
    });

    test('cached value should be the same on the second method call', () {
      final cachedClass = SimpleCached(_dataProvider);
      final cachedValue = cachedClass.cachedValue();
      final secondCachedValue = cachedClass.cachedValue();

      expect(cachedValue, equals(secondCachedValue));
    });

    test('cached values should be stored by generated custom cache key', () {
      final cachedClass = SimpleCached(_dataProvider);

      for (final exampleValue in ["a", "b", "c"]) {
        final cachedValue = cachedClass.cachedValueWithCustomKey(exampleValue);
        final secondCachedValue =
            cachedClass.cachedValueWithCustomKey(exampleValue);
        expect(cachedValue, equals(secondCachedValue));
      }
    });

    test('iterableCacheKeyGenerator should generate reproducible hashes', () {
      final exampleValue = ["a", "b"];

      final cachedClass = SimpleCached(_dataProvider);

      final cachedValue = cachedClass.cachedWithIterableCacheKey(exampleValue);
      final secondCachedValue =
          cachedClass.cachedWithIterableCacheKey(exampleValue);
      final reverseListOrderingValue = cachedClass
          .cachedWithIterableCacheKey(exampleValue.reversed.toList());
      final listCopyValue =
          cachedClass.cachedWithIterableCacheKey(exampleValue.toList());

      expect(cachedValue, equals(secondCachedValue));
      expect(cachedValue, isNot(reverseListOrderingValue));
      expect(cachedValue, equals(listCopyValue));
    });

    test('iterableCacheKeyGenerator should handle null', () {
      final cachedClass = SimpleCached(_dataProvider);

      final cachedValue = cachedClass.cachedWithNullableList(null);
      final secondCachedValue = cachedClass.cachedWithNullableList(null);
      final notCachedValue = cachedClass.cachedWithNullableList([]);

      expect(cachedValue, equals(secondCachedValue));
      expect(cachedValue, isNot(notCachedValue));
    });

    test('clear cache method should clear cache', () {
      final cachedClass = SimpleCached(_dataProvider);
      final cachedValue = cachedClass.cachedValue();
      cachedClass.clearCachedValue();
      final secondCachedValue = cachedClass.cachedValue();

      expect(cachedValue != secondCachedValue, true);
    });

    test(
        'setting ignoreCache to true should ignore cached value and return new one',
        () async {
      final cachedClass = SimpleCached(_dataProvider);
      final cachedValue = cachedClass.cachedTimestamp();
      await Future.delayed(const Duration(milliseconds: 10));
      final secondCachedValue = cachedClass.cachedTimestamp(refresh: true);

      expect(cachedValue != secondCachedValue, true);
    });

    test('calling other clear cache method, should not clear cache', () {
      final cachedClass = SimpleCached(_dataProvider);
      final cachedValue = cachedClass.cachedTimestamp();
      cachedClass.clearCachedValue();
      final secondCachedValue = cachedClass.cachedTimestamp();

      expect(cachedValue == secondCachedValue, true);
    });

    test('clearing all cache method should clear cache', () async {
      final cachedClass = SimpleCached(_dataProvider);
      final cachedValue = cachedClass.cachedValue();
      final cachedTimestamp = cachedClass.cachedTimestamp();
      await Future.delayed(const Duration(milliseconds: 10));

      cachedClass.clearAll();
      final secondCachedValue = cachedClass.cachedValue();
      final secondCachedTimestamp = cachedClass.cachedTimestamp();

      expect(cachedValue != secondCachedValue, true);
      expect(cachedTimestamp != secondCachedTimestamp, true);
    });
  });
}
