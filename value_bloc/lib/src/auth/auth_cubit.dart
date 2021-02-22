import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

typedef Authorizer = void Function();

typedef Revoker = void Function();

class AuthCubit<Authorization> extends Cubit<AuthCubitState<Authorization>> {
  Authorizer _authorizer;
  Revoker _revoker;

  AuthCubit({
    bool isAuthorized,
    Stream<AuthEvent> onAuthorizationChanges,
  }) : super(isAuthorized ? AuthCubitAuthorized() : AuthCubitUnauthorized()) {
    onAuthorizationChanges.listen((event) {
      if (event is AuthorizingEvent) {
        emit(state.toUpdating());
      } else if (event is UnauthorizedEvent) {
        emit(state.toUnauthorized());
      } else if (event is AuthorizedEvent) {
        emit(state.toUpdating());
      }
    });
  }

  void authorize() {
    emit(state.toUpdating());
    _authorizer();
  }

  void revoke() {
    emit(state.toUpdating());
    _revoker();
  }

  void emitAuthorization() {
    emit(state.toUnauthorized());
  }

  void emitUnauthorized() {
    emit(state.toUnauthorized());
  }
}
