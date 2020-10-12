import 'package:built_value/built_value.dart';
import 'package:value_bloc/src/value/ValueStateDelegate.dart';

part 'SingleValueStateDelegate.g.dart';

abstract class SingleValueStateDelegate<V, Filter>
    implements
        Built<SingleValueStateDelegate<V, Filter>,
            SingleValueStateDelegateBuilder<V, Filter>>,
        ValueStateDelegate<Filter> {
  SingleValueStateDelegate._();

  factory SingleValueStateDelegate(
          [void Function(SingleValueStateDelegateBuilder<V, Filter> b) updates]) =
      _$SingleValueStateDelegate<V, Filter>;

  static void _finalizeBuilder(SingleValueStateDelegateBuilder b) =>
      ValueStateDelegate.finalizeBuilder(b);

  @nullable
  V get value;
}
