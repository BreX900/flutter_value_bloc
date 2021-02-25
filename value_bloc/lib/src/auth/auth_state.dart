part of 'auth_cubit.dart';

abstract class AuthEvent<Authorization> {}

abstract class AuthorizingEvent<Authorization> extends AuthEvent<Authorization> {}

abstract class AuthorizedEvent<Authorization> extends AuthEvent<Authorization> {}

abstract class UnauthorizedEvent<Authorization> extends AuthEvent<Authorization> {}

abstract class AuthCubitState<Authorization> extends Equatable {
  AuthCubitState toUpdating() {
    if (this is AuthCubitAuthorizing || this is AuthCubitAuthorized) {}
    return AuthCubitAuthorizing();
  }

  AuthCubitState toUnauthorized() {}

  AuthCubitState toAuthorized() {}
}

class AuthCubitUnauthorized<Authorization> extends AuthCubitState<Authorization> {
  @override
  List<Object> get props => [];
}

class AuthCubitAuthorizing<Authorization> extends AuthCubitUnauthorized<Authorization> {
  @override
  List<Object> get props => [];
}

class AuthCubitAuthorized<Authorization> extends AuthCubitState<Authorization> {
  final Authorization authorization;

  AuthCubitAuthorized({@required this.authorization});

  @override
  List<Object> get props => [authorization];
}

class AuthCubitUnauthorizing<Authorization> extends AuthCubitAuthorized<Authorization> {
  AuthCubitUnauthorizing({
    @required Authorization authorization,
  }) : super(authorization: authorization);
}

class AuthCubitReauthorizing<Authorization> extends AuthCubitAuthorized<Authorization> {
  AuthCubitReauthorizing({
    @required Authorization authorization,
  }) : super(authorization: authorization);
}
