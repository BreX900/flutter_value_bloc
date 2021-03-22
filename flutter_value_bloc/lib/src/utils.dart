import 'package:flutter/widgets.dart';

typedef CubitValueWidgetBuilder<V> = Widget Function(BuildContext context, V value);

typedef DecorationWidgetBuilder = Widget Function(BuildContext context, Widget child);
