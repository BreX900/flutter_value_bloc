import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:flutter_value_bloc/src/views/view_provider.dart';
import 'package:value_bloc/value_bloc.dart';

class ViewBlocBuilder<TBloc extends BlocBase<DataBlocState<TData, TFailure>>, TData,
    TFailure extends Object> extends StatelessWidget {
  final TBloc? bloc;
  final Widget Function(BuildContext context, TData data) builder;

  const ViewBlocBuilder({
    Key? key,
    this.bloc,
    required this.builder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TBloc, DataBlocState<TData, TFailure>>(
      builder: (context, state) {
        if (state.hasData) {
          return builder(context, state.data);
        }
        if (state.hasFailure) {
          return ViewsProvider.from<TFailure>(context).failureBuilder(context, state.failure!);
        }

        return ViewsProvider.from<TFailure>(context).loadingBuilder(context, null);
      },
    );
  }
}
