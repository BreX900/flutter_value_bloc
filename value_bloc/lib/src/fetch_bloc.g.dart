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

mixin _$FetchingData<TSuccess> {
  FetchingData<TSuccess> get _self => this as FetchingData<TSuccess>;

  Iterable<Object?> get _props sync* {
    yield _self.hasData;
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$FetchingData<TSuccess> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('FetchingData', [TSuccess])
        ..add('hasData', _self.hasData)
        ..add('data', _self.data))
      .toString();
}

mixin _$FailedFetchData<TSuccess> {
  FailedFetchData<TSuccess> get _self => this as FailedFetchData<TSuccess>;

  Iterable<Object?> get _props sync* {
    yield _self.error;
    yield _self.stackTrace;
    yield _self.hasData;
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$FailedFetchData<TSuccess> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('FailedFetchData', [TSuccess])
        ..add('error', _self.error)
        ..add('stackTrace', _self.stackTrace)
        ..add('hasData', _self.hasData)
        ..add('data', _self.data))
      .toString();
}

mixin _$FetchedData<TSuccess> {
  FetchedData<TSuccess> get _self => this as FetchedData<TSuccess>;

  Iterable<Object?> get _props sync* {
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$FetchedData<TSuccess> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() =>
      (ClassToString('FetchedData', [TSuccess])..add('data', _self.data))
          .toString();
}
