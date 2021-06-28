// import 'dart:async';
//
// import 'package:value_bloc/src_3/list_event.dart';
// import 'package:value_bloc/value_bloc.dart';
//
// class BlocsManagerEvent<TFailure, TValue> {
//   final Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc;
//   final DataBlocAction<TFailure, TValue> event;
//
//   BlocsManagerEvent(this.bloc, this.event);
// }
//
// abstract class BlocsManager<TFailure, TValue> {
//   final _subject = StreamController<BlocsManagerEvent<TFailure, TValue>>.broadcast();
//
//   BlocsManager() {
//     _subject.stream.asyncMap((event) => mapEvent(event.bloc, event.event)).listen((_) {});
//   }
//
//   void add(
//     Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc,
//     DataBlocAction<TFailure, TValue> event,
//   ) {
//     _subject.add(BlocsManagerEvent(bloc, event));
//   }
//
//   final _blocs = <Bloc<DataBlocEvent<TFailure, TValue>, dynamic>>[];
//
//   void addBloc(Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc) => _blocs.add(bloc);
//
//   void removeBloc(Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc) => _blocs.remove(bloc);
//
//   void emit(Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc,
//           DataBlocEmission<TFailure, TValue> event) =>
//       _blocs.forEach((bloc) => bloc.add(ExternalDataBlocEmission(bloc, event)));
//
//   Future<void> mapEvent(
//     Bloc<DataBlocEvent<TFailure, TValue>, dynamic> bloc,
//     DataBlocAction<TFailure, TValue> event,
//   ) async {
//     await for (final event in mapBlocsEvent(event)) {
//       emit(bloc, event);
//     }
//   }
//
//   Stream<DataBlocEmission<TFailure, TValue>> mapBlocsEvent(
//       DataBlocAction<TFailure, TValue> event) async* {
//     yield event.toEmitting();
//     yield* onMapBlocsEvent(event);
//   }
//
//   Stream<DataBlocEmission<TFailure, TValue>> onMapBlocsEvent(
//       DataBlocAction<TFailure, TValue> event);
// }
