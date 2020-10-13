import 'dart:math';

import 'package:built_collection/built_collection.dart';
import 'package:value_bloc/value_bloc.dart';

/// This class permit a custom fetching for [ListValueCubit]
abstract class ValueFetcher {
  const ValueFetcher();

  int getInitialOffset(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
    for (var i = 0; true; i++) {
      final existOffset = values.keys.any((s) => s.containsOffset(i));
      if (!existOffset) return i;
    }
  }

  int getInitialLimit(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme);

  FetchScheme initFetchScheme(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
    if (scheme.offset == null)
      scheme = scheme.copyWith(offset: getInitialOffset(values, scheme));
    if (scheme.limit == null)
      scheme = scheme.copyWith(limit: getInitialLimit(values, scheme));
    return scheme;
  }

  /// Find a more [FetchScheme] for elaboration a user [ListValueCubit.onFetching]
  List<FetchScheme> findSchemes(
      BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
    return onFindSchemes(values, initFetchScheme(values, scheme));
  }

  List<FetchScheme> onFindSchemes(
      BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme);
}

/// This class perform a fetch ignoring different limit pagination
/// You can use this class in [ListValueCubit]
/// when you are interested in using paging queries with different limit
class ListFetcher extends ValueFetcher {
  final int minLimit;

  ListFetcher({this.minLimit = 20});

  int getInitialLimit(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) =>
      minLimit;

  List<FetchScheme> onFindSchemes(
      BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
    int offset;
    final schemes = <FetchScheme>[];
    for (var i = scheme.offset; i < scheme.end; i++) {
      final existOffset = values.keys.any((s) => s.containsOffset(i));
      if (!existOffset && offset == null) {
        offset = i;
      }
      if (existOffset && offset != null) {
        schemes.add(FetchScheme(offset, i - offset));
      }
    }
    if (offset != null)
      schemes.add(FetchScheme(offset, max(scheme.end - offset, minLimit)));
    return schemes;
  }
}

/// This class perform fetch with standard limit pagination
/// You can use this class in [ListValueCubit]
/// when you are interested in using paging queries with same limit
class PageFetcher extends ValueFetcher {
  static var defaultValuePerPage = 20;

  final int valuesPerPage;

  PageFetcher({
    int valuesPerPage,
  }) : this.valuesPerPage = valuesPerPage ?? defaultValuePerPage;

  int getInitialLimit(BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) =>
      valuesPerPage;

  List<FetchScheme> onFindSchemes(
      BuiltMap<FetchScheme, dynamic> values, FetchScheme scheme) {
    // Generate a scheme based on page
    final start = (scheme.offset / valuesPerPage).floor();
    final end = (scheme.end / valuesPerPage).ceil();
    final schemes = List.generate(end - start, (index) {
      return FetchScheme(index * valuesPerPage, valuesPerPage);
    });
    // Remove already exist scheme in state
    return schemes..removeWhere(values.containsKey);
  }
}

class FetchScheme {
  final int offset;
  final int limit;
  int get end => offset + limit;

  FetchScheme(this.offset, this.limit);

  bool contains(FetchScheme other) => offset <= other.offset && end >= other.end;
  bool containsOffset(int other) => offset <= other && end > other;

  FetchScheme copyWith({int offset, int limit}) {
    return FetchScheme(offset ?? this.offset, limit ?? this.limit);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FetchScheme &&
          runtimeType == other.runtimeType &&
          offset == other.offset &&
          limit == other.limit;

  @override
  int get hashCode => offset.hashCode ^ limit.hashCode;

  @override
  String toString() => 'Scheme(offset: $offset, limit: $limit)';
}