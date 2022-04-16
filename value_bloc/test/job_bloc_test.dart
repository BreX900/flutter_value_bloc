import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:value_bloc/src/job_bloc.dart';

class _TestableJobBloc extends JobBloc<bool, String> {
  final _Worker<bool, String> _worker;

  _TestableJobBloc(this._worker);

  @override
  FutureOr<String> onWorking(bool data) => _worker(data);
}

void main() {
  late _Worker<bool, String> mockWorker;

  late JobBloc<bool, String> bloc;
  late Job<String> state;

  setUp(() {
    mockWorker = MockWorker();

    bloc = _TestableJobBloc(mockWorker);
    state = bloc.state;
  });

  group('JobBloc', () {
    final tData = true;
    final tError = 'ERROR';
    final tStackTrace = StackTrace.empty;
    final tResult = 'RESULT';

    group('constructor', () {
      test('initial state', () {
        final expectedState = IdleJob<String>();
        expect(state, expectedState);
      });
    });

    group('work', () {
      test('emits and return result', () async {
        when(() => mockWorker(any())).thenAnswer((_) async => tResult);

        final expectedStates = [
          state = state.toLoading(),
          state = state.toSuccess(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.work(tData), completion(tResult)),
        ]);
      });

      test('emits and throw error', () async {
        when(() => mockWorker(any())).thenAnswer((_) async {
          return Future.error(tError, tStackTrace);
        });

        act() => bloc.work(tData);

        final expectedStates = [
          state = state.toLoading(),
          state = state.toError(tError, tStackTrace),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(act, throwsA(isA<String>())),
        ]);
      });

      test('throw an error if you start working while you are already working', () async {
        bloc.emit(state = state.toLoading());

        await expectLater(() => bloc.work(tData), throwsA(isA<AlreadyWorkingError>()));
      });
    });
  });
}

abstract class _Worker<A, R> {
  Future<R> call(A arg);
}

class MockWorker extends Mock implements _Worker<bool, String> {}

void after(FutureOr<void> Function() body) async {
  await Future.delayed(const Duration());
  await body();
}
