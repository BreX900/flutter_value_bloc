import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:rxdart/rxdart.dart';
import 'package:value_bloc/src/object/ObjectCubit.dart';

class Optional<TValue> {
  final bool hasValue;
  final TValue value;

  const Optional()
      : hasValue = false,
        value = null;

  Optional.of(this.value) : hasValue = true;

  TValue ifAbsent(TValue value) => hasValue ? this.value : value;
}

class Tuple2<Value1, Value2> {
  final Value1 value1;
  final Value2 value2;

  Tuple2(this.value1, this.value2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple2 &&
          runtimeType == other.runtimeType &&
          value1 == other.value1 &&
          value2 == other.value2;

  @override
  int get hashCode => value1.hashCode ^ value2.hashCode;
}

mixin FilteredCubit<Filter, State> on Cubit<State> {
  final _filterSubject = PublishSubject<Filter>();
  StreamSubscription _filterSub;

  Stream<Filter> get onFilterChanges => _filterSubject;

  void applyFilter({
    @required Filter filter,
  }) async {
    await Future.delayed(Duration());
    await _filterSub?.cancel();
    _filterSubject.add(filter);
  }

  void applyFilterChanges({
    @required Stream<Filter> onFilterChanges,
  }) async {
    assert(onFilterChanges != null);
    await Future.delayed(Duration());
    await _filterSub?.cancel();
    _filterSub = onFilterChanges.listen(_filterSubject.add);
  }

  void applyFilterCubit({
    @required ObjectCubit<Filter, Object> filterCubit,
  }) async {
    assert(filterCubit != null);
    await Future.delayed(Duration());
    await _filterSub?.cancel();
    _filterSub = filterCubit.listen((filterState) {
      if (filterState is ObjectCubitUpdated<Filter, Object>) {
        _filterSubject.add(filterState.value);
      }
    });
  }

  @override
  Future<void> close() {
    _filterSub?.cancel();
    _filterSubject.close();
    return super.close();
  }
}

class Utils {
  static Stream<Filter> createFilterStream<Filter>({
    @required Stream<Filter> filterStream,
    Filter initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter e1, Filter e2) filterEquals,
    Duration filterDebounceTime,
  }) {
    if (filterDebounceTime != null) filterStream.debounceTime(filterDebounceTime);
    return filterStream.distinct(filterEquals);
  }
}
