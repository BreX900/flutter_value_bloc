import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

abstract class AuthCubit<ExtraData> extends Cubit<AuthCubitState<ExtraData>> {
  StreamSubscription _authorizationSub;

  AuthCubit({
    Authorization initialAuthorization,
    Stream<Authorization> onAuthorizationChanges,
  }) : super(() {
          if (initialAuthorization == null) {
            return AuthCubitUnauthorized();
          } else {
            return AuthCubitAuthorized(authorization: initialAuthorization);
          }
        }()) {
    _authorizationSub = onAuthorizationChanges?.listen((authorization) {
      emit(state.copyWith(authorization: authorization));
    });
  }

  void revokeAuthorization() {
    emit(state.toUnauthorizing());
    onRevokingAuthorization();
  }

  void onRevokingAuthorization();

  void emitAuthorization({@required Authorization authorization}) {
    emit(state.toAuthorized(authorization: authorization));
  }

  void emitUnauthorized() {
    emit(state.toUnauthorized());
  }

  @override
  Future<void> close() {
    _authorizationSub?.cancel();
    return super.close();
  }
}
