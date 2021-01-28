import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:test/test.dart' as test;

void testPrint(Object object) {
  print(object);
}

Future<void> runBlocTest<C extends Cubit<State>, State>({
  @required C Function() build,
  Function(C cubit) act,
  Duration wait,
  int skip = 0,
  Iterable expect,
  Function(C cubit) verify,
  Iterable errors,
}) async {
  final unhandledErrors = <Object>[];
  var shallowEquality = false;
  final states = <State>[];
  await runZoned(() async {
    final cubit = build();
    states.add(cubit.state);
    final subscription = cubit.skip(skip).listen(states.add);
    try {
      await act?.call(cubit);
    } on Exception catch (error) {
      unhandledErrors.add(
        error is CubitUnhandledErrorException ? error.error : error,
      );
      print(states);
    }
    if (wait != null) await Future<void>.delayed(wait);
    await Future<void>.delayed(Duration.zero);
    await cubit.close();
    if (expect != null) {
      shallowEquality = '$states' == '$expect';
      test.expect(states, expect);
    }
    await subscription.cancel();
    await verify?.call(cubit);
  }, onError: (Object error) {
    print(states);
    if (error is CubitUnhandledErrorException) {
      unhandledErrors.add(error.error);
    } else if (shallowEquality && error is test.TestFailure) {
      // ignore: only_throw_errors
      throw test.TestFailure(
        '''${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the blocTest rather than concrete state instances.\n''',
      );
    } else {
      // ignore: only_throw_errors
      throw error;
    }
  });
  if (errors != null) test.expect(unhandledErrors, errors);
}

class CubitTest<C extends Cubit<S>, S> {
  final void Function(C cubit) act;
  final Iterable expect;

  CubitTest({this.act, this.expect});
}

Future<void> runCubitTest<C extends Cubit<State>, State>({
  @required C Function() build,
  Duration wait = Duration.zero,
  int skip = 0,
  Iterable<CubitTest<C, State>> tests,
  Function(C cubit) verify,
  Iterable errors,
}) async {
  final unhandledErrors = <Object>[];
  var shallowEquality = false;
  var allStates = <State>[];
  await runZoned(() async {
    final cubit = build();
    final currentStates = <State>[];
    currentStates.add(cubit.state);
    final subscription = cubit.skip(skip).listen(currentStates.add);
    for (var t in tests) {
      try {
        await t.act?.call(cubit);
      } on Exception catch (error) {
        unhandledErrors.add(
          error is CubitUnhandledErrorException ? error.error : error,
        );
        print([allStates, currentStates]);
      }

      await Future<void>.delayed(wait);

      if (t.expect != null) {
        shallowEquality = '${[allStates, currentStates]}' == '${[allStates, t.expect]}';
        test.expect([allStates, currentStates], [allStates, t.expect]);
      }
      allStates..addAll(currentStates);
      currentStates.clear();
    }
    await cubit.close();
    await subscription.cancel();
    await verify?.call(cubit);
  }, onError: (Object error) {
    print(allStates);
    if (error is CubitUnhandledErrorException) {
      unhandledErrors.add(error.error);
    } else if (shallowEquality && error is test.TestFailure) {
      // ignore: only_throw_errors
      throw test.TestFailure(
        '''${error.message}
WARNING: Please ensure state instances extend Equatable, override == and hashCode, or implement Comparable.
Alternatively, consider using Matchers in the expect of the blocTest rather than concrete state instances.\n''',
      );
    } else {
      // ignore: only_throw_errors
      throw error;
    }
  });
  if (errors != null) test.expect(unhandledErrors, errors);
}
