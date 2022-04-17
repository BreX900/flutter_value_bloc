import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'fetch_bloc.g.dart';

@DataClass()
abstract class DataState<TSuccess> with _$DataState<TSuccess> {
  bool get hasError => false;
  Object? get error => null;
  StackTrace? get stackTrace => null;

  bool get hasData => false;
  TSuccess? get data => null;
  TSuccess get requiredData => hasData ? data as TSuccess : throw 'Missing data';

  const DataState();

  bool get isFetching => this is FetchingData<TSuccess>;
  bool get isFailed => this is FailedFetchData<TSuccess>;
  bool get isFetched => this is FetchedData<TSuccess>;

  bool get isLoading => !(hasData || hasError);
  bool get isLoaded => hasData || hasError;

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
    return FetchingData(
      hasData: hasData,
      data: data,
    );
  }

  DataState<TSuccess> toError(Object error, StackTrace stackTrace) {
    return FailedFetchData(
      error: error,
      stackTrace: stackTrace,
      hasData: hasData,
      data: data,
    );
  }

  DataState<TSuccess> toSuccess(TSuccess data) {
    return FetchedData(
      data: data,
    );
  }
}

@DataClass()
class FetchingData<TSuccess> extends DataState<TSuccess> with _$FetchingData<TSuccess> {
  @override
  final bool hasData;
  @override
  final TSuccess? data;

  const FetchingData({
    required this.hasData,
    required this.data,
  });

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
class FailedFetchData<TSuccess> extends DataState<TSuccess> with _$FailedFetchData<TSuccess> {
  @override
  bool get hasError => true;

  final Object error;
  final StackTrace stackTrace;

  @override
  final bool hasData;
  @override
  final TSuccess? data;

  const FailedFetchData({
    required this.error,
    required this.stackTrace,
    required this.hasData,
    required this.data,
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
class FetchedData<TSuccess> extends DataState<TSuccess> with _$FetchedData<TSuccess> {
  @override
  bool get hasData => true;
  @override
  final TSuccess data;

  const FetchedData({
    required this.data,
  });

  @override
  R map<R>({
    required R Function() loading,
    required R Function(Object error, StackTrace st) error,
    required R Function(TSuccess value) success,
  }) {
    return success(this.data);
  }
}

class _CancelledFutureException implements Exception {}

abstract class DataBloc<TSuccess> extends Cubit<DataState<TSuccess>> {
  var _key = const Object();
  Completer<TSuccess>? _result;

  DataBloc() : super(FetchingData<TSuccess>(hasData: false, data: null)) {
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
      onError(error, stackTrace);
      if (_key != key) throw _CancelledFutureException();

      emit(state.toError(error, stackTrace));
      _result!.completeError(error, stackTrace);

      _result = null;
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
