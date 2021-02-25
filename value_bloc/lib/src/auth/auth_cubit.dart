import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

abstract class AuthRequest {}

class RevokeAuthRequest extends AuthRequest {}

class EmailAndPasswordAuthRequest extends AuthRequest {
  final String email;
  final String password;

  EmailAndPasswordAuthRequest(this.email, this.password);
}

typedef Authorizer = void Function(AuthRequest request);

class AuthCubit<Authorization> extends Cubit<AuthCubitState<Authorization>> {
  StreamSubscription _authorizationSub;
  Authorizer _authorizer;

  AuthCubit({
    AuthEvent<Authorization> initialAuthorization,
    Stream<AuthEvent> onAuthorizationChanges,
    Authorizer authorizer,
  })  : _authorizer = authorizer,
        super(() {
          if (initialAuthorization is AuthorizedEvent<Authorization>) {
            return AuthCubitAuthorized(authorization: null);
          } else if (initialAuthorization is AuthorizingEvent<Authorization>) {
            return AuthCubitAuthorizing();
          } else {
            return AuthCubitUnauthorized();
          }
        }()) {
    _authorizationSub = onAuthorizationChanges?.listen((event) {
      if (event is AuthorizingEvent) {
        emit(state.toUpdating());
      } else if (event is UnauthorizedEvent) {
        emit(state.toUnauthorized());
      } else if (event is AuthorizedEvent) {
        emit(state.toUpdating());
      }
    });
  }

  void applyAuthorizer(Authorizer authorizer) {
    _authorizer = authorizer;
  }

  void authorizeWithEmailAndPassword(String email, String password) {
    emit(state.toUpdating());
    _authorizer(EmailAndPasswordAuthRequest(email, password));
  }

  void revokeAuthorization() {
    emit(state.toUpdating());
    _authorizer(RevokeAuthRequest());
  }

  void emitAuthorization() {
    emit(state.toUnauthorized());
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
