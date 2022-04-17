// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_bloc.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides

mixin _$DemandState<TData> {
  DemandState<TData> get _self => this as DemandState<TData>;

  Iterable<Object?> get _props sync* {}

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$DemandState<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('DemandState', [TData])).toString();
}

mixin _$LoadingDemand<TData> {
  LoadingDemand<TData> get _self => this as LoadingDemand<TData>;

  Iterable<Object?> get _props sync* {
    yield _self.hasData;
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$LoadingDemand<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('LoadingDemand', [TData])
        ..add('hasData', _self.hasData)
        ..add('data', _self.data))
      .toString();
}

mixin _$FailedDemand<TData> {
  FailedDemand<TData> get _self => this as FailedDemand<TData>;

  Iterable<Object?> get _props sync* {
    yield _self.error;
    yield _self.stackTrace;
    yield _self.hasData;
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$FailedDemand<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('FailedDemand', [TData])
        ..add('error', _self.error)
        ..add('stackTrace', _self.stackTrace)
        ..add('hasData', _self.hasData)
        ..add('data', _self.data))
      .toString();
}

mixin _$SuccessDemand<TData> {
  SuccessDemand<TData> get _self => this as SuccessDemand<TData>;

  Iterable<Object?> get _props sync* {
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$SuccessDemand<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() =>
      (ClassToString('SuccessDemand', [TData])..add('data', _self.data))
          .toString();
}
