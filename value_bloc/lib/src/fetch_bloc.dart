import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'fetch_bloc.g.dart';

@DataClass()
abstract class DataState<TSuccess> with _$DataState<TSuccess> {
  bool get isLoaded => hasData || hasError;

  bool get hasError;

  bool get hasData;
  TSuccess get data => hasData ? dataOrNull as TSuccess : throw 'Missing data';
  TSuccess? get dataOrNull;

  const DataState();

  R map<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(TSuccess value) success,
  });

  R maybeMap<R>({
    R Function()? loading,
    R Function(Object error, StackTrace st)? error,
    R Function(TSuccess value)? success,
    required R Function() orElse,
  }) {
    return map(loading: () {
      return (loading ?? orElse)();
    }, error: (e, st) {
      return error != null ? error(e, st) : orElse();
    }, success: (data) {
      return success != null ? success(data) : orElse();
    });
  }

  DataState<TSuccess> toLoading() {
    final state = this;
    if (state is ErrorData<TSuccess>) {
      return ErrorData(
        isLoading: true,
        error: state.error,
        stackTrace: state.stackTrace,
        hasData: hasData,
        dataOrNull: dataOrNull,
      );
    } else if (state is SuccessData<TSuccess>) {
      return SuccessData(
        isLoading: true,
        error: null,
        stackTrace: null,
        data: state.data,
      );
    }
    return LoadingData();
  }

  DataState<TSuccess> toError(Object error, StackTrace stackTrace) {
    return ErrorData(
      isLoading: false,
      error: error,
      stackTrace: stackTrace,
      hasData: hasData,
      dataOrNull: dataOrNull,
    );
  }

  DataState<TSuccess> toSuccess(TSuccess data) {
    return SuccessData(
      isLoading: false,
      error: null,
      stackTrace: null,
      data: data,
    );
  }
}

@DataClass()
class LoadingData<TSuccess> extends DataState<TSuccess> with _$LoadingData<TSuccess> {
  @override
  bool get hasError => false;
  @override
  bool get hasData => false;
  @override
  TSuccess? get dataOrNull => null;

  const LoadingData();

  @override
  R map<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(TSuccess value) success,
  }) {
    return loading();
  }
}

@DataClass()
class ErrorData<TSuccess> extends DataState<TSuccess> with _$ErrorData<TSuccess> {
  final bool isLoading;
  @override
  bool get hasError => true;

  final Object error;
  final StackTrace stackTrace;

  @override
  final bool hasData;
  @override
  final TSuccess? dataOrNull;

  const ErrorData({
    required this.isLoading,
    required this.error,
    required this.stackTrace,
    required this.hasData,
    required this.dataOrNull,
  });

  @override
  R map<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(TSuccess value) success,
  }) {
    return error(this.error, this.stackTrace);
  }
}

@DataClass()
class SuccessData<TSuccess> extends DataState<TSuccess> with _$SuccessData<TSuccess> {
  final bool isLoading;
  @override
  bool get hasError => error != null;

  final Object? error;
  final StackTrace? stackTrace;

  @override
  bool get hasData => true;
  @override
  final TSuccess dataOrNull;

  const SuccessData({
    required this.isLoading,
    required this.error,
    required this.stackTrace,
    required TSuccess data,
  }) : dataOrNull = data;

  @override
  R map<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(TSuccess value) success,
  }) {
    return success(this.dataOrNull);
  }
}

class _CancelledFutureException implements Exception {}

abstract class DataBloc<TSuccess> extends Cubit<DataState<TSuccess>> {
  var _key = const Object();
  Completer<TSuccess>? _result;

  DataBloc() : super(LoadingData<TSuccess>()) {
    _init();
  }

  Future<TSuccess?> tryFetch() async {
    try {
      return await fetch();
    } catch (_) {
      return null;
    }
  }

  Future<TSuccess> fetch() async {
    _key = Object();
    emit(state.toLoading());
    try {
      return await _fetching(_key);
    } on _CancelledFutureException {
      return await _result!.future;
    }
  }

  Future<TSuccess> _fetching(Object key) async {
    _result ??= Completer()..future.ignore(); // Ignore the error because it is thrown in the zone
    late TSuccess result;
    try {
      result = await onFetching();
    } catch (error, stackTrace) {
      if (_key != key) throw _CancelledFutureException();

      onError(error, stackTrace);
      emit(state.toError(error, stackTrace));
      _result!.completeError(error, stackTrace);

      _result = null;
      print('My Herrir');
      rethrow;
    }

    if (_key != key) throw _CancelledFutureException();

    emit(state.toSuccess(result));
    _result!.complete(result);

    _result = null;
    return result;
  }

  void _init() async {
    try {
      await _fetching(_key);
    } catch (_) {}
  }

  @protected
  Future<TSuccess> onFetching();
}
