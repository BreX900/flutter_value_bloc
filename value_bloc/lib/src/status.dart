enum LoadStatus {
  /// The bloc required load before fetching
  idle,

  /// The bloc is performing the loading
  loading,

  /// The bloc is already loaded
  loaded,

  /// The bloc have a load error
  crashed,
}
enum FetchStatus { idle, fetching, fetched, crashed }

extension LoadStatusExtension on LoadStatus {
  bool get isIdle => this == LoadStatus.idle;
  bool get isLoading => this == LoadStatus.loading;
  bool get isLoaded => this == LoadStatus.loaded;
}

extension FetchStatusExtension on FetchStatus {
  bool get isIdle => this == FetchStatus.idle;
  bool get isFetching => this == FetchStatus.fetching;
  bool get isFetched => this == FetchStatus.fetched;
}

// extension ListBuilderExt<T> on ListBuilder<T> {
//   /// this: [1, 2, 3, 4, 5], start: 3, values = [6, 7, 8, 9]
//   /// [1, 2, 3, 6, 7, 8, 9]
//   void push(int at, Iterable<T> values) {
//     final end = at + values.length;
//     final iterator = values.iterator;
//
//     replace(List<T>.generate(max(length, end), (index) {
//       if (index >= at && index < end) {
//         iterator.moveNext();
//         return iterator.current;
//       } else if (index < length) {
//         return this[index];
//       } else {
//         return null;
//       }
//     }));
//
//     // final newLength = start + values.length;
//     // final newValuesCount = newLength - length;
//     // if (newValuesCount > 0) {
//     //   addAll(values.skip(values.length - newValuesCount));
//     // }
//     // final oldValuesCount = length - start;
//     // if (oldValuesCount > 0) {
//     //   setRange(start, start + oldValuesCount, values);
//     // }
//   }
//
//   void pushRange(int at, Iterable<T> values, int start, [int end]) {
//     if (start > 0) values = values.skip(start);
//     if (end != null) values = values.take(end);
//     push(at, values);
//   }
// }
//
// class PushedIterable<T> extends Iterable<T> {
//   final List<T> values;
//   final int at;
//   final Iterable<T> newValues;
//
//   PushedIterable(this.values, this.at, this.newValues);
//
//   @override
//   Iterator<T> get iterator {
//     final end = at + newValues.length;
//     return PushedIterator(
//         values, at, end, newValues.iterator, max(values.length, end));
//   }
// }
//
// class PushedIterator<T> implements Iterator<T> {
//   final List<T> values;
//   final int at;
//   final int end;
//   final Iterator<T> iterator;
//   final int length;
//
//   PushedIterator(this.values, this.at, this.end, this.iterator, this.length);
//
//   var _index = 0;
//
//   @override
//   bool moveNext() {
//     if (_index >= at && _index < end) {
//       iterator.moveNext();
//       _current = iterator.current;
//     } else if (_index < values.length) {
//       _current = values[_index];
//     } else {
//       _current = null;
//     }
//     _index++;
//     return _index <= length;
//   }
//
//   T _current;
//
//   @override
//   T get current => _current;
// }
