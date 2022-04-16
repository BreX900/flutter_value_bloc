import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:value_bloc/src/fetch_bloc.dart';

class FakeError {}

class TestableBloc extends DataBloc<String> {
  final Future<String> Function() _fetcher;

  TestableBloc(this._fetcher);

  @override
  Future<String> onFetching() async => await _fetcher();
}

void main() {
  late _Fetcher<String> mockFetcher;

  setUp(() {
    mockFetcher = _MockFetcher();
  });

  group('FetchBloc', () {
    final tError = FakeError();
    final tStackTrace = StackTrace.empty;
    final tResult = 'RESULT';

    group('init', () {
      test('Success initializing', () async {
        when(() => mockFetcher()).thenAnswer((_) async => tResult);

        final bloc = TestableBloc(mockFetcher);
        var state = bloc.state;

        final expectedState = LoadingData<String>();
        expect(bloc.state, expectedState);

        final expectedStates = [
          state = state.toSuccess(tResult),
        ];
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
      });

      test('Failed initializing', () async {
        when(() => mockFetcher()).thenAnswer((_) async {
          throw Error.throwWithStackTrace(tError, tStackTrace);
        });

        final bloc = TestableBloc(mockFetcher);
        var state = bloc.state;

        final expectedState = LoadingData<String>();
        expect(bloc.state, expectedState);

        final expectedStates = [
          state = state.toError(tError, tStackTrace),
        ];
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
      });
    });

    group('fetch', () {
      late DataBloc<String> bloc;
      late DataState<String> state;

      setUp(() async {
        when(() => mockFetcher()).thenAnswer((_) async => '');
        bloc = TestableBloc(mockFetcher);
        await bloc.stream.firstWhere((state) => state.hasData);
        state = bloc.state;
      });

      test('Success fetch', () async {
        when(() => mockFetcher()).thenAnswer((_) async => tResult);

        final expectedStates = [
          state = state.toLoading(),
          state = state.toSuccess(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(), completion(tResult)),
        ]);
      });

      test('Failed fetch', () async {
        when(() => mockFetcher()).thenAnswer((_) async {
          Error.throwWithStackTrace(tError, tStackTrace);
        });

        final expectedStates = [
          state = state.toLoading(),
          state = state.toError(tError, tStackTrace),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(() => bloc.fetch(), throwsA(tError)),
        ]);
      });

      test('Cancel first success fetch and returns new fetch success result', () async {
        var count = -1;
        when(() => mockFetcher()).thenAnswer((_) async {
          await Future.delayed(const Duration());
          count++;
          return count == 0 ? 'WRONG_RESULT' : tResult;
        });

        final expectedStates = [
          state = state.toLoading(),
          state = state.toSuccess(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(), completion(tResult)),
          expectLater(bloc.fetch(), completion(tResult)),
        ]);
      });

      test('Cancel first error fetch and returns new fetch success result', () async {
        var count = -1;
        when(() => mockFetcher()).thenAnswer((_) async {
          count++;
          return count == 0 ? throw tError : tResult;
        });

        final expectedStates = [
          state = state.toLoading(),
          state = state.toSuccess(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(), completion(tResult)),
          expectLater(bloc.fetch(), completion(tResult)),
        ]);
      });

      test('Cancel first fetch and returns new fetch error result', () async {
        var count = -1;
        when(() => mockFetcher()).thenAnswer((_) async {
          count++;
          return count == 0 ? Future.error('', tStackTrace) : Future.error(tError, tStackTrace);
        });

        final expectedStates = [
          state = state.toLoading(),
          state = state.toError(tError, tStackTrace),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(() => bloc.fetch(), throwsA(tError)),
          expectLater(() => bloc.fetch(), throwsA(tError)),
        ]);
      });
    });
  });

  // when(() => mockFetcher()).thenAnswer((_) async {
  //   return _.positionalArguments[0] ? tResult : throw tError;
  // });
}

abstract class _Fetcher<R> {
  Future<R> call();
}

class _MockFetcher extends Mock implements _Fetcher<String> {}
