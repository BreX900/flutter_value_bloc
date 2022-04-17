// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fetch_bloc.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides

mixin _$DataState<TData> {
  DataState<TData> get _self => this as DataState<TData>;

  Iterable<Object?> get _props sync* {}

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$DataState<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('DataState', [TData])).toString();
}

mixin _$FetchingData<TData> {
  FetchingData<TData> get _self => this as FetchingData<TData>;

  Iterable<Object?> get _props sync* {
    yield _self.hasData;
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$FetchingData<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('FetchingData', [TData])
        ..add('hasData', _self.hasData)
        ..add('data', _self.data))
      .toString();
}

mixin _$FailedFetchData<TData> {
  FailedFetchData<TData> get _self => this as FailedFetchData<TData>;

  Iterable<Object?> get _props sync* {
    yield _self.error;
    yield _self.stackTrace;
    yield _self.hasData;
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$FailedFetchData<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('FailedFetchData', [TData])
        ..add('error', _self.error)
        ..add('stackTrace', _self.stackTrace)
        ..add('hasData', _self.hasData)
        ..add('data', _self.data))
      .toString();
}

mixin _$FetchedData<TData> {
  FetchedData<TData> get _self => this as FetchedData<TData>;

  Iterable<Object?> get _props sync* {
    yield _self.data;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$FetchedData<TData> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() =>
      (ClassToString('FetchedData', [TData])..add('data', _self.data))
          .toString();
}
