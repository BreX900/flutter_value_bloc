import 'package:flutter/widgets.dart';

typedef ObjectWidgetBuilder<V> = Widget Function(BuildContext context, V value);

typedef ChildWidgetBuilder = Widget Function(BuildContext context, Widget child);
