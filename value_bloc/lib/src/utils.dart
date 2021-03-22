import 'dart:math';

abstract class SingleFetchEvent<V> {
  factory SingleFetchEvent.failed({Object failure}) = FailedFetchEvent<V>;

  factory SingleFetchEvent.empty() = EmptyFetchEvent<V>;

  factory SingleFetchEvent.fetched(V value) = ObjectFetchedEvent<V>;
}

abstract class MultiFetchEvent<V> {
  factory MultiFetchEvent.failed({Object failure}) = FailedFetchEvent<V>;

  factory MultiFetchEvent.empty() = EmptyFetchEvent<V>;

  factory MultiFetchEvent.fetched(V value, {int total}) = IterableFetchedEvent<V>;
}

class FailedFetchEvent<V> implements SingleFetchEvent<V>, MultiFetchEvent<V> {
  final Object failure;

  FailedFetchEvent({this.failure});
}

class EmptyFetchEvent<V> implements SingleFetchEvent<V>, MultiFetchEvent<V> {
  EmptyFetchEvent();
}

class ObjectFetchedEvent<V> implements SingleFetchEvent<V> {
  final V value;

  ObjectFetchedEvent(this.value);
}

class IterableFetchedEvent<V> implements MultiFetchEvent<V> {
  final V values;
  final int total;

  IterableFetchedEvent(this.values, {this.total});
}

/// It represent a request for retrieving a values determined by [startAt] and [length]
class IterableSection {
  /// it is a first position
  final int startAt;

  /// it is a positions count
  final int length;

  /// it is a position after last position
  /// Todo: Fix it with match with last position
  int get endAt => startAt + length;

  IterableSection(this.startAt, this.length)
      : assert(startAt != null, 'startAt is "$startAt"'),
        assert(length != null && length > 0, 'length is "$length"');

  IterableSection.of(int startAt, int endAt) : this(startAt, endAt - startAt);

  IterableSection.from(int sectionsCount, int length) : this(sectionsCount * length, length);

  IterableSection.fromPagination(int offset, int length) : this((offset / length).floor(), length);

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

  IterableSection moveOf(int length) => copyWith(startAt: startAt + length);

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
