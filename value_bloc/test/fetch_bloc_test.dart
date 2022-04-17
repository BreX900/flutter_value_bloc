import 'package:mocktail/mocktail.dart';
import 'package:test/expect.dart';
import 'package:test/scaffolding.dart';
import 'package:value_bloc/src/fetch_bloc.dart';

class FakeError {}

class TestableBloc extends DemandBloc<int, String> {
  final Future<String> Function() _fetcher;

  TestableBloc(this._fetcher) : super(initialArg: 0);

  @override
  Future<String> onFetching(int args) async => await _fetcher();
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

        final expectedState = LoadingDemand<String>(
          hasData: false,
          data: null,
        );
        expect(bloc.state, expectedState);

        final expectedStates = [
          state = state.toFetched(tResult),
        ];
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
      });

      test('Failed initializing', () async {
        when(() => mockFetcher()).thenAnswer((_) async {
          throw Error.throwWithStackTrace(tError, tStackTrace);
        });

        final bloc = TestableBloc(mockFetcher);
        var state = bloc.state;

        final expectedState = LoadingDemand<String>(
          hasData: false,
          data: null,
        );
        expect(bloc.state, expectedState);

        final expectedStates = [
          state = state.toFetchFailed(tError, tStackTrace),
        ];
        await expectLater(bloc.stream, emitsInOrder(expectedStates));
      });
    });

    group('fetch', () {
      late DemandBloc<int, String> bloc;
      late DemandState<String> state;

      final tInitialResult = 'INITIAL_RESULT';

      setUp(() async {
        when(() => mockFetcher()).thenAnswer((_) async => tInitialResult);
        bloc = TestableBloc(mockFetcher);
        await bloc.stream.firstWhere((state) => state.hasData);
        state = bloc.state;
      });

      test('Success fetch', () async {
        when(() => mockFetcher()).thenAnswer((_) async => tResult);

        final expectedStates = [
          state = state.toFetching(),
          state = state.toFetched(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(1), completion(tResult)),
        ]);
      });

      test('Failed fetch', () async {
        when(() => mockFetcher()).thenAnswer((_) async {
          Error.throwWithStackTrace(tError, tStackTrace);
        });

        final expectedStates = [
          state = state.toFetching(),
          state = state.toFetchFailed(tError, tStackTrace),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(() => bloc.fetch(1), throwsA(tError)),
        ]);
      });

      test('Not fetch already fetched args', () async {
        final expectedStates = [
          emitsDone,
        ];
        await Future.wait<void>([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(0), completion(tInitialResult)),
          Future.delayed(const Duration(milliseconds: 1)).whenComplete(bloc.close),
        ]);
      });

      test('Fetch already fetched args if force is true', () async {
        when(() => mockFetcher()).thenAnswer((_) async => tResult);

        final expectedStates = [
          state = state.toFetching(),
          state = state.toFetched(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(0, force: true), completion(tResult)),
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
          state = state.toFetching(),
          state = state.toFetched(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(1, force: true), completion(tResult)),
          expectLater(bloc.fetch(1, force: true), completion(tResult)),
        ]);
      });

      test('Cancel first error fetch and returns new fetch success result', () async {
        var count = -1;
        when(() => mockFetcher()).thenAnswer((_) async {
          count++;
          return count == 0 ? throw tError : tResult;
        });

        final expectedStates = [
          state = state.toFetching(),
          state = state.toFetched(tResult),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(bloc.fetch(1, force: true), completion(tResult)),
          expectLater(bloc.fetch(1, force: true), completion(tResult)),
        ]);
      });

      test('Cancel first fetch and returns new fetch error result', () async {
        var count = -1;
        when(() => mockFetcher()).thenAnswer((_) async {
          count++;
          return count == 0 ? Future.error('', tStackTrace) : Future.error(tError, tStackTrace);
        });

        final expectedStates = [
          state = state.toFetching(),
          state = state.toFetchFailed(tError, tStackTrace),
        ];
        await Future.wait([
          expectLater(bloc.stream, emitsInOrder(expectedStates)),
          expectLater(() => bloc.fetch(1, force: true), throwsA(tError)),
          expectLater(() => bloc.fetch(1, force: true), throwsA(tError)),
        ]);
      });
    });
  });
}

abstract class _Fetcher<R> {
  Future<R> call();
}

class _MockFetcher extends Mock implements _Fetcher<String> {}
