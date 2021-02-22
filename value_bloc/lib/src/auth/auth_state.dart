part of 'auth_cubit.dart';

abstract class AuthEvent {}

abstract class AuthorizingEvent extends AuthEvent {}

abstract class AuthorizedEvent extends AuthEvent {}

abstract class UnauthorizedEvent extends AuthEvent {}

abstract class AuthCubitState<Authorization> extends Equatable {
  final Authorization authorization;

  const AuthCubitState({@required this.authorization});

  AuthCubitState toUpdating() {
    if (this is AuthCubitAuthorizing || this is AuthCubitAuthorized) {}
    return AuthCubitAuthorizing();
  }

  AuthCubitState toUnauthorized() {}

  AuthCubitState toAuthorized() {}
}

class AuthCubitAuthorizing extends AuthCubitState {
  @override
  List<Object> get props => [];
}

class AuthCubitAuthorized extends AuthCubitState {
  @override
  List<Object> get props => [];
}

class AuthCubitUnauthorizing extends AuthCubitState {
  @override
  List<Object> get props => [];
}

class AuthCubitUnauthorized extends AuthCubitState {
  @override
  List<Object> get props => [];
}
