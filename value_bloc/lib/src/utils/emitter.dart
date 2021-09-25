import 'dart:async';

import 'package:bloc/bloc.dart';

class EventEmitter<TEvent, TState> implements Emitter<TEvent> {
  final Emitter<TState> emitter;
  final TState? Function(TEvent) converter;

  EventEmitter(this.emitter, this.converter);

  @override
  Future<void> onEach<T>(
    Stream<T> stream, {
    required void Function(T) onData,
    void Function(Object error, StackTrace stackTrace)? onError,
  }) {
    return emitter.onEach(stream, onData: onData, onError: onError);
  }

  @override
  Future<void> forEach<T>(
    Stream<T> stream, {
    required TEvent Function(T) onData,
    TEvent Function(Object error, StackTrace stackTrace)? onError,
  }) {
    throw UnimplementedError('EventEmitter.forEach');
    // return emitter.forEach<T>(
    //   stream,
    //   onData: (data) => converter(onData(data)),
    //   onError: onError != null
    //       ? (Object error, StackTrace stackTrace) {
    //           return converter(onError(error, stackTrace));
    //         }
    //       : null,
    // );
  }

  @override
  void call(TEvent event) {
    final state = converter(event);
    if (state != null) emitter(state);
  }

  @override
  bool get isDone => emitter.isDone;
}
