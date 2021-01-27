import 'package:value_bloc/src/internalUtils.dart';

abstract class FetchEvent<V> {
  FetchEvent._();

  // factory FetchEvent.empty() = FetchEmptyEvent;

  factory FetchEvent.failed({Object failure}) = FetchFailedEvent;

  factory FetchEvent.fetched(V value, {int total}) = FetchedEvent;
}
