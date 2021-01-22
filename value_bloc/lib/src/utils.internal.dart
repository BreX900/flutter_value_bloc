import 'package:meta/meta.dart';
import 'package:value_bloc/src/utils.dart';

class FetchingEvent<V> implements FetchEvent<V> {
  final double progress;

  FetchingEvent({@required this.progress});
}

class FetchEmptyEvent<V> implements FetchEvent<V> {
  FetchEmptyEvent();
}

class FetchFailedEvent<V> implements FetchEvent<V> {
  FetchFailedEvent();
}

class FetchedEvent<V> implements FetchEvent<V> {
  final V value;

  FetchedEvent({@required this.value});
}
