import 'package:built_value/built_value.dart';
import 'package:value_bloc/src/base/BaseBlocState.dart';
import 'package:value_bloc/src/status.dart';

part 'ValueState.g.dart';

abstract class ValueBlocState<V, Filter>
    implements
        Built<ValueBlocState<V, Filter>, ValueBlocStateBuilder<V, Filter>>,
        BaseBlocState<Filter> {
  ValueBlocState._();

  factory ValueBlocState([void Function(ValueBlocStateBuilder<V, Filter> b) updates]) =
      _$ValueBlocState<V, Filter>;

  static void _finalizeBuilder(ValueBlocStateBuilder b) =>
      BaseBlocState.finalizeBuilder(b);

  LoadStatusValueBloc get loadStatus;
  FetchStatusValueBloc get fetchStatus;

  @nullable
  V get value;
}
