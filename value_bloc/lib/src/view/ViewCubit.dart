import 'package:bloc/bloc.dart';

mixin ViewCubitMixin<State> on Cubit<State> {}

abstract class ViewCubit<State> extends Cubit<State>
    with ViewCubitMixin<State> {
  ViewCubit(State state) : super(state);
}
