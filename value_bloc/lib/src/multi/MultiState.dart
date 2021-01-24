part of 'MultiCubit.dart';

typedef ListFetcher<Value, Filter, ExtraData> = Stream<FetchEvent<Iterable<Value>>> Function(
    MultiCubitState<Value, Filter, ExtraData> state, FetchScheme scheme);

abstract class MultiCubitState<Value, Filter, ExtraData> with EquatableMixin {
  final Filter filter;
  final int countValues;
  final BuiltMap<int, Value> allValues;
  BuiltList<Value> _firstValues;
  BuiltList<Value> get firstValues {
    if (_firstValues == null) {
      final values = <Value>[];
      for (var i = 0; allValues.containsKey(i); i++) {
        values.add(allValues[i]);
      }
      _firstValues = values.toBuiltList();
    }
    return _firstValues;
  }

  final ExtraData extraData;

  BuiltSet<FetchScheme> _$schemes;
  BuiltSet<FetchScheme> get _schemes {
    if (_$schemes != null) return _$schemes;
    if (allValues.isEmpty) return _$schemes ??= BuiltSet<FetchScheme>();

    final schemes = <FetchScheme>[];
    int startAt = allValues.keys.first;
    int endAt = allValues.keys.first - 1;
    for (var i in allValues.keys) {
      endAt += 1;
      if (endAt != i) {
        schemes.add(FetchScheme.of(startAt, endAt));
        startAt = i;
        endAt = i - 1;
      }
    }
    schemes.add(FetchScheme.of(startAt, endAt));
    return _$schemes = schemes.toBuiltSet();
  }

  MultiCubitState({
    @required this.filter,
    @required this.countValues,
    @required this.allValues,
    @required this.extraData,
  });

  bool containsFetchScheme(FetchScheme scheme) {
    return _schemes.any((s) => s.contains(scheme));
  }

  MultiCubitState<Value, Filter, ExtraData> toFilteredFetching({Filter filter}) {
    return MultiCubitFetching(
      filter: filter,
      countValues: countValues,
      allValues: allValues,
      extraData: extraData,
    );
  }

  MultiCubitState<Value, Filter, ExtraData> toFetching() {
    return MultiCubitFetching(
      filter: filter,
      countValues: countValues,
      allValues: allValues,
      extraData: extraData,
    );
  }

  MultiCubitState<Value, Filter, ExtraData> toFetchFailed({
    bool canFetchAgain = false,
    Object failure,
  }) {
    return MultiCubitFailed(
      filter: filter,
      countValues: countValues,
      allValues: allValues,
      failure: failure,
      extraData: extraData,
    );
  }

  MultiCubitState<Value, Filter, ExtraData> toEmptyFetched({@required FetchScheme scheme}) {
    return MultiCubitFetched(
      filter: filter,
      countValues: allValues.keys.last,
      allValues: allValues,
      extraData: extraData,
      schemeFetched: scheme,
    );
  }

  MultiCubitState<Value, Filter, ExtraData> toFetched({
    @required BuiltList<Value> values,
    @required FetchScheme scheme,
  }) {
    final newAllValues = allValues.rebuild((b) {
      b.addEntries(List.generate(values.length, (index) {
        return MapEntry(scheme.startAt + index, values[index]);
      }));
    });
    print([scheme.endAt, newAllValues.keys.last]);
    return MultiCubitFetched(
      filter: filter,
      countValues: countValues ??
          ((scheme.endAt - 1) > newAllValues.keys.last ? newAllValues.keys.last : null),
      allValues: newAllValues,
      extraData: extraData,
      schemeFetched: scheme,
    );
  }

  @override
  List<Object> get props => [filter, countValues, allValues, extraData];
}

class MultiCubitFetching<Value, Filter, ExtraData>
    extends MultiCubitState<Value, Filter, ExtraData> {
  MultiCubitFetching({
    @required Filter filter,
    @required int countValues,
    @required BuiltMap<int, Value> allValues,
    @required ExtraData extraData,
  }) : super(
          filter: filter,
          countValues: countValues,
          allValues: allValues,
          extraData: extraData,
        );
}

class MultiCubitFailed<Value, Filter, ExtraData> extends MultiCubitState<Value, Filter, ExtraData> {
  final Object failure;

  MultiCubitFailed({
    @required Filter filter,
    @required int countValues,
    @required BuiltMap<int, Value> allValues,
    @required ExtraData extraData,
    this.failure,
  }) : super(
          filter: filter,
          countValues: countValues,
          allValues: allValues,
          extraData: extraData,
        );

  @override
  List<Object> get props => super.props..add(failure);
}

class MultiCubitFetched<Value, Filter, ExtraData>
    extends MultiCubitState<Value, Filter, ExtraData> {
  final FetchScheme schemeFetched;

  MultiCubitFetched({
    @required Filter filter,
    @required int countValues,
    @required BuiltMap<int, Value> allValues,
    @required ExtraData extraData,
    @required this.schemeFetched,
  })  : assert(schemeFetched != null),
        super(
          filter: filter,
          countValues: countValues,
          allValues: allValues,
          extraData: extraData,
        );

  @override
  List<Object> get props => super.props..add(schemeFetched);
}
