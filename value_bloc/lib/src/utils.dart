import 'package:meta/meta.dart';
import 'package:value_bloc/src/internalUtils.dart';

abstract class FetchEvent<V> {
  FetchEvent._();

  factory FetchEvent.empty() = FetchEmptyEvent;

  factory FetchEvent.failed() = FetchFailedEvent;

  factory FetchEvent.fetched({@required V value}) = FetchedEvent;
}
