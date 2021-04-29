part of 'auth_cubit.dart';

abstract class Authorization with EquatableMixin {
  Authorization();
}

abstract class AuthCubitState<ExtraData> extends Equatable {
  final ExtraData extraData;

  const AuthCubitState({
    required this.extraData,
  });

  AuthCubitState<ExtraData?> toUnauthorizing() {
    final state = this;
    if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitUnauthorizing(extraData: extraData);
    } else {
      return this;
    }
  }

  AuthCubitState<ExtraData?> toUnauthorized() {
    final state = this;
    if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitUnauthorized();
    } else {
      return this;
    }
  }

  AuthCubitState<ExtraData?> toAuthorizing() {
    final state = this;
    if (state is AuthCubitUnauthorized<ExtraData>) {
      return AuthCubitAuthorizing(extraData: extraData);
    } else if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitReauthorizing(extraData: extraData);
    } else {
      return this;
    }
  }

  AuthCubitState<ExtraData?> toAuthorized() {
    final state = this;
    if (state is AuthCubitUnauthorized<ExtraData>) {
      return AuthCubitAuthorized(extraData: extraData);
    } else {
      return copyWith();
    }
  }

  AuthCubitState<ExtraData?> copyWith({Authorization? authorization, ExtraData? extraData}) {
    final state = this;
    if (state is AuthCubitReauthorizing<ExtraData>) {
      return AuthCubitReauthorizing(
        extraData: extraData ?? state.extraData,
      );
    } else if (state is AuthCubitUnauthorizing<ExtraData>) {
      return AuthCubitUnauthorizing(
        extraData: extraData ?? state.extraData,
      );
    } else if (state is AuthCubitAuthorized<ExtraData>) {
      return AuthCubitAuthorized(
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
  List<Object?> get props => [extraData];
}

class AuthCubitUnauthorized<ExtraData> extends AuthCubitState<ExtraData?> {
  const AuthCubitUnauthorized({ExtraData? extraData}) : super(extraData: extraData);
}

class AuthCubitAuthorizing<ExtraData> extends AuthCubitUnauthorized<ExtraData> {
  const AuthCubitAuthorizing({ExtraData? extraData}) : super(extraData: extraData);
}

class AuthCubitAuthorized<ExtraData> extends AuthCubitState<ExtraData?> {
  AuthCubitAuthorized({
    ExtraData? extraData,
  }) : super(extraData: extraData);

  @override
  List<Object?> get props => super.props;
}

class AuthCubitUnauthorizing<ExtraData> extends AuthCubitAuthorized<ExtraData> {
  AuthCubitUnauthorizing({
    ExtraData? extraData,
  }) : super(extraData: extraData);
}

class AuthCubitReauthorizing<ExtraData> extends AuthCubitAuthorized<ExtraData> {
  AuthCubitReauthorizing({
    ExtraData? extraData,
  }) : super(extraData: extraData);
}
