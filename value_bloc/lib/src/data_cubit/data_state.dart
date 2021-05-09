part of 'data_cubit.dart';

enum DataStatus {
  idle,
  waiting,
  creating,
  createFailed,
  created,
  reading,
  readFailed,
  read,
  updating,
  updateFailed,
  updated,
  deleting,
  deleteFailed,
  deleted,
}

extension DataStatusExtensions on DataStatus {
  bool get isIdle => this == DataStatus.idle;
  bool get isWaiting => this == DataStatus.waiting;

  bool get isProcessing {
    switch (this) {
      case DataStatus.creating:
      case DataStatus.reading:
      case DataStatus.updating:
      case DataStatus.deleting:
        return true;
      default:
        return false;
    }
  }

  bool get isFailed {
    switch (this) {
      case DataStatus.createFailed:
      case DataStatus.readFailed:
      case DataStatus.updateFailed:
      case DataStatus.deleteFailed:
        return true;
      default:
        return false;
    }
  }

  bool get isSuccess {
    switch (this) {
      case DataStatus.created:
      case DataStatus.read:
      case DataStatus.updated:
      case DataStatus.deleted:
        return true;
      default:
        return false;
    }
  }

  bool get isCompleted => isFailed || isSuccess;

  bool get canProcess {
    switch (this) {
      case DataStatus.idle:
      case DataStatus.created:
      case DataStatus.read:
      case DataStatus.updated:
        return true;
      default:
        return false;
    }
  }

  Option<F> resolveFailure<F>(Option<F> current, Option<F>? next) {
    if (next != null) return next;
    return isFailed ? current : None();
  }

  Option<D> resolveData<D>(Option<D> current, Option<D>? next) {
    if (next != null) return next;
    switch (this) {
      case DataStatus.created:
      case DataStatus.reading:
      case DataStatus.readFailed:
      case DataStatus.read:
      case DataStatus.updating:
      case DataStatus.updateFailed:
      case DataStatus.updated:
      case DataStatus.deleting:
      case DataStatus.deleteFailed:
        return current;
      default:
        return None();
    }
  }
}

abstract class DataState<TFailure, TData> with EquatableMixin {
  final DataStatus status;
  final Option<TFailure> _failure;
  final Option<TData> _data;

  DataState({
    required this.status,
    required Option<TFailure> failure,
    required Option<TData> data,
  })   : _failure = failure,
        _data = data;

  bool get hasFailure => _failure.isSome();
  bool get notHasFailure => _failure.isNone();
  TFailure get failure => tryFailure!;
  TFailure? get tryFailure => _failure.fold(() => null, (a) => a);

  bool get hasData => _data.isSome();
  bool get notHasData => _failure.isNone();
  TData get data => tryData!;
  TData? get tryData => _data.fold(() => null, (a) => a);

  DataState<TFailure, TData> copyWith({
    DataStatus? status,
    Option<TFailure>? failure,
  });

  @override
  late final List<Object?> props = [_failure, _data];
}

class SingleDataState<TFailure, TData> extends DataState<TFailure, TData> {
  SingleDataState({
    required DataStatus status,
    required Option<TFailure> failure,
    required Option<TData> data,
  }) : super(status: status, failure: failure, data: data);

  @override
  SingleDataState<TFailure, TData> copyWith({
    DataStatus? status,
    Option<TFailure>? failure,
    Option<TData>? data,
  }) {
    final nextStatus = status ?? this.status;
    return SingleDataState(
      status: nextStatus,
      failure: nextStatus.resolveFailure(_failure, failure),
      data: nextStatus.resolveData(_data, data),
    );
  }
}

class MultiDataState<TFailure, TData> extends DataState<TFailure, BuiltList<TData>> {
  final int? length;
  final Option<BuiltMap<int, TData>> _allData;

  MultiDataState({
    required DataStatus status,
    required Option<TFailure> failure,
    required this.length,
    required Option<BuiltMap<int, TData>> allData,
  })   : _allData = allData,
        super(status: status, failure: failure, data: allData.map((a) => a.values.toBuiltList()));

  bool contains(PageOffset offset) {
    return _allData.fold(() => false, (a) => a.length >= offset.endAt);
  }

  bool get isFull {
    if (length == null) return false;
    return _allData.fold(() => false, (a) => a.length >= length!);
  }

  @override
  MultiDataState<TFailure, TData> copyWith({
    DataStatus? status,
    Option<TFailure>? failure,
    Option<BuiltMap<int, TData>>? allData,
    int? length,
  }) {
    final nextStatus = status ?? this.status;
    return MultiDataState(
      status: nextStatus,
      failure: nextStatus.resolveFailure(_failure, failure),
      length: length ?? this.length,
      allData: nextStatus.resolveData(_allData, allData),
    );
  }
}
