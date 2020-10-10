import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:value_bloc/src/base/BaseBlocState.dart';
import 'package:value_bloc/src/status.dart';

part 'ListBlocState.g.dart';

abstract class ListBlocState<V, Filter>
    implements
        Built<ListBlocState<V, Filter>, ListBlocStateBuilder<V, Filter>>,
        BaseBlocState<Filter> {
  ListBlocState._();

  factory ListBlocState([void Function(ListBlocStateBuilder<V, Filter> b) updates]) =
      _$ListBlocState<V, Filter>;

  static void _finalizeBuilder(ListBlocStateBuilder b) =>
      BaseBlocState.finalizeBuilder(b);

  LoadStatusValueBloc get loadStatus;
  FetchStatusValueBloc get fetchStatus;

  /// if this defined the limit of fetching is defined
  @nullable
  int get countValues;
  BuiltList<V> get values;
}
