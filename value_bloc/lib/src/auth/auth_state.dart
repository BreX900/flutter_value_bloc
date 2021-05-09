part of 'auth_cubit.dart';

abstract class AuthCubitState<TFailure, TSuccess> extends Equatable {
  const AuthCubitState();

  bool get isAuthorizing =>
      this is AuthCubitAuthorizing<TFailure, TSuccess> ||
      this is AuthCubitUnauthorizing<TFailure, TSuccess> ||
      this is AuthCubitReauthorizing<TFailure, TSuccess>;

  bool get isUnauthorized => this is AuthCubitUnauthorized<TFailure, TSuccess>;

  bool get isAuthorized => this is AuthCubitAuthorized<TFailure, TSuccess>;

  AuthCubitState<TFailure, TSuccess> toUnauthorizing() {
    final state = this;
    if (state is AuthCubitAuthorized<TFailure, TSuccess>) {
      return AuthCubitUnauthorizing(success: state.success);
    } else {
      return this;
    }
  }

  AuthCubitState<TFailure, TSuccess> toAuthorizationFailed({required TFailure failure}) {
    final state = this;
    if (state is AuthCubitUnauthorized<TFailure, TSuccess>) {
      return AuthCubitUnauthorized(failure: failure);
    } else {
      return this;
    }
  }

  AuthCubitState<TFailure, TSuccess> toUnauthorized() {
    final state = this;
    if (state is AuthCubitAuthorized<TFailure, TSuccess>) {
      return AuthCubitUnauthorized();
    } else {
      return this;
    }
  }

  AuthCubitState<TFailure, TSuccess> toAuthorizing() {
    final state = this;
    if (state is AuthCubitUnauthorized<TFailure, TSuccess>) {
      return AuthCubitAuthorizing();
    } else if (state is AuthCubitAuthorized<TFailure, TSuccess>) {
      return AuthCubitReauthorizing(success: state.success);
    } else {
      return this;
    }
  }

  AuthCubitState<TFailure, TSuccess> toRevokeFailed({required TFailure failure}) {
    final state = this;
    if (state is AuthCubitAuthorized<TFailure, TSuccess>) {
      return AuthCubitAuthorized(failure: failure, success: state.success);
    } else {
      return this;
    }
  }

  AuthCubitState<TFailure, TSuccess> toAuthorized({required TSuccess success}) {
    final state = this;
    if (state is AuthCubitUnauthorized<TFailure, TSuccess>) {
      return AuthCubitAuthorized(success: success);
    } else {
      return this;
    }
  }

  @override
  bool get stringify => true;
}

class AuthCubitUnauthorized<TFailure, TSuccess> extends AuthCubitState<TFailure, TSuccess> {
  final TFailure? failure;

  const AuthCubitUnauthorized({this.failure}) : super();

  @override
  List<Object?> get props => [failure];
}

class AuthCubitAuthorizing<TFailure, TSuccess> extends AuthCubitUnauthorized<TFailure, TSuccess> {
  const AuthCubitAuthorizing() : super();
}

class AuthCubitAuthorized<TFailure, TSuccess> extends AuthCubitState<TFailure, TSuccess> {
  final TFailure? failure;
  final TSuccess success;

  AuthCubitAuthorized({this.failure, required this.success}) : super();

  @override
  List<Object?> get props => [failure, success];
}

class AuthCubitUnauthorizing<TFailure, TSuccess> extends AuthCubitAuthorized<TFailure, TSuccess> {
  AuthCubitUnauthorizing({required TSuccess success}) : super(success: success);
}

class AuthCubitReauthorizing<TFailure, TSuccess> extends AuthCubitAuthorized<TFailure, TSuccess> {
  AuthCubitReauthorizing({required TSuccess success}) : super(success: success);
}
