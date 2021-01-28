// import 'dart:math';
//
// import 'package:built_collection/built_collection.dart';
//
// /// This class permit a custom fetching for [ListValueCubit]
// abstract class ValueFetcher {
//   const ValueFetcher();
//
//   int getInitialOffset(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
//     for (var i = 0; true; i++) {
//       final existOffset = values.keys.any((s) => s.containsOffset(i));
//       if (!existOffset) return i;
//     }
//   }
//
//   int getInitialLimit(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme);
//
//   FetchScheme initFetchScheme(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
//     if (scheme.offset == null) scheme = scheme.copyWith(offset: getInitialOffset(values, scheme));
//     if (scheme.limit == null) scheme = scheme.copyWith(limit: getInitialLimit(values, scheme));
//     return scheme;
//   }
//
//   /// Find a more [FetchScheme] for elaboration a user [ListValueCubit.onFetching]
//   List<FetchScheme> findSchemes(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
//     return onFindSchemes(values, initFetchScheme(values, scheme));
//   }
//
//   List<FetchScheme> onFindSchemes(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme);
// }
//
// /// This class perform a fetch ignoring different limit pagination
// /// You can use this class in [ListValueCubit]
// /// when you are interested in using paging queries with different limit
// class ListFetcher extends ValueFetcher {
//   final int minLimit;
//
//   ListFetcher({this.minLimit = 20});
//
//   @override
//   int getInitialLimit(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) => minLimit;
//
//   @override
//   List<FetchScheme> onFindSchemes(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
//     int offset;
//     final schemes = <FetchScheme>[];
//     for (var i = scheme.offset; i < scheme.end; i++) {
//       final existOffset = values.keys.any((s) => s.containsOffset(i));
//       if (!existOffset && offset == null) {
//         offset = i;
//       }
//       if (existOffset && offset != null) {
//         schemes.add(FetchScheme(offset, i - offset));
//       }
//     }
//     if (offset != null) schemes.add(FetchScheme(offset, max(scheme.end - offset, minLimit)));
//     return schemes;
//   }
// }
//
// /// This class perform fetch with standard limit pagination
// /// You can use this class in [ListValueCubit]
// /// when you are interested in using paging queries with same limit
// class PageFetcher extends ValueFetcher {
//   static var defaultValuePerPage = 20;
//
//   final int valuesPerPage;
//
//   PageFetcher({
//     int valuesPerPage,
//   }) : valuesPerPage = valuesPerPage ?? defaultValuePerPage;
//
//   @override
//   int getInitialLimit(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) => valuesPerPage;
//
//   @override
//   List<FetchScheme> onFindSchemes(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
//     // Generate a scheme based on page
//     final start = (scheme.offset / valuesPerPage).floor();
//     final end = (scheme.end / valuesPerPage).ceil();
//     final schemes = List.generate(end - start, (index) {
//       return FetchScheme((start * valuesPerPage) + (index * valuesPerPage), valuesPerPage);
//     });
//     // Remove already exist scheme in state
//     return schemes..removeWhere(values.containsKey);
//   }
// }
//
// /// It represent a request for retrieving a values determined by [offset] and [limit]
// class FetchScheme {
//   /// it is a start fetching position
//   final int offset;
//
//   /// it is a max number of values fetching
//   final int limit;
//
//   /// it is a end fetching position
//   int get end => offset + limit;
//
//   FetchScheme(this.offset, this.limit);
//
//   /// it check if [other] scheme is in [this] scheme
//   bool contains(FetchScheme other) => offset <= other.offset && end >= other.end;
//
//   /// it check if [other] offset is in [this] scheme
//   bool containsOffset(int other) => offset <= other && end > other;
//
//   FetchScheme copyWith({int offset, int limit}) {
//     return FetchScheme(offset ?? this.offset, limit ?? this.limit);
//   }
//
//   @override
//   bool operator ==(Object other) =>
//       identical(this, other) ||
//       other is FetchScheme &&
//           runtimeType == other.runtimeType &&
//           offset == other.offset &&
//           limit == other.limit;
//
//   @override
//   int get hashCode => offset.hashCode ^ limit.hashCode;
//
//   @override
//   String toString() => 'Scheme(offset: $offset, limit: $limit)';
// }

import 'package:built_collection/built_collection.dart';
import 'package:value_bloc/src/internalUtils.dart';

abstract class ListFetcherPlugin {
  const ListFetcherPlugin();

  BuiltSet<IterableSection> update(BuiltSet<IterableSection> schemes, IterableSection newScheme);
}

/// Merge the new scheme in queue without reply the offset
/// It ignore scheme and offset if it already exist in queue
class SimpleListFetcherPlugin extends ListFetcherPlugin {
  const SimpleListFetcherPlugin();

  /// find in queue the first scheme contains the offset
  IterableSection findContainer(BuiltSet<IterableSection> queue, int offset) {
    return queue.firstWhere((s) => s.containsOffset(offset), orElse: () => null);
  }

  /// find in the queue for the first possible not-existent scheme offset
  ///
  /// Returns null if the offset exist
  int findFirstNotExistOffset(BuiltSet<IterableSection> queue, IterableSection scheme) {
    for (var i = scheme.startAt; i < scheme.endAt; i++) {
      final container = findContainer(queue, i);
      if (container == null) return i;
    }
    return null;
  }

  /// find in the queue for the first possible existent scheme offset
  ///
  /// Returns null if the offset not exist
  int findFirstExistOffset(BuiltSet<IterableSection> queue, IterableSection scheme) {
    for (var i = scheme.startAt; i < scheme.endAt; i++) {
      final container = findContainer(queue, i);
      if (container != null) return i;
    }
    return null;
  }

  @override
  BuiltSet<IterableSection> update(BuiltSet<IterableSection> queue, IterableSection scheme) {
    do {
      final newStartAt = findFirstNotExistOffset(queue, scheme);
      if (newStartAt == null) return queue;
      final startScheme = scheme.mergeWith(startAt: newStartAt);
      final newEndAt = findFirstExistOffset(queue, startScheme);
      final newScheme = newEndAt == null ? startScheme : startScheme.mergeWith(endAt: newEndAt);

      queue = queue.rebuild((b) => b.add(newScheme));
      scheme = newScheme.endAt >= scheme.endAt ? null : scheme.mergeWith(startAt: newScheme.endAt);
    } while (scheme != null);

    return queue;
  }
}
