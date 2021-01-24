import 'dart:math';

import 'package:meta/meta.dart';
import 'package:value_bloc/src/utils.dart';

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

/// It represent a request for retrieving a values determined by [startAt] and [length]
class FetchScheme {
  /// it is a first position
  final int startAt;

  /// it is a positions count
  final int length;

  /// it is a position after last position
  int get endAt => startAt + length;

  FetchScheme(this.startAt, this.length)
      : assert(startAt != null, 'startAt is "$startAt"'),
        assert(length != null && length > 0, 'length is "$length"');

  FetchScheme.of(int startAt, int endAt) : this(startAt, endAt - startAt);

  /// it check if [other] scheme is in [this] scheme
  bool contains(FetchScheme other) => startAt <= other.startAt && endAt >= other.endAt;

  /// it check if [other] offset is in [this] scheme
  bool containsOffset(int other) => startAt <= other && endAt > other;

  FetchScheme copyWith({int startAt, int length}) {
    return FetchScheme(startAt ?? this.startAt, length ?? this.length);
  }

  FetchScheme mergeWith({int startAt, int endAt}) {
    startAt ??= this.startAt;
    endAt ??= this.endAt;

    assert(startAt < endAt, 'Not possible apply "$startAt, $endAt" to "$this"');

    return FetchScheme.of(startAt, endAt);
  }

  FetchScheme applyEnd(int offset) {
    assert(offset != null && offset < endAt, 'Not possible apply "$offset" to "$this"');
    return FetchScheme(offset, endAt - offset);
  }

  FetchScheme find(FetchScheme other) {
    if (!containsOffset(other.startAt)) return null;
    return FetchScheme(other.startAt, min(length, other.length));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchScheme &&
          runtimeType == other.runtimeType &&
          startAt == other.startAt &&
          length == other.length;

  @override
  int get hashCode => startAt.hashCode ^ length.hashCode;

  @override
  String toString() => 'Scheme(offset: $startAt, length: $length)';
}
