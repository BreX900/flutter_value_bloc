import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rxdart/src/utils/forwarding_sink.dart';
import 'package:rxdart/src/utils/forwarding_stream.dart';
import 'package:value_bloc/src/object/ObjectCubit.dart';

class Optional<TValue> {
  final bool hasValue;
  final TValue? value;

  const Optional()
      : hasValue = false,
        value = null;

  Optional.of(this.value) : hasValue = true;

  TValue? ifAbsent(TValue value) => hasValue ? this.value : value;
}

class Tuple2<Value1, Value2> {
  final Value1 value1;
  final Value2 value2;

  Tuple2(this.value1, this.value2);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Tuple2 &&
          runtimeType == other.runtimeType &&
          value1 == other.value1 &&
          value2 == other.value2;

  @override
  int get hashCode => value1.hashCode ^ value2.hashCode;
}

mixin FilteredCubit<Filter, State> on Cubit<State> {
  final _filterSubject = PublishSubject<Filter?>();
  StreamSubscription? _filterSub;

  Stream<Filter?> get onFilterChanges => _filterSubject;

  void applyFilter({
    required Filter filter,
  }) async {
    await Future.delayed(Duration());
    await _filterSub?.cancel();
    _filterSubject.add(filter);
  }

  void applyFilterChanges({
    required Stream<Filter> onFilterChanges,
  }) async {
    await Future.delayed(Duration());
    await _filterSub?.cancel();
    _filterSub = onFilterChanges.listen(_filterSubject.add);
  }

  void applyFilterCubit({
    required ObjectCubit<Filter, Object> filterCubit,
  }) async {
    await Future.delayed(Duration());
    await _filterSub?.cancel();
    _filterSub = filterCubit.stream.listen((filterState) {
      if (filterState is ObjectCubitUpdated<Filter, Object>) {
        _filterSubject.add(filterState.value);
      }
    });
  }

  @override
  Future<void> close() {
    _filterSub?.cancel();
    _filterSubject.close();
    return super.close();
  }
}

class Utils {
  static Stream<Filter> createFilterStream<Filter>({
    required Stream<Filter> filterStream,
    Filter? initialFilter,
    bool canWaitFirstFilter = false,
    bool Function(Filter e1, Filter e2)? filterEquals,
    Duration? filterDebounceTime,
  }) {
    if (filterDebounceTime != null) filterStream.debounceTime(filterDebounceTime);
    return filterStream.distinct(filterEquals);
  }
}

class _MakeUniqueStreamSink<S, T> implements ForwardingSink<S, T> {
  final MapEntry<Object, Stream<T>> Function(S value) _mapper;
  final List<StreamSubscription<T>> _subscriptions = <StreamSubscription<T>>[];
  final keys = <Object>{};
  bool _inputClosed = false;

  _MakeUniqueStreamSink(this._mapper);

  @override
  void add(EventSink<T> sink, S data) {
    final entityStream = _mapper(data);
    final keyStream = entityStream.key;
    final mappedStream = entityStream.value;

    if (keys.contains(keyStream)) return;

    keys.add(keyStream);

    StreamSubscription<T>? subscription;

    subscription = mappedStream.listen(
      sink.add,
      onError: sink.addError,
      onDone: () {
        keys.remove(keyStream);
        _subscriptions.remove(subscription);

        if (_inputClosed && keys.isEmpty) {
          sink.close();
        }
      },
    );

    _subscriptions.add(subscription);
  }

  @override
  void addError(EventSink<T> sink, dynamic e, [st]) => sink.addError(e, st);

  @override
  void close(EventSink<T> sink) {
    _inputClosed = true;

    if (keys.isEmpty) {
      sink.close();
    }
  }

  @override
  FutureOr onCancel(EventSink<T> sink) =>
      Future.wait<dynamic>(_subscriptions.map((s) => s.cancel()));

  @override
  void onListen(EventSink<T> sink) {}

  @override
  void onPause(EventSink<T> sink, [Future? resumeSignal]) =>
      _subscriptions.forEach((s) => s.pause(resumeSignal));

  @override
  void onResume(EventSink<T> sink) => _subscriptions.forEach((s) => s.resume());
}

class MakeUniqueStreamTransformer<S, T> extends StreamTransformerBase<S, T> {
  final MapEntry<Object, Stream<T>> Function(S value) mapper;

  MakeUniqueStreamTransformer(this.mapper);

  @override
  Stream<T> bind(Stream<S> stream) => forwardStream(stream, _MakeUniqueStreamSink(mapper));
}

extension MakeUniqueStreamExtension<S> on Stream<S> {
  /// Similar to flatMap but only listen to one stream per key.
  ///
  /// If it is already listening to a stream with the same key it will ignore the new stream.
  /// It will only listen to the new stream if the previous stream with the same key has been closed.
  Stream<T> makeUnique<T>(MapEntry<Object, Stream<T>> Function(S value) mapper) {
    return transform(MakeUniqueStreamTransformer(mapper));
  }
}
