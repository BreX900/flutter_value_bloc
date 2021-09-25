part of 'data_blocs.dart';

abstract class DataBlocState<TFailure, TValue> extends Equatable {
  /// [data] is valid
  final bool hasValidData;
  final bool isEmitting;
  final Option<TFailure> _failure;
  final Option<TValue> _data;

  bool get hasFailure => _failure.isSome();
  TFailure get failure => _failure.getOrElse(() => throw 'Not has failure! $this');
  TFailure? get failureOrNull => _failure.fold(() => null, (a) => a);

  bool get hasData => _data.isSome();
  TValue get data => _data.getOrElse(() => throw 'Not has value! $this');

  /// You can call read and create
  bool get canInitialize {
    if (isEmitting) return false;
    if (hasFailure) return false;
    return !(hasData && hasValidData);
  }

  bool get isInitialized {
    if (isEmitting) return true;
    if (hasFailure) return true;
    return hasData && hasValidData;
  }

  bool get canPerformAction => !isEmitting;

  bool get canPerformDataAction {
    if (isEmitting) return false;
    return hasValidData && hasData;
  }

  DataBlocState({
    required this.hasValidData,
    required this.isEmitting,
    required Option<TFailure> failure,
    required Option<TValue> data,
  })  : _failure = failure,
        _data = data;

  DataBlocState<TFailure, TValue> copyWith({
    bool? hasValidData,
    bool? isEmitting,
    Option<TFailure>? failure,
  });

  @override
  String toString() {
    return (newBuiltValueToStringHelper('$runtimeType')
          ..add('isValid', hasValidData)
          ..add('isEmitting', isEmitting)
          ..add('failure', hasFailure ? failure : null)
          ..add('data', hasData ? data : null))
        .toString();
  }

  @override
  List<Object?> get props => [hasValidData, isEmitting, _failure, _data];
}

class SingleDataBlocState<TFailure, TValue> extends DataBlocState<TFailure, TValue> {
  SingleDataBlocState({
    required bool hasValidData,
    required bool isEmitting,
    required Option<TFailure> failure,
    required Option<TValue> value,
  }) : super(hasValidData: hasValidData, isEmitting: isEmitting, failure: failure, data: value);

  @override
  SingleDataBlocState<TFailure, TValue> copyWith({
    bool? hasValidData,
    bool? isEmitting,
    Option<TFailure>? failure,
    Option<TValue>? value,
  }) {
    return SingleDataBlocState(
      hasValidData: hasValidData ?? this.hasValidData,
      isEmitting: isEmitting ?? this.isEmitting,
      failure: failure ?? _failure,
      value: value ?? _data,
    );
  }
}

class MultiDataBlocState<TFailure, TValue> extends DataBlocState<TFailure, BuiltList<TValue>> {
  final Option<BuiltMap<int, TValue>> _allData;

  MultiDataBlocState({
    required bool isValid,
    required bool isEmitting,
    required Option<TFailure> failure,
    required Option<BuiltMap<int, TValue>> values,
  })  : _allData = values,
        super(
          hasValidData: isValid,
          isEmitting: isEmitting,
          failure: failure,
          data: values.map((allData) => allData.values.toBuiltList()),
        );

  @override
  MultiDataBlocState<TFailure, TValue> copyWith({
    bool? hasValidData,
    bool? isEmitting,
    Option<TFailure>? failure,
    Option<BuiltMap<int, TValue>>? values,
  }) {
    return MultiDataBlocState(
      isValid: hasValidData ?? this.hasValidData,
      isEmitting: isEmitting ?? this.isEmitting,
      failure: failure ?? _failure,
      values: values ?? _allData,
    );
  }

  MultiDataBlocState<TFailure, TValue> copyWithList({
    bool? isValid,
    bool? isEmitting,
    Option<TFailure>? failure,
    Option<BuiltList<TValue>>? values,
  }) {
    return copyWith(
      hasValidData: isValid,
      isEmitting: isEmitting,
      failure: failure,
      values: values?.map((a) => a.asMap().build()),
    );
  }
}
