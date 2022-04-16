// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_bloc.dart';

// **************************************************************************
// DataClassGenerator
// **************************************************************************

// ignore_for_file: annotate_overrides

mixin _$Job<T> {
  Job<T> get _self => this as Job<T>;

  Iterable<Object?> get _props sync* {}

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$Job<T> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('Job', [T])).toString();
}

mixin _$IdleJob<T> {
  IdleJob<T> get _self => this as IdleJob<T>;

  Iterable<Object?> get _props sync* {}

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$IdleJob<T> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('IdleJob', [T])).toString();
}

mixin _$LoadingJob<T> {
  LoadingJob<T> get _self => this as LoadingJob<T>;

  Iterable<Object?> get _props sync* {}

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$LoadingJob<T> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('LoadingJob', [T])).toString();
}

mixin _$ErrorJob<T> {
  ErrorJob<T> get _self => this as ErrorJob<T>;

  Iterable<Object?> get _props sync* {
    yield _self.error;
    yield _self.stackTrace;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$ErrorJob<T> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() => (ClassToString('ErrorJob', [T])
        ..add('error', _self.error)
        ..add('stackTrace', _self.stackTrace))
      .toString();
}

mixin _$SuccessJob<T> {
  SuccessJob<T> get _self => this as SuccessJob<T>;

  Iterable<Object?> get _props sync* {
    yield _self.value;
  }

  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _$SuccessJob<T> &&
          runtimeType == other.runtimeType &&
          DataClass.$equals(_props, other._props);

  int get hashCode => Object.hashAll(_props);

  String toString() =>
      (ClassToString('SuccessJob', [T])..add('value', _self.value)).toString();
}
