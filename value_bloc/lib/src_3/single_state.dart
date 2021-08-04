import 'package:built_value/built_value.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

class SingleState<TFailure, TValue> extends Equatable {
  final bool isEmitting;
  final Option<TFailure> _failure;
  final Option<TValue> _value;

  bool get hasFailure => _failure.isSome();
  TFailure get failure => _failure.getOrElse(() => throw 'Not has failure! $this');

  bool get hasValue => _value.isSome();
  bool get isEmpty => value == null;
  TValue get value => _value.getOrElse(() => throw 'Not has value! $this');

  bool get hasValueOrFailure => hasFailure || hasValue;

  SingleState({
    required this.isEmitting,
    required Option<TFailure> failure,
    required Option<TValue> value,
  })  : _failure = failure,
        _value = value;

  @override
  List<Object?> get props => [isEmitting, _failure, _value];

  @override
  String toString() {
    return (newBuiltValueToStringHelper('$runtimeType')
          ..add('isEmitting', isEmitting)
          ..add('failure', hasFailure ? '$failure' : null)
          ..add('values', hasValue ? '$value' : null))
        .toString();
  }
}

extension SingleStateCopyWith<TFailure, TValue> on SingleState<TFailure, TValue> {
  SingleState<TFailure, TValue> copyWith({
    bool? isEmitting,
    Option<TFailure>? failure,
    Option<TValue>? value,
  }) {
    return SingleState(
      isEmitting: isEmitting ?? this.isEmitting,
      failure: failure ?? _failure,
      value: value ?? _value,
    );
  }
}
