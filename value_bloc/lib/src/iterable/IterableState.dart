part of 'IterableCubit.dart';

extension FirstValuesExtension<Value> on BuiltMap<int, Value> {
  BuiltList<Value> get firstValues {
    final values = <Value>[];
    for (var i = 0; containsKey(i); i++) {
      values.add(this[i]);
    }
    return values.toBuiltList();
  }
}

abstract class IterableCubitState<Value, ExtraData> with EquatableMixin {
  final int length;
  final BuiltMap<int, Value> allValues;
  final ExtraData extraData;

  IterableCubitState({
    @required this.length,
    @required this.allValues,
    @required this.extraData,
  });

  BuiltList<Value> _values;
  BuiltList<Value> get values => _values ??= allValues.firstValues;

  BuiltList<IterableSection> _sections;
  BuiltList<IterableSection> get sections {
    if (allValues.isEmpty) return BuiltList<IterableSection>();
    if (_sections != null) return _sections;

    final sections = ListBuilder<IterableSection>();
    var startAt = allValues.keys.first;
    var endAt = allValues.keys.first;
    for (var i = allValues.keys.first; i < allValues.keys.last; i++) {
      if (i != endAt) {
        sections.add(IterableSection.of(startAt, endAt));
        startAt = i;
        endAt = i;
      }
    }
    sections.add(IterableSection.of(startAt, endAt));

    return _sections = sections.build();
  }

  bool containsSection(IterableSection section) {
    return sections.any((s) => s.containsOffset(section.startAt));
  }

  IterableCubitState<Value, ExtraData> toUpdating() {
    return IterableCubitUpdating(
      length: length,
      allValues: allValues,
      extraData: extraData,
    );
  }

  IterableCubitState<Value, ExtraData> toUpdateFailed({Object failure}) {
    return IterableCubitUpdateFailed(
      length: length,
      allValues: allValues,
      extraData: extraData,
      failure: failure,
    );
  }

  IterableCubitState<Value, ExtraData> toUpdated({
    int length,
    BuiltMap<int, Value> allValues,
  }) {
    return IterableCubitUpdated(
      length: length ?? this.length,
      allValues: allValues ?? this.allValues,
      extraData: extraData,
      oldAllValues: this.allValues,
    );
  }

  IterableCubitState<Value, ExtraData> toIdle() {
    return IterableCubitIdle(
      allValues: allValues.rebuild((b) => b.clear()),
      extraData: extraData,
    );
  }

  // IterableCubitState<Value, ExtraData> toRemoved({@required BuiltMap<int, Value> allValues}) {
  //   return IterableCubitRemoved(
  //     length: length,
  //     allValues: allValues,
  //     extraData: extraData,
  //   );
  // }
  //
  // IterableCubitState<Value, ExtraData> toAdded({@required BuiltMap<int, Value> allValues}) {
  //   return IterableCubitAdded(
  //     length: length,
  //     allValues: allValues,
  //     extraData: extraData,
  //   );
  // }

  @override
  List<Object> get props => [length, allValues, extraData];
}

/// The job list is being updated
class IterableCubitUpdating<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitUpdating({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}

class IterableCubitUpdateFailed<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final Object failure;

  IterableCubitUpdateFailed({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
    this.failure,
  }) : super(length: length, allValues: allValues, extraData: extraData);

  @override
  List<Object> get props => super.props..add(failure);
}

/// The job list has been updated
/// [ListCubit] The old values have been replaced by the new ones
/// [MultiCubit] New values have been added to the previous values
class IterableCubitUpdated<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final BuiltMap<int, Value> oldAllValues;

  BuiltList<Value> _oldValues;
  BuiltList<Value> get oldValues => _oldValues ??= oldAllValues.firstValues;

  BuiltList<Value> _losValues;
  BuiltList<Value> get lostValues {
    return _losValues ??= oldValues.where((value) => !values.contains(value)).toBuiltList();
  }

  BuiltList<Value> _newValues;
  BuiltList<Value> get newValues {
    return _newValues ??= values.where((value) => !oldValues.contains(value)).toBuiltList();
  }

  IterableCubitUpdated({
    int length,
    @required BuiltMap<int, Value> allValues,
    ExtraData extraData,
    @required this.oldAllValues,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}

/// All values have been removed
/// [ListCubit] All values have been removed
/// [MultiCubit] All values have been removed and you call fetch when receive this state
///              it is a initial State
class IterableCubitIdle<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  IterableCubitIdle({
    @required BuiltMap<int, Value> allValues,
    @required ExtraData extraData,
  }) : super(length: null, allValues: allValues, extraData: extraData);
}

// class IterableCubitAdded<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
//   IterableCubitAdded({
//     int length,
//     @required BuiltMap<int, Value> allValues,
//     ExtraData extraData,
//   }) : super(length: length, allValues: allValues, extraData: extraData);
// }
//
// class IterableCubitRemoved<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
//   IterableCubitRemoved({
//     int length,
//     @required BuiltMap<int, Value> allValues,
//     ExtraData extraData,
//   }) : super(length: length, allValues: allValues, extraData: extraData);
// }
