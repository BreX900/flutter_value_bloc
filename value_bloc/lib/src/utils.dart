import 'dart:math';

abstract class SingleFetchEvent<V> {
  factory SingleFetchEvent.failed({Object? failure}) = FailedFetchEvent<V>;

  factory SingleFetchEvent.empty() = EmptyFetchEvent<V>;

  factory SingleFetchEvent.fetched(V value) = ObjectFetchedEvent<V>;
}

abstract class MultiFetchEvent<V> {
  factory MultiFetchEvent.failed({Object? failure}) = FailedFetchEvent<V>;

  factory MultiFetchEvent.empty() = EmptyFetchEvent<V>;

  factory MultiFetchEvent.fetched(V value, {int? total}) = IterableFetchedEvent<V>;
}

class FailedFetchEvent<V> implements SingleFetchEvent<V>, MultiFetchEvent<V> {
  final Object? failure;

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
  final int? total;

  IterableFetchedEvent(this.values, {this.total});
}

/// It represent a request for retrieving a values determined by [startAt] and [length]
class PageOffset {
  /// it is a first position
  final int startAt;

  /// it is a positions count
  final int length;

  /// it is a position after last position
  /// Todo: Fix it with match with last position
  int get endAt => startAt + length;

  PageOffset(this.startAt, this.length) : assert(length > 0, 'length is "$length"');

  PageOffset.of(int startAt, int endAt) : this(startAt, endAt - startAt);

  PageOffset.from(int sectionsCount, int length) : this(sectionsCount * length, length);

  PageOffset.fromPagination(int offset, int length) : this((offset / length).floor(), length);

  /// it check if [other] scheme is in [this] scheme
  bool contains(PageOffset other) => startAt <= other.startAt && endAt >= other.endAt;

  /// it check if [other] offset is in [this] scheme
  bool containsOffset(int other) => startAt <= other && endAt > other;

  PageOffset copyWith({int? startAt, int? length}) {
    return PageOffset(startAt ?? this.startAt, length ?? this.length);
  }

  PageOffset mergeWith({int? startAt, int? endAt}) {
    startAt ??= this.startAt;
    endAt ??= this.endAt;

    assert(startAt < endAt, 'Not possible apply "$startAt, $endAt" to "$this"');

    return PageOffset.of(startAt, endAt);
  }

  PageOffset applyEnd(int offset) {
    assert(offset < endAt, 'Not possible apply "$offset" to "$this"');
    return PageOffset(offset, endAt - offset);
  }

  PageOffset? find(PageOffset other) {
    if (!containsOffset(other.startAt)) return null;
    return PageOffset(other.startAt, min(length, other.length));
  }

  PageOffset restart() => copyWith(startAt: 0);

  PageOffset move(int length) => copyWith(startAt: startAt + length);

  PageOffset next() => copyWith(startAt: startAt + length);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PageOffset &&
          runtimeType == other.runtimeType &&
          startAt == other.startAt &&
          length == other.length;

  @override
  int get hashCode => startAt.hashCode ^ length.hashCode;

  @override
  String toString() => 'Scheme(offset: $startAt, length: $length)';
}
