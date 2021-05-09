import 'package:bloc/bloc.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

part 'auth_state.dart';

abstract class AuthCubit<TFailure, TSuccess> extends Cubit<AuthCubitState<TFailure, TSuccess>> {
  AuthCubit({
    required Either<TFailure?, TSuccess> response,
  }) : super(response.fold((failure) {
          return AuthCubitUnauthorized<TFailure, TSuccess>(failure: failure);
        }, (success) {
          return AuthCubitAuthorized<TFailure, TSuccess>(success: success);
        }));

  void revokeAuthorization() {
    emit(state.toUnauthorizing());
    onRevokingAuthorization();
  }

  void onRevokingAuthorization();

  void emitAuthorizing() {
    emit(state.toAuthorizing());
  }

  void emitFailed({required TFailure failure}) {
    emit(state.toAuthorizationFailed(failure: failure));
  }

  void emitUnauthorized() {
    emit(state.toUnauthorized());
  }

  void emitAuthorized({required TSuccess success}) {
    emit(state.toAuthorized(success: success));
  }
}
