import 'package:test/test.dart';
import 'package:value_bloc/src/single/ValueState.dart';
import 'package:value_bloc/src/value/ValueState.dart';

class Father {}

abstract class SayHello {
  void sayHello();
}

class Child extends Father implements SayHello {
  @override
  void sayHello() => print('Hello');
}

void main() {
  test('emptyTest', () {
    expect(true, true);

    ValueState child = IdleSingleValueState(null);

    if (child is LoadingValueState) {
      child.progress;
    }
  });
}
