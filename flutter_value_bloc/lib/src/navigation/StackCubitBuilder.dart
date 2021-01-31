import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class StackCubitBuilder<T> extends StatelessWidget {
  final NavigationCubit<T> navigationCubit;
  final AlignmentGeometry alignment;
  final TextDirection textDirection;
  final StackFit sizing;
  final Map<T, Widget> children;

  const StackCubitBuilder({
    Key key,
    @required this.navigationCubit,
    this.alignment = AlignmentDirectional.topStart,
    this.textDirection,
    this.sizing = StackFit.loose,
    @required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit<T>, NavigationCubitState<T>>(
      cubit: navigationCubit,
      builder: (context, state) {
        return IndexedStack(
          index: state.currentIndexPage,
          alignment: alignment,
          textDirection: textDirection,
          sizing: sizing,
          children: state.pages.map((page) {
            final current = children[page];

            assert(current != null, 'Not exist widget for this page: ${page}');

            return current;
          }).toList(),
        );
      },
    );
  }
}
