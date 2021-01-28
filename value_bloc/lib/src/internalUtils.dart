import 'dart:math';

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

/// It represent a request for retrieving a values determined by [startAt] and [length]
class IterableSection {
  /// it is a first position
  final int startAt;

  /// it is a positions count
  final int length;

  /// it is a position after last position
  int get endAt => startAt + length;

  IterableSection(this.startAt, this.length)
      : assert(startAt != null, 'startAt is "$startAt"'),
        assert(length != null && length > 0, 'length is "$length"');

  IterableSection.of(int startAt, int endAt) : this(startAt, endAt - startAt);

  /// it check if [other] scheme is in [this] scheme
  bool contains(IterableSection other) => startAt <= other.startAt && endAt >= other.endAt;

  /// it check if [other] offset is in [this] scheme
  bool containsOffset(int other) => startAt <= other && endAt > other;

  IterableSection copyWith({int startAt, int length}) {
    return IterableSection(startAt ?? this.startAt, length ?? this.length);
  }

  IterableSection mergeWith({int startAt, int endAt}) {
    startAt ??= this.startAt;
    endAt ??= this.endAt;

    assert(startAt < endAt, 'Not possible apply "$startAt, $endAt" to "$this"');

    return IterableSection.of(startAt, endAt);
  }

  IterableSection applyEnd(int offset) {
    assert(offset != null && offset < endAt, 'Not possible apply "$offset" to "$this"');
    return IterableSection(offset, endAt - offset);
  }

  IterableSection find(IterableSection other) {
    if (!containsOffset(other.startAt)) return null;
    return IterableSection(other.startAt, min(length, other.length));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IterableSection &&
          runtimeType == other.runtimeType &&
          startAt == other.startAt &&
          length == other.length;

  @override
  int get hashCode => startAt.hashCode ^ length.hashCode;

  @override
  String toString() => 'Scheme(offset: $startAt, length: $length)';
}
