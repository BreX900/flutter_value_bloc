part of 'data_blocs.dart';

enum DataBlocStatus { none, present, invalid }

abstract class DataBlocState<TData, TFailure extends Object> with EquatableMixin {
  final bool isUpdating;

  bool get hasFailure => failure != null;
  final TFailure? failure;

  final DataBlocStatus dataStatus;
  TData get data;

  const DataBlocState({
    required this.isUpdating,
    required this.failure,
    required this.dataStatus,
  });

  bool get hasData => dataStatus != DataBlocStatus.none;
  bool get hasValidData => dataStatus != DataBlocStatus.invalid;

  bool get isEmpty => !hasFailure && !hasData;

  bool get isEmptyIdle => !isUpdating && !hasFailure && !hasData;

  bool get isSuccessfullyIdle => !isUpdating && !hasFailure && hasData;
  bool get isFailedIdle => !isUpdating && hasFailure;

  bool get isIdle => !isUpdating;

  /// You can call read and create
  bool get canInitialize {
    if (isUpdating) return false;
    if (hasFailure) return false;
    return !(hasData && hasValidData);
  }

  /// DEPRECATED
  bool get isEmitting => isUpdating;

  DataBlocState<TData, TFailure> copyWith({
    bool? isUpdating,
    Param<TFailure?>? failure,
    DataBlocStatus? dataStatus,
  });

  @override
  String toString() {
    return (StateToString('$runtimeType')
          ..check(hasFailure)?.addNull('failure', failure)
          ..addNull('dataStatus', dataStatus)
          ..check(hasData)?.addNull('data', data))
        .toString();
  }
}

class ValueBlocState<TData, TFailure extends Object> extends DataBlocState<TData, TFailure> {
  final Equality<TData> _equality;
  @override
  final TData data;

  factory ValueBlocState({
    Equals<TData>? equals,
    bool isUpdating = false,
    bool? hasData,
    required TData data,
  }) {
    return ValueBlocState.raw(
      equality: SimpleEquality(equals ?? DataBloc.defaultEquals),
      isUpdating: isUpdating,
      failure: null,
      dataStatus: (hasData ?? data != null) ? DataBlocStatus.present : DataBlocStatus.none,
      data: data,
    );
  }

  ValueBlocState.raw({
    required Equality<TData> equality,
    required bool isUpdating,
    required TFailure? failure,
    required DataBlocStatus dataStatus,
    required this.data,
  })  : _equality = equality,
        super(
          isUpdating: isUpdating,
          failure: failure,
          dataStatus: dataStatus,
        );

  @override
  ValueBlocState<TData, TFailure> copyWith({
    bool? isUpdating,
    Param<TFailure?>? failure,
    DataBlocStatus? dataStatus,
    Param<TData>? data,
  }) {
    return ValueBlocState.raw(
      equality: _equality,
      isUpdating: isUpdating ?? this.isUpdating,
      failure: failure == null ? this.failure : failure.value,
      dataStatus: dataStatus ?? this.dataStatus,
      data: data == null ? this.data : data.value,
    );
  }

  ValueBlocState<TData, TFailure> toFailed(TFailure failure) {
    return copyWith(
      isUpdating: false,
      failure: Param(failure),
    );
  }

  ValueBlocState<TData, TFailure> toUpdating() {
    return copyWith(
      isUpdating: true,
      failure: const Param(null),
    );
  }

  TData replace(TData data) {
    if (!hasData) return this.data;
    return _equality.replace(this.data, data);
  }

  ValueBlocState<TData, TFailure> toUpdated(TData data) {
    return copyWith(
      isUpdating: false,
      dataStatus: DataBlocStatus.present,
      data: Param(data),
    );
  }

  ValueBlocState<TData, TFailure> toCleaned() {
    return copyWith(
      isUpdating: false,
      dataStatus: DataBlocStatus.none,
    );
  }

  @override
  List<Object?> get props => [isUpdating, failure, hasData, data];
}

abstract class MultiBlocState<TState extends MultiBlocState<TState, TData, TFailure>, TData,
    TFailure extends Object> extends DataBlocState<List<TData>, TFailure> {
  @override
  List<TData> get data;

  Map<int, TData> get indexedData;

  MultiBlocState({
    required bool isUpdating,
    required TFailure? failure,
    required DataBlocStatus dataStatus,
  }) : super(
          isUpdating: isUpdating,
          failure: failure,
          dataStatus: dataStatus,
        );

  @override
  TState copyWith({
    bool? isUpdating,
    Param<TFailure?>? failure,
    DataBlocStatus? dataStatus,
  });

  TState toFailed(TFailure failure) {
    return copyWith(
      isUpdating: false,
      failure: Param(failure),
    );
  }

  TState toUpdating() {
    return copyWith(
      isUpdating: true,
      failure: const Param(null),
    );
  }

  TState toCleaned() {
    return copyWith(
      isUpdating: false,
      dataStatus: DataBlocStatus.none,
      failure: const Param(null),
    );
  }
}

class ListBlocState<TData, TFailure extends Object>
    extends MultiBlocState<ListBlocState<TData, TFailure>, TData, TFailure> {
  final Equality<TData> _equality;
  @override
  final List<TData> data;
  Map<int, TData>? _indexedData;
  @override
  Map<int, TData> get indexedData => _indexedData ??= data.asMap();

  factory ListBlocState({
    Equals<TData>? equals,
    bool isUpdating = false,
    Iterable<TData>? data,
  }) {
    return ListBlocState.raw(
      equality: SimpleEquality(equals ?? DataBloc.defaultEquals),
      isUpdating: isUpdating,
      failure: null,
      dataStatus: data != null ? DataBlocStatus.present : DataBlocStatus.none,
      data: data ?? <TData>[],
    );
  }

  ListBlocState.raw({
    required Equality<TData> equality,
    required bool isUpdating,
    required TFailure? failure,
    required DataBlocStatus dataStatus,
    required Iterable<TData> data,
  })  : _equality = equality,
        data = List.unmodifiable(data),
        super(
          isUpdating: isUpdating,
          failure: failure,
          dataStatus: dataStatus,
        );

  @override
  ListBlocState<TData, TFailure> copyWith({
    bool? isUpdating,
    Param<TFailure?>? failure,
    DataBlocStatus? dataStatus,
    Iterable<TData>? data,
  }) {
    return ListBlocState.raw(
      equality: _equality,
      isUpdating: isUpdating ?? this.isUpdating,
      failure: failure == null ? this.failure : failure.value,
      dataStatus: dataStatus ?? this.dataStatus,
      data: data ?? this.data,
    );
  }

  ListBlocState<TData, TFailure> toUpdated(List<TData> data) {
    return copyWith(
      isUpdating: false,
      dataStatus: DataBlocStatus.present,
      data: List.unmodifiable(data),
    );
  }

  Iterable<TData> add(List<TData> values) {
    if (!hasData) return data;
    return [...data, ...values];
  }

  Iterable<TData> addIfAbsent(List<TData> values) {
    if (!hasData) return data;
    return _equality.addAllIfAbsent(data, values);
  }

  Iterable<TData> update(List<TData> values) {
    if (!hasData) return data;
    return _equality.updateAll(data, values);
  }

  Iterable<TData> replace(Map<TData, TData> values) {
    if (!hasData) return data;
    return _equality.replaceAll(data, values);
  }

  Iterable<TData> remove(List<TData> values) {
    if (!hasData) return data;
    return _equality.whereNotContainsAll(data, values);
  }

  @override
  List<Object?> get props => [isUpdating, failure, hasData, data];
}

// class IndexedState {
//   final Ring<TData?> _ring;
// }
