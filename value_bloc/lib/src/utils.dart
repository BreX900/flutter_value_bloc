import 'package:meta/meta.dart';
import 'package:value_bloc/src/utils.internal.dart';

typedef Fetcher<V> = Stream<FetchEvent<V>> Function();

abstract class FetchEvent<V> {
  FetchEvent._();

  factory FetchEvent.fetching({@required double progress}) = FetchingEvent;

  factory FetchEvent.empty() = FetchEmptyEvent;

  factory FetchEvent.failed() = FetchFailedEvent;

  factory FetchEvent.fetched({@required V value}) = FetchedEvent;
}
