import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_value_bloc/flutter_value_bloc.dart';
import 'package:value_bloc/value_bloc.dart';

class NavigationRailCubitBuilder<T> extends StatelessWidget {
  final NavigationCubit<T> navigationCubit;
  final Color backgroundColor;
  final bool extended;
  final Widget leading;
  final Widget trailing;
  final ValueChanged<int> onDestinationSelected;
  final double elevation;
  final double groupAlignment;
  final NavigationRailLabelType labelType;
  final TextStyle unselectedLabelTextStyle;
  final TextStyle selectedLabelTextStyle;
  final IconThemeData unselectedIconTheme;
  final IconThemeData selectedIconTheme;
  final double minWidth;
  final double minExtendedWidth;
  final Map<T, NavigationRailDestination> children;

  const NavigationRailCubitBuilder({
    Key key,
    @required this.navigationCubit,
    this.backgroundColor,
    this.extended = false,
    this.leading,
    this.trailing,
    this.onDestinationSelected,
    this.elevation,
    this.groupAlignment,
    this.labelType,
    this.unselectedLabelTextStyle,
    this.selectedLabelTextStyle,
    this.unselectedIconTheme,
    this.selectedIconTheme,
    this.minWidth,
    this.minExtendedWidth,
    @required this.children,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit<T>, NavigationCubitState<T>>(
      cubit: navigationCubit,
      builder: (context, state) {
        return NavigationRail(
          selectedIndex: state.currentIndexPage,
          backgroundColor: backgroundColor,
          extended: extended,
          leading: leading,
          trailing: trailing,
          onDestinationSelected: onDestinationSelected,
          elevation: elevation,
          groupAlignment: groupAlignment,
          labelType: labelType,
          unselectedLabelTextStyle: unselectedLabelTextStyle,
          selectedLabelTextStyle: selectedLabelTextStyle,
          unselectedIconTheme: unselectedIconTheme,
          selectedIconTheme: selectedIconTheme,
          minWidth: minWidth,
          minExtendedWidth: minExtendedWidth,
          destinations: state.pages.map((page) {
            final current = children[page];

            assert(current != null, 'Not exist widget for this page: ${page}');

            return current;
          }).toList(),
        );
      },
    );
  }
}
