import 'dart:async';

import 'package:bloc/bloc.dart';
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
