import 'dart:collection';

import 'package:test/test.dart';

void main() {
  test('Test work?', () {
    final set = HashSet<int>();

    set.add(5);

    set.add(2);

    print(set);
  });
}
