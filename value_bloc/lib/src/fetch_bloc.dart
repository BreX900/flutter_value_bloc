import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:mek_data_class/mek_data_class.dart';
import 'package:meta/meta.dart';

part 'fetch_bloc.g.dart';

@DataClass()
abstract class DemandState<TData> with _$DemandState<TData> {
  bool get hasError => false;
  Object? get error => null;
  Object get requiredError => hasError ? error as Object : throw 'Missing error';
  StackTrace? get stackTrace => null;

  bool get hasData => false;
  TData? get data => null;
  TData get requiredData => hasData ? data as TData : throw 'Missing data';

  const DemandState();

  bool get isLoading => this is LoadingDemand<TData>;
  bool get isFailed => this is FailedDemand<TData>;
  bool get isSuccess => this is SuccessDemand<TData>;

  bool get isInitialing => !(hasData || hasError);

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
    required R Function(LoadingDemand<TData> state) loading,
    required R Function(FailedDemand<TData> state) failed,
    required R Function(SuccessDemand<TData> state) success,
  });

  R maybeMap<R>({
    R Function(LoadingDemand<TData> state)? loading,
    R Function(FailedDemand<TData> state)? failed,
    R Function(SuccessDemand<TData> state)? success,
    required R Function(DemandState<TData> state) orElse,
  }) {
    return map(
      loading: loading ?? orElse,
      failed: failed ?? orElse,
      success: success ?? orElse,
    );
  }

  DemandState<TData> toFetching() {
    return LoadingDemand(
      hasData: hasData,
      data: data,
    );
  }

  DemandState<TData> toFetchFailed(Object error, StackTrace stackTrace) {
    return FailedDemand(
      error: error,
      stackTrace: stackTrace,
      hasData: hasData,
      data: data,
    );
  }

  DemandState<TData> toFetched(TData data) {
    return SuccessDemand(
      data: data,
    );
  }
}

@DataClass()
class LoadingDemand<TData> extends DemandState<TData> with _$LoadingDemand<TData> {
  @override
  final bool hasData;
  @override
  final TData? data;

  const LoadingDemand({
    required this.hasData,
    required this.data,
  });

  @override
  R map<R>({
    required R Function(LoadingDemand<TData> state) loading,
    required R Function(FailedDemand<TData> state) failed,
    required R Function(SuccessDemand<TData> state) success,
  }) {
    return loading(this);
  }
}

@DataClass()
class FailedDemand<TData> extends DemandState<TData> with _$FailedDemand<TData> {
  @override
  bool get hasError => true;

  final Object error;
  final StackTrace stackTrace;

  @override
  final bool hasData;
  @override
  final TData? data;

  const FailedDemand({
    required this.error,
    required this.stackTrace,
    required this.hasData,
    required this.data,
  });

  @override
  R map<R>({
    required R Function(LoadingDemand<TData> state) loading,
    required R Function(FailedDemand<TData> state) failed,
    required R Function(SuccessDemand<TData> state) success,
  }) {
    return failed(this);
  }
}

@DataClass()
class SuccessDemand<TData> extends DemandState<TData> with _$SuccessDemand<TData> {
  @override
  bool get hasData => true;
  @override
  final TData data;

  const SuccessDemand({
    required this.data,
  });

  @override
  R map<R>({
    required R Function(LoadingDemand<TData> state) loading,
    required R Function(FailedDemand<TData> state) failed,
    required R Function(SuccessDemand<TData> state) success,
  }) {
    return success(this);
  }
}

class _CancelledFutureException implements Exception {}

abstract class DemandBloc<TArg, TData> extends Cubit<DemandState<TData>> {
  var _key = const Object();
  Completer<TData>? _result;

  TArg _arg;

  DemandBloc({
    required TArg initialArg,
    TData? initialData,
  })  : _arg = initialArg,
        super(LoadingDemand<TData>(
          hasData: initialData != null,
          data: initialData,
        )) {
    _init(initialArg);
  }

  factory DemandBloc.inline(
    Future<TData> Function(TArg arg) fetcher, {
    required TArg initialArg,
    TData? initialData,
  }) = _InlineDemandBloc<TArg, TData>;

  // TODO: Split to forceFetch and tryForceFetch
  Future<TData> fetch(TArg arg, {bool force = false}) async {
    if (_arg == arg && !force) {
      return state.map(loading: (state) {
        return _result!.future;
      }, failed: (state) {
        throw Error.throwWithStackTrace(state.error, state.stackTrace);
      }, success: (state) {
        return state.data;
      });
    }
    emit(state.toFetching());
    _key = Object();
    _arg = arg;
    try {
      return await _fetching(_key, arg);
    } on _CancelledFutureException {
      return await _result!.future;
    }
  }

  Future<TData?> tryFetch(TArg arg, {bool force = false}) async {
    try {
      return await fetch(arg);
    } catch (_) {
      return null;
    }
  }

  Future<TData> reFetch() async => await fetch(_arg, force: true);

  Future<TData?> tryReFetch() async => await tryFetch(_arg, force: true);

  Future<TData> _fetching(Object key, TArg arg) async {
    _result ??= Completer()..future.ignore(); // Ignore the error because it is thrown in the zone
    late TData result;
    try {
      result = await onFetching(arg);
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

  void _init(TArg arg) async {
    try {
      await _fetching(_key, arg);
    } catch (_) {}
  }

  @protected
  Future<TData> onFetching(TArg arg);
}

class _InlineDemandBloc<TArg, TData> extends DemandBloc<TArg, TData> {
  final Future<TData> Function(TArg arg) fetcher;

  _InlineDemandBloc(
    this.fetcher, {
    required TArg initialArg,
    TData? initialData,
  }) : super(
          initialArg: initialArg,
          initialData: initialData,
        );

  @override
  Future<TData> onFetching(TArg arg) => fetcher(arg);
}
