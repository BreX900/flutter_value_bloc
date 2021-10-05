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

EventTransformer<TEvent> assign<TEvent>(ConcurrencyType Function(TEvent event) concurrency) {
  return (events, mapper) {
    return Stream<TEvent>.multi((controller) {
      bool canAdd = true;
      late StreamSubscription sub;
      StreamSubscription? restartableSub;
      sub = events.listen((event) async {
        restartableSub?.cancel();
        switch (concurrency(event)) {
          case ConcurrencyType.concurrent:
            // TODO: Handle this case.
            break;
          case ConcurrencyType.restartable:
            if (canAdd) {
              restartableSub =
                  mapper(event).listen(controller.addSync, onError: controller.addErrorSync);
            }
            break;
          case ConcurrencyType.sequential:
            canAdd = false;
            sub.pause();
            await controller.addStream(mapper(event));
            canAdd = true;
            sub.resume();
            break;
        }
      }, onError: controller.addErrorSync, onDone: controller.closeSync);

      controller
        // ignore: void_checks
        ..onCancel = () {
          final f1 = restartableSub?.cancel();
          final f2 = sub.cancel();
          return Future.wait<void>([if (f1 != null) f1, f2]);
        }
        ..onPause = sub.pause
        ..onResume = sub.resume;
    });
  };
}
