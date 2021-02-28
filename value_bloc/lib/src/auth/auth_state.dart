part of 'auth_cubit.dart';

abstract class Authorization with EquatableMixin {
  Authorization();
}

abstract class AuthCubitState<ExtraData> extends Equatable {
  final ExtraData extraData;

  const AuthCubitState({
    @required this.extraData,
  });

  AuthCubitState<ExtraData> toUnauthorizing() {
    final state = this;
    if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitUnauthorizing(authorization: state.authorization, extraData: extraData);
    } else {
      return this;
    }
  }

  AuthCubitState<ExtraData> toUnauthorized() {
    final state = this;
    if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitUnauthorized();
    } else {
      return this;
    }
  }

  AuthCubitState<ExtraData> toAuthorizing() {
    final state = this;
    if (state is AuthCubitUnauthorized<ExtraData>) {
      return AuthCubitAuthorizing(extraData: extraData);
    } else if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitReauthorizing(authorization: state.authorization, extraData: extraData);
    } else {
      return this;
    }
  }

  AuthCubitState<ExtraData> toAuthorized({@required Authorization authorization}) {
    final state = this;
    if (state is AuthCubitUnauthorized<ExtraData>) {
      return AuthCubitAuthorized(authorization: authorization, extraData: extraData);
    } else {
      return copyWith(authorization: authorization);
    }
  }

  AuthCubitState<ExtraData> copyWith({Authorization authorization, ExtraData extraData}) {
    final state = this;
    if (state is AuthCubitReauthorizing<ExtraData>) {
      return AuthCubitReauthorizing(
        authorization: authorization ?? state.authorization,
        extraData: extraData ?? state.extraData,
      );
    } else if (state is AuthCubitUnauthorizing<ExtraData>) {
      return AuthCubitUnauthorizing(
        authorization: authorization ?? state.authorization,
        extraData: extraData ?? state.extraData,
      );
    } else if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitAuthorized(
        authorization: authorization ?? state.authorization,
        extraData: extraData ?? state.extraData,
      );
    } else if (state is AuthCubitAuthorizing<ExtraData>) {
      return AuthCubitAuthorizing(
        extraData: extraData ?? state.extraData,
      );
    } else if (state is AuthCubitUnauthorized<ExtraData>) {
      return AuthCubitUnauthorized(
        extraData: extraData ?? state.extraData,
      );
    } else {
      throw 'Not support ${state}';
    }
  }

  @override
  List<Object> get props => [extraData];
}

class AuthCubitUnauthorized<ExtraData> extends AuthCubitState<ExtraData> {
  const AuthCubitUnauthorized({ExtraData extraData}) : super(extraData: extraData);
}

class AuthCubitAuthorizing<ExtraData> extends AuthCubitUnauthorized<ExtraData> {
  const AuthCubitAuthorizing({ExtraData extraData}) : super(extraData: extraData);
}

class AuthCubitAuthorized<ExtraData> extends AuthCubitState<ExtraData> {
  final Authorization authorization;

  AuthCubitAuthorized({
    @required this.authorization,
    ExtraData extraData,
  }) : super(extraData: extraData);

  @override
  List<Object> get props => super.props..add(authorization);
}

class AuthCubitUnauthorizing<ExtraData> extends AuthCubitAuthorized<ExtraData> {
  AuthCubitUnauthorizing({
    @required Authorization authorization,
    ExtraData extraData,
  }) : super(authorization: authorization, extraData: extraData);
}

class AuthCubitReauthorizing<ExtraData> extends AuthCubitAuthorized<ExtraData> {
  AuthCubitReauthorizing({
    @required Authorization authorization,
    ExtraData extraData,
  }) : super(authorization: authorization, extraData: extraData);
}
