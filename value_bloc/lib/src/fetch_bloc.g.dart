// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_bloc.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides

mixin _$DataState<TSuccess> {
  DataState<TSuccess> get _self => this as DataState<TSuccess>;

  Iterable<Object?> get _props sync* {}

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$DataState<TSuccess> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('DataState', [TSuccess])).toString();
}

mixin _$LoadingData<TSuccess> {
  LoadingData<TSuccess> get _self => this as LoadingData<TSuccess>;

  Iterable<Object?> get _props sync* {}

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$LoadingData<TSuccess> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('LoadingData', [TSuccess])).toString();
}

mixin _$ErrorData<TSuccess> {
  ErrorData<TSuccess> get _self => this as ErrorData<TSuccess>;

  Iterable<Object?> get _props sync* {
    yield _self.isLoading;
    yield _self.error;
    yield _self.stackTrace;
    yield _self.hasData;
    yield _self.dataOrNull;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$ErrorData<TSuccess> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('ErrorData', [TSuccess])
        ..add('isLoading', _self.isLoading)
        ..add('error', _self.error)
        ..add('stackTrace', _self.stackTrace)
        ..add('hasData', _self.hasData)
        ..add('dataOrNull', _self.dataOrNull))
      .toString();
}

mixin _$SuccessData<TSuccess> {
  SuccessData<TSuccess> get _self => this as SuccessData<TSuccess>;

  Iterable<Object?> get _props sync* {
    yield _self.isLoading;
    yield _self.error;
    yield _self.stackTrace;
    yield _self.dataOrNull;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$SuccessData<TSuccess> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('SuccessData', [TSuccess])
        ..add('isLoading', _self.isLoading)
        ..add('error', _self.error)
        ..add('stackTrace', _self.stackTrace)
        ..add('dataOrNull', _self.dataOrNull))
      .toString();
}
