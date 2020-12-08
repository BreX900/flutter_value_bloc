import 'package:test/test.dart';
import 'package:value_bloc/src/single/SingleValueState.dart';
import 'package:value_bloc/src/value/ValueState.dart';

class Father {}

abstract class SayHello {
  void sayHello();
}

class Child extends Father implements SayHello {
  void sayHello() => print('Hello');
}

main() {
  test('emptyTest', () {
    expect(true, true);

    ValueState child = IdleSingleValueState(null);

    if (child is LoadingValueState) {
      child.progress;
    }
  });
}
