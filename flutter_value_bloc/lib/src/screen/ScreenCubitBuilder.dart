import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/src/load/CircularProgressCubitBuilder.dart';
import 'package:value_bloc/value_bloc.dart';

class ScreenCubitConsumer<SC extends ScreenCubit<S, LoadCubitData>, S, LoadCubitData>
    extends StatelessWidget {
  final SC screenCubit;
  final ViewErrorBuilder errorBuilder;
  final ViewLoaderBuilder loadingBuilder;
  final BlocWidgetListener<S> listener;
  final BlocWidgetBuilder<S> builder;

  const ScreenCubitConsumer({
    Key key,
    this.screenCubit,
    this.errorBuilder,
    this.loadingBuilder,
    this.listener,
    @required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenCubit = this.screenCubit ?? BlocProvider.of<SC>(context);

    return CircularProgressCubitBuilder(
      loadCubit: screenCubit.loadCubit,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      builder: (context) {
        return BlocConsumer<SC, S>(
          cubit: screenCubit,
          listener: listener,
          builder: builder,
        );
      },
    );
  }
}
