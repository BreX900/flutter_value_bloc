import 'package:built_collection/built_collection.dart';
import 'package:dartz/dartz.dart';
import 'package:value_bloc/src_3/single_state.dart';

class MultiState<TFailure, TValue> implements SingleState<TFailure, BuiltList<TValue>> {
  @override
  final bool isEmitting;
  final Option<TFailure> _failure;
  final Option<BuiltMap<int, TValue>> _values;

  @override
  bool get hasFailure => _failure.isSome();
  @override
  TFailure get failure => _failure.getOrElse(() => throw 'Not has failure! $this');

  @override
  bool get hasValue => _values.isSome();
  @override
  bool get isEmpty => values.isEmpty;
  @override
  BuiltList<TValue> get value => values.values.toBuiltList();

  @override
  bool get hasValueOrFailure => hasFailure || hasValue;

  BuiltMap<int, TValue> get values => _values.getOrElse(() => throw 'Not has value! $this');

  MultiState({
    required this.isEmitting,
    required Option<TFailure> failure,
    required Option<BuiltMap<int, TValue>> values,
  })  : _failure = failure,
        _values = values;

  MultiState<TFailure, TValue> copyWith({
    bool? isEmitting,
    Option<TFailure>? failure,
    Option<BuiltMap<int, TValue>>? values,
  }) {
    return MultiState(
      isEmitting: isEmitting ?? this.isEmitting,
      failure: failure ?? _failure,
      values: values ?? _values,
    );
  }
}
