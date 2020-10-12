import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:value_bloc/src/fetchers.dart';
import 'package:value_bloc/src/status.dart';
import 'package:value_bloc/src/value/ValueStateDelegate.dart';

part 'ListValueStateDelegate.g.dart';

abstract class ListValueStateDelegate<V, Filter>
    implements
        Built<ListValueStateDelegate<V, Filter>,
            ListValueStateDelegateBuilder<V, Filter>>,
        ValueStateDelegate<Filter> {
  ListValueStateDelegate._();

  factory ListValueStateDelegate(
          [void Function(ListValueStateDelegateBuilder<V, Filter> b) updates]) =
      _$ListValueStateDelegate<V, Filter>;

  static void _finalizeBuilder(ListValueStateDelegateBuilder b) =>
      ValueStateDelegate.finalizeBuilder(b);

  /// if this defined the limit of fetching is defined
  @nullable
  int get countValues;
  BuiltMap<FetchScheme, BuiltList<V>> get pages;
  @memoized
  BuiltList<V> get values => pages.values.expand((vls) => vls).toBuiltList();
}
