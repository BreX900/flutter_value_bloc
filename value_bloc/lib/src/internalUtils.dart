import 'dart:math';

import 'package:value_bloc/src/utils.dart';

// class FetchEmptyEvent<V> implements FetchEvent<V> {
//   FetchEmptyEvent();
// }

class FetchFailedEvent<V> implements FetchEvent<V> {
  final Object failure;

  FetchFailedEvent({this.failure});
}

class FetchedEvent<V> implements FetchEvent<V> {
  final V value;
  final int total;

  FetchedEvent(this.value, {this.total});

  bool get hasValue => total != null ? total != 0 : value != null;
}

/// It represent a request for retrieving a values determined by [startAt] and [length]
class ListSection {
  /// it is a first position
  final int startAt;

  /// it is a positions count
  final int length;

  /// it is a position after last position
  int get endAt => startAt + length;

  ListSection(this.startAt, this.length)
      : assert(startAt != null, 'startAt is "$startAt"'),
        assert(length != null && length > 0, 'length is "$length"');

  ListSection.of(int startAt, int endAt) : this(startAt, endAt - startAt);

  /// it check if [other] scheme is in [this] scheme
  bool contains(ListSection other) => startAt <= other.startAt && endAt >= other.endAt;

  /// it check if [other] offset is in [this] scheme
  bool containsOffset(int other) => startAt <= other && endAt > other;

  ListSection copyWith({int startAt, int length}) {
    return ListSection(startAt ?? this.startAt, length ?? this.length);
  }

  ListSection mergeWith({int startAt, int endAt}) {
    startAt ??= this.startAt;
    endAt ??= this.endAt;

    assert(startAt < endAt, 'Not possible apply "$startAt, $endAt" to "$this"');

    return ListSection.of(startAt, endAt);
  }

  ListSection applyEnd(int offset) {
    assert(offset != null && offset < endAt, 'Not possible apply "$offset" to "$this"');
    return ListSection(offset, endAt - offset);
  }

  ListSection find(ListSection other) {
    if (!containsOffset(other.startAt)) return null;
    return ListSection(other.startAt, min(length, other.length));
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ListSection &&
          runtimeType == other.runtimeType &&
          startAt == other.startAt &&
          length == other.length;

  @override
  int get hashCode => startAt.hashCode ^ length.hashCode;

  @override
  String toString() => 'Scheme(offset: $startAt, length: $length)';
}
