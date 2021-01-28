import 'package:value_bloc/src/internalUtils.dart';

class FailedFetchEvent<V> implements ObjectFetchEvent<V>, IterableFetchEvent<V> {
  final Object failure;

  FailedFetchEvent({this.failure});
}

class EmptyFetchEvent<V> implements ObjectFetchEvent<V>, IterableFetchEvent<V> {
  EmptyFetchEvent();
}

class ObjectFetchedEvent<V> implements ObjectFetchEvent<V> {
  final V value;

  ObjectFetchedEvent(this.value);
}

class IterableFetchedEvent<V> implements IterableFetchEvent<V> {
  final V values;
  final int total;

  IterableFetchedEvent(this.values, {this.total});
}
