import 'package:value_bloc/src/utils.dart';

abstract class ObjectFetchEvent<V> {
  factory ObjectFetchEvent.failed({Object failure}) = FailedFetchEvent<V>;

  factory ObjectFetchEvent.empty() = EmptyFetchEvent<V>;

  factory ObjectFetchEvent.fetched(V value) = ObjectFetchedEvent<V>;
}

abstract class IterableFetchEvent<V> {
  factory IterableFetchEvent.failed({Object failure}) = FailedFetchEvent<V>;

  factory IterableFetchEvent.empty() = EmptyFetchEvent<V>;

  factory IterableFetchEvent.fetched(V value, {int total}) = IterableFetchedEvent<V>;
}
