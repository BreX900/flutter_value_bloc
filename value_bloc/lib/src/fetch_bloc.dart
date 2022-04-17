import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'fetch_bloc.g.dart';

@DataClass()
abstract class DataState<TData> with _$DataState<TData> {
  bool get hasError => false;
  Object? get error => null;
  Object get requiredError => hasError ? error as Object : throw 'Missing error';
  StackTrace? get stackTrace => null;

  bool get hasData => false;
  TData? get data => null;
  TData get requiredData => hasData ? data as TData : throw 'Missing data';

  const DataState();

  bool get isFetching => this is FetchingData<TData>;
  bool get isFailed => this is FailedFetchData<TData>;
  bool get isFetched => this is FetchedData<TData>;

  bool get isLoading => !(hasData || hasError);
  bool get isLoaded => hasData || hasError;

  R mapStatus<R>({
    required R Function() loading,
    required R Function(Object error) error,
    required R Function(TData data) data,
  }) {
    if (hasData) {
      return data(this.requiredData);
    } else if (hasError) {
      return error(this.requiredError);
    } else {
      return loading();
    }
  }

  R maybeMapStatus<R>({
    R Function()? loading,
    R Function(Object error)? error,
    R Function(TData data)? data,
    required R Function() orElse,
  }) {
    return mapStatus(loading: () {
      return loading != null ? loading() : orElse();
    }, error: (e) {
      return error != null ? error(e) : orElse();
    }, data: (d) {
      return data != null ? data(d) : orElse();
    });
  }

  R map<R>({
    required R Function(FetchingData<TData> state) fetching,
    required R Function(FailedFetchData<TData> state) failedFetch,
    required R Function(FetchedData<TData> state) fetched,
  });

  R maybeMap<R>({
    R Function(FetchingData<TData> state)? fetching,
    R Function(FailedFetchData<TData> state)? failedFetch,
    R Function(FetchedData<TData> state)? fetched,
    required R Function(DataState<TData> state) orElse,
  }) {
    return map(
      fetching: fetching ?? orElse,
      failedFetch: failedFetch ?? orElse,
      fetched: fetched ?? orElse,
    );
  }

  DataState<TData> toFetching() {
    return FetchingData(
      hasData: hasData,
      data: data,
    );
  }

  DataState<TData> toFetchFailed(Object error, StackTrace stackTrace) {
    return FailedFetchData(
      error: error,
      stackTrace: stackTrace,
      hasData: hasData,
      data: data,
    );
  }

  DataState<TData> toFetched(TData data) {
    return FetchedData(
      data: data,
    );
  }
}

@DataClass()
class FetchingData<TData> extends DataState<TData> with _$FetchingData<TData> {
  @override
  final bool hasData;
  @override
  final TData? data;

  const FetchingData({
    required this.hasData,
    required this.data,
  });

  @override
  R map<R>({
    required R Function(FetchingData<TData> state) fetching,
    required R Function(FailedFetchData<TData> state) failedFetch,
    required R Function(FetchedData<TData> state) fetched,
  }) {
    return fetching(this);
  }
}

@DataClass()
class FailedFetchData<TData> extends DataState<TData> with _$FailedFetchData<TData> {
  @override
  bool get hasError => true;

  final Object error;
  final StackTrace stackTrace;

  @override
  final bool hasData;
  @override
  final TData? data;

  const FailedFetchData({
    required this.error,
    required this.stackTrace,
    required this.hasData,
    required this.data,
  });

  @override
  R map<R>({
    required R Function(FetchingData<TData> state) fetching,
    required R Function(FailedFetchData<TData> state) failedFetch,
    required R Function(FetchedData<TData> state) fetched,
  }) {
    return failedFetch(this);
  }
}

@DataClass()
class FetchedData<TData> extends DataState<TData> with _$FetchedData<TData> {
  @override
  bool get hasData => true;
  @override
  final TData data;

  const FetchedData({
    required this.data,
  });

  @override
  R map<R>({
    required R Function(FetchingData<TData> state) fetching,
    required R Function(FailedFetchData<TData> state) failedFetch,
    required R Function(FetchedData<TData> state) fetched,
  }) {
    return fetched(this);
  }
}

class Param<T> {
  final T value;

  Param(this.value);
}

class _CancelledFutureException implements Exception {}

abstract class DataBloc<TArgs, TData> extends Cubit<DataState<TData>> {
  var _key = const Object();
  Completer<TData>? _result;

  TArgs _args;

  DataBloc({
    required TArgs initialArgs,
    TData? initialData,
  })  : _args = initialArgs,
        super(FetchingData<TData>(
          hasData: initialData != null,
          data: initialData,
        )) {
    _init(initialArgs);
  }

  factory DataBloc.inline(
    Future<TData> Function(TArgs args) fetcher, {
    required TArgs initialArgs,
    TData? initialData,
  }) = _InlineDataBloc<TArgs, TData>;

  // TODO: Split to forceFetch and tryForceFetch
  Future<TData> fetch(TArgs args, {bool force = false}) async {
    if (_args == args && !force) {
      return state.map(fetching: (state) {
        return _result!.future;
      }, failedFetch: (state) {
        throw Error.throwWithStackTrace(state.error, state.stackTrace);
      }, fetched: (state) {
        return state.data;
      });
    }
    emit(state.toFetching());
    _key = Object();
    _args = args;
    try {
      return await _fetching(_key, args);
    } on _CancelledFutureException {
      return await _result!.future;
    }
  }

  Future<TData?> tryFetch(TArgs args, {bool force = false}) async {
    try {
      return await fetch(args);
    } catch (_) {
      return null;
    }
  }

  Future<TData> reFetch() async => await fetch(_args, force: true);

  Future<TData?> tryReFetch() async => await tryFetch(_args, force: true);

  Future<TData> _fetching(Object key, TArgs args) async {
    _result ??= Completer()..future.ignore(); // Ignore the error because it is thrown in the zone
    late TData result;
    try {
      result = await onFetching(args);
    } catch (error, stackTrace) {
      onError(error, stackTrace);
      if (_key != key) throw _CancelledFutureException();

      emit(state.toFetchFailed(error, stackTrace));
      _result!.completeError(error, stackTrace);

      _result = null;
      rethrow;
    }

    if (_key != key) throw _CancelledFutureException();

    emit(state.toFetched(result));
    _result!.complete(result);

    _result = null;
    return result;
  }

  void _init(TArgs args) async {
    try {
      await _fetching(_key, args);
    } catch (_) {}
  }

  @protected
  Future<TData> onFetching(TArgs args);
}

class _InlineDataBloc<TArgs, TData> extends DataBloc<TArgs, TData> {
  final Future<TData> Function(TArgs args) fetcher;

  _InlineDataBloc(
    this.fetcher, {
    required TArgs initialArgs,
    TData? initialData,
  }) : super(
          initialArgs: initialArgs,
          initialData: initialData,
        );

  @override
  Future<TData> onFetching(TArgs args) => fetcher(args);
}
