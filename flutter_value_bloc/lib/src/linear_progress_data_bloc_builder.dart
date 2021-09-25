import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class LinearProgressDataBlocBuilder<
        TDataBloc extends DataBloc<dynamic, dynamic, DataBlocState<dynamic, dynamic>>>
    extends StatelessWidget implements PreferredSizeWidget {
  final TDataBloc? dataBloc;

  const LinearProgressDataBlocBuilder({Key? key, this.dataBloc}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(8.0);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TDataBloc, DataBlocState<dynamic, dynamic>>(
      bloc: dataBloc,
      builder: (context, state) {
        return LinearProgressIndicator(
          value: state.isEmitting ? null : 0.0,
        );
      },
    );
  }
}
