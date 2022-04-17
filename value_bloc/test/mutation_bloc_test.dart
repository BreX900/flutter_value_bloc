import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:value_bloc/src/mutation_bloc.dart';

class _TestableBloc extends MutationBloc<bool, String> {
  final _Mutator<bool, String> _mutator;

  _TestableBloc(this._mutator);

  @override
  FutureOr<String> onMutating(bool data) => _mutator(data);
}

void main() {
  late _Mutator<bool, String> mockWorker;

  late MutationBloc<bool, String> bloc;
  late MutationState<String> state;

  setUp(() {
    mockWorker = MockMutator();

    bloc = _TestableBloc(mockWorker);
    state = bloc.state;
  });

  group('MutationBloc', () {
    final tData = true;
    final tError = 'ERROR';
    final tStackTrace = StackTrace.empty;
    final tResult = 'RESULT';

    group('constructor', () {
      test('initial state', () {
        final expectedState = IdleMutation<String>();
        expect(state, expectedState);
      });
    });

    group('mutate', () {
      test('emits and return result', () async {
        when(() => mockWorker(any())).thenAnswer((_) async => tResult);

        final expectedStates = [
          state = state.toLoading(),
          state = state.toSuccess(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.mutate(tData), completion(tResult)),
        ]);
      });

      test('emits and throw error', () async {
        when(() => mockWorker(any())).thenAnswer((_) async {
          return Future.error(tError, tStackTrace);
        });

        act() => bloc.mutate(tData);

        final expectedStates = [
          state = state.toLoading(),
          state = state.toError(tError, tStackTrace),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(act, throwsA(isA<String>())),
        ]);
      });

      test('throw an error if you start mutation while you are already mutating', () async {
        bloc.emit(state = state.toLoading());

        await expectLater(() => bloc.mutate(tData), throwsA(isA<AlreadyMutatingError>()));
      });
    });
  });
}

abstract class _Mutator<A, R> {
  Future<R> call(A arg);
}

class MockMutator extends Mock implements _Mutator<bool, String> {}
