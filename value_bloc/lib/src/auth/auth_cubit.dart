import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

abstract class AuthCubit<ExtraData> extends Cubit<AuthCubitState<ExtraData>> {
  AuthCubit({
    bool isAuthorized = false,
  }) : super(() {
          if (isAuthorized) {
            return AuthCubitUnauthorized();
          } else {
            return AuthCubitAuthorized();
          }
        }());

  void revokeAuthorization() {
    emit(state.toUnauthorizing());
    onRevokingAuthorization();
  }

  void onRevokingAuthorization();

  void emitAuthorizing() {
    emit(state.toAuthorizing());
  }

  void emitAuthorization() {
    emit(state.toAuthorized());
  }

  void emitUnauthorized() {
    emit(state.toUnauthorized());
  }
}
