part of 'IterableCubit.dart';

extension FirstValuesBuiltListExtension<Value> on BuiltMap<int, Value> {
  BuiltList<Value> get firstValues {
    final values = <Value>[];
    for (var i = 0; containsKey(i); i++) {
      values.add(this[i]!);
    }
    return values.toBuiltList();
  }
}

abstract class IterableCubitState<Value, ExtraData> with EquatableMixin {
  /// Defines the maximum amount of possible values. If it is null, it is not known.
  final int? length;

  /// Contains all indexed values.
  ///
  /// It can also contain non-continuous indexes.
  /// For Example: [23: ..., 24: ..., 89: ...]
  final BuiltMap<int, Value> allValues;

  /// What you want :)
  final ExtraData? extraData;

  IterableCubitState({
    required this.length,
    required this.allValues,
    required this.extraData,
  });

  BuiltList<Value>? _values;
  BuiltList<Value> get values => _values ??= allValues.firstValues;

  BuiltList<PageOffset>? _sections;
  BuiltList<PageOffset> get sections {
    if (allValues.isEmpty) return BuiltList<PageOffset>();
    if (_sections != null) return _sections!;

    final sections = ListBuilder<PageOffset>();
    var startAt = allValues.keys.first;
    var endAt = allValues.keys.first - 1;
    for (var i = allValues.keys.first; i < allValues.keys.last; i++) {
      if (i == endAt + 1) {
        endAt = i;
      } else {
        sections.add(PageOffset.of(startAt, endAt));
        startAt = i;
        endAt = i;
      }
    }
    sections.add(PageOffset.of(startAt, endAt));

    return _sections = sections.build();
  }

  bool containsSection(PageOffset section) {
    return sections.any((s) => s.containsOffset(section.startAt));
  }

  BuiltMap<int, Value> get _oldAllValues {
    final state = this;
    if (state is IterableCubitUpdating<Value, ExtraData>) {
      return state.oldAllValues;
    } else {
      return state.allValues;
    }
  }

  IterableCubitState<Value, ExtraData> toUpdating() {
    return IterableCubitUpdating(
      length: null,
      allValues: allValues.rebuild((b) => b.clear()),
      extraData: extraData,
      oldAllValues: _oldAllValues,
    );
  }

  IterableCubitState<Value, ExtraData> toUpdateFailed({Object? failure}) {
    return IterableCubitUpdateFailed(
      length: length,
      allValues: allValues,
      extraData: extraData,
      failure: failure,
    );
  }

  IterableCubitState<Value, ExtraData> toUpdated({
    int? length,
    BuiltMap<int, Value>? allValues,
  }) {
    return IterableCubitUpdated(
      length: length ?? this.length,
      allValues: allValues ?? this.allValues,
      extraData: extraData,
      oldAllValues: _oldAllValues,
    );
  }

  IterableCubitState<Value, ExtraData> copyWith({
    Optional<BuiltMap<int, Value>?> allValues = const Optional(),
    Optional<ExtraData?> extraData = const Optional(),
  }) {
    final state = this;
    final currentValues = allValues.ifAbsent(this.allValues);
    final currentExtraData = extraData.ifAbsent(this.extraData);
    if (state is IterableCubitUpdating<Value, ExtraData>) {
      return IterableCubitUpdating(
        length: length,
        allValues: currentValues!,
        extraData: currentExtraData,
        oldAllValues: state.oldAllValues,
      );
    } else if (state is IterableCubitUpdateFailed<Value, ExtraData>) {
      return IterableCubitUpdateFailed(
        length: length,
        allValues: currentValues!,
        extraData: currentExtraData,
        failure: state.failure,
      );
    } else if (state is IterableCubitUpdated<Value, ExtraData>) {
      return IterableCubitUpdated(
        length: length,
        allValues: currentValues!,
        extraData: currentExtraData,
        oldAllValues: state.oldAllValues,
      );
    } else {
      throw 'Not known "${this}" state';
    }
  }

  @override
  List<Object?> get props => [length, allValues, extraData];
}

/// The job list is being updated.
///
/// If using [MultiCubit], listeners will need to request the current section to refresh it.
class IterableCubitUpdating<Value, ExtraData> extends IterableCubitState<Value, ExtraData>
    with _OldValues {
  @override
  final BuiltMap<int, Value> oldAllValues;

  IterableCubitUpdating({
    int? length,
    required BuiltMap<int, Value> allValues,
    ExtraData? extraData,
    required this.oldAllValues,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}

/// The job is failed.
///
/// The reason for the failure is saved on failure.
class IterableCubitUpdateFailed<Value, ExtraData> extends IterableCubitState<Value, ExtraData> {
  final Object? failure;

  IterableCubitUpdateFailed({
    int? length,
    required BuiltMap<int, Value> allValues,
    ExtraData? extraData,
    this.failure,
  }) : super(length: length, allValues: allValues, extraData: extraData);

  @override
  List<Object?> get props => super.props..add(failure);
}

/// The job list has been updated.
///
/// The values of the previous state will remain available on [oldValues].
class IterableCubitUpdated<Value, ExtraData> extends IterableCubitState<Value, ExtraData>
    with _OldValues {
  @override
  final BuiltMap<int, Value> oldAllValues;

  IterableCubitUpdated({
    int? length,
    required BuiltMap<int, Value> allValues,
    ExtraData? extraData,
    required this.oldAllValues,
  }) : super(length: length, allValues: allValues, extraData: extraData);
}

mixin _OldValues<Value, ExtraData> on IterableCubitState<Value, ExtraData> {
  BuiltMap<int, Value> get oldAllValues;

  BuiltList<Value>? _oldValues;
  BuiltList<Value> get oldValues => _oldValues ??= oldAllValues.firstValues;

  /// Is a difference between [oldValues] and [values]
  ///
  /// Ex. <oldValues>[1, 2, 3, 4] - <values>[1, 2, 3] = <lostValues>[4]
  BuiltList<Value>? _lostValues;
  BuiltList<Value> get lostValues {
    return _lostValues ??= oldValues.where((value) => !values.contains(value)).toBuiltList();
  }

  /// Is a difference between [values] and [oldValues]
  ///
  /// Ex. <values>[1, 2, 3] - <oldValues>[1] = <acquiredValues>[2, 3]
  BuiltList<Value>? _acquiredValues;
  BuiltList<Value> get acquiredValues {
    return _acquiredValues ??= values.where((value) => !oldValues.contains(value)).toBuiltList();
  }
}
