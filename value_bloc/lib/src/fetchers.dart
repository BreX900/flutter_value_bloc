import 'package:built_collection/built_collection.dart';
import 'package:collection/collection.dart' show IterableExtension;
import 'package:meta/meta.dart';
import 'package:value_bloc/src/utils.dart';

/// You can override how the [MultiCubit] handles the sections to be requested
///
/// You can use:
/// - [ContinuousListFetcherPlugin] Requires section only once per filter
/// - [SpasmodicListFetcherPlugin] Request the section every time the current section changes
@immutable
abstract class ListFetcherPlugin {
  const ListFetcherPlugin();

  BuiltSet<PageOffset> addTo(BuiltSet<PageOffset> queue, PageOffset newSection);
}

/// It caches all the sections that have been requested by the UI
/// The fetcher will be called only once per section
class ContinuousListFetcherPlugin extends ListFetcherPlugin {
  const ContinuousListFetcherPlugin();

  /// find in queue the first scheme contains the offset
  PageOffset? findContainer(BuiltSet<PageOffset> queue, int offset) {
    return queue.firstWhereOrNull((s) => s.containsOffset(offset));
  }

  /// find in the queue for the first possible not-existent scheme offset
  ///
  /// Returns null if the offset exist
  int? findFirstNotExistOffset(BuiltSet<PageOffset> queue, PageOffset scheme) {
    for (var i = scheme.startAt; i < scheme.endAt; i++) {
      final container = findContainer(queue, i);
      if (container == null) return i;
    }
    return null;
  }

  /// find in the queue for the first possible existent scheme offset
  ///
  /// Returns null if the offset not exist
  int? findFirstExistOffset(BuiltSet<PageOffset> queue, PageOffset scheme) {
    for (var i = scheme.startAt; i < scheme.endAt; i++) {
      final container = findContainer(queue, i);
      if (container != null) return i;
    }
    return null;
  }

  @override
  BuiltSet<PageOffset> addTo(BuiltSet<PageOffset> queue, PageOffset scheme) {
    PageOffset? tmpScheme = scheme;
    do {
      final newStartAt = findFirstNotExistOffset(queue, scheme);
      if (newStartAt == null) return queue;
      final startScheme = scheme.mergeWith(startAt: newStartAt);
      final newEndAt = findFirstExistOffset(queue, startScheme);
      final newScheme = newEndAt == null ? startScheme : startScheme.mergeWith(endAt: newEndAt);

      queue = queue.rebuild((b) => b.add(newScheme));
      tmpScheme =
          newScheme.endAt >= scheme.endAt ? null : scheme.mergeWith(startAt: newScheme.endAt);
    } while (tmpScheme != null);

    return queue;
  }
}

/// It only caches the last section that the UI requested
/// The fetcher will be called for each new section (different from the previous one)
class SpasmodicListFetcherPlugin extends ListFetcherPlugin {
  const SpasmodicListFetcherPlugin();

  @override
  BuiltSet<PageOffset> addTo(BuiltSet<PageOffset> queue, PageOffset newScheme) {
    return BuiltSet.of([newScheme]);
  }
}

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
