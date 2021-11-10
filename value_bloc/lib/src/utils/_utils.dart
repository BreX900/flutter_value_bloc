import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:collection/collection.dart';
import 'package:rxdart/rxdart.dart';

enum ConcurrencyType { concurrent, restartable, sequential }

class Mark<TEvent> {
  final bool isActive;
  final TEvent value;

  Mark(this.isActive, this.value);
}

EventTransformer<ExEvent> assign2<ExEvent, Event extends ExEvent>(
  ConcurrencyType Function(Event event) concurrency,
) {
  return (_events, mapper) {
    final events = _events.cast<Event>();

    final subs = CompositeSubscription();
    final restartableController = StreamController<Event?>(sync: true);
    // final concurrentController = StreamController<Event?>(sync: true);
    final sequentialController = StreamController<Mark<ExEvent>>(sync: true);
    final resultController = StreamController<ExEvent>(sync: true);

    resultController.onListen = () {
      events.listen((event) {
        switch (concurrency(event)) {
          case ConcurrencyType.concurrent:
            // TODO: Handle this case.
            break;
          case ConcurrencyType.restartable:
            restartableController.add(event);
            break;
          case ConcurrencyType.sequential:
            restartableController.add(null);
            sequentialController.add(Mark(true, event));
            break;
        }
      }, onError: resultController.addError).addTo(subs);

      restartableController.stream
          .switchMap<ExEvent>((event) {
            if (event == null) return Stream.empty();
            return mapper(event);
          })
          .listen((event) => sequentialController.add(Mark(false, event)))
          .addTo(subs);

      sequentialController.stream
          .asyncExpand<ExEvent>((markedEvent) {
            if (markedEvent.isActive) {
              return mapper(markedEvent.value);
            } else {
              return Stream.value(markedEvent.value);
            }
          })
          .listen(resultController.add)
          .addTo(subs);

      resultController.onCancel = () {
        subs.dispose();
        restartableController.close();
        sequentialController.close();
      };
    };

    return resultController.stream;
  };
}

EventTransformer<TEvent> assign<TEvent>(
  ConcurrencyType Function(TEvent event) concurrency,
) {
  return (_events, mapper) {
    final events = _events.cast<TEvent>();

    return events.switchMap<Mark<TEvent>>((event) {
      switch (concurrency(event)) {
        case ConcurrencyType.concurrent:
          // TODO: Handle this case.
          return Stream.empty();
        case ConcurrencyType.restartable:
          return mapper(event).map((event) => Mark(false, event));
        case ConcurrencyType.sequential:
          return Stream.value(Mark(true, event));
      }
    }).asyncExpand((event) {
      if (event.isActive) {
        return mapper(event.value);
      } else {
        return Stream.value(event.value);
      }
    });
  };
}

class StateToString {
  static int _indentingIndent = 0;
  StringBuffer? _buffer = StringBuffer();

  StateToString(String className) {
    _buffer!
      ..write(className)
      ..write(' {\n');
    _indentingIndent += 2;
  }

  void add(String field, Object? value) {
    if (value != null) addNull(field, value);
  }

  void addNull(String field, Object? value) {
    _buffer!
      ..write(' ' * _indentingIndent)
      ..write(field)
      ..write('=')
      ..write(value)
      ..write(',\n');
  }

  StateToString? check(bool condition) => condition ? this : null;

  @override
  String toString() {
    _indentingIndent -= 2;
    _buffer!
      ..write(' ' * _indentingIndent)
      ..write('}');
    var stringResult = _buffer.toString();
    _buffer = null;
    return stringResult;
  }
}

typedef Equals<T> = bool Function(T a, T b);

class SimpleEquality<T> implements Equality<T> {
  final Equals<T> _equals;

  SimpleEquality(Equals<T> equals) : _equals = equals;

  @override
  bool equals(T e1, T e2) => _equals(e1, e2);

  @override
  int hash(T e) => e.hashCode;

  @override
  bool isValidKey(Object? o) => true;
}

extension EqualityExtension<T> on Equality<T> {
  T replace(T current, T next) => equals(current, next) ? next : current;

  Iterable<T> addAllIfAbsent(List<T> current, List<T> next) {
    return [...current, ...whereNotContainsAll(next, current)];
  }

  Iterable<T> updateAll(List<T> current, List<T> next) {
    return current.map((cvl) => next.firstWhere((nvl) => equals(cvl, nvl), orElse: () => cvl));
  }

  Iterable<T> replaceAll(List<T> current, Map<T, T> next) {
    return current.map((cvl) => next.containsKey(cvl) ? next[cvl] as T : cvl);
  }

  Iterable<T> whereNotContainsAll(List<T> current, List<T> bad) {
    return current.where((cvl) => !bad.any((bvl) => equals(cvl, bvl)));
  }

  bool contains(List<T> values, T value) {
    for (final vl in values) {
      final hasHit = equals(value, vl);
      if (hasHit) return true;
    }
    return false;
  }
}

class Param<T> {
  final T value;

  const Param(this.value);

  // ignore: prefer_void_to_null
  static const Param<Null> none = Param(null);
}

extension IterableExtension<T> on Iterable<T> {
  Iterable<T> whereNot(bool Function(T e) test) => where((e) => !test(e));
}
