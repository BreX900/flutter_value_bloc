import 'package:test/test.dart';
import 'package:value_bloc/src/internalUtils.dart';

void main() {
  group('FetchScheme tests', () {
    test('P1', () {
      final res = FetchScheme(0, 15).mergeWith(startAt: FetchScheme(0, 5).endAt);

      expect(
        res,
        FetchScheme(5, 10),
      );
    });
  });
}
