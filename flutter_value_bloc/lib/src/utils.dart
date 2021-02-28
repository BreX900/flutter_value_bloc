import 'package:flutter/widgets.dart';

typedef ViewWidgetBuilder<V> = Widget Function(BuildContext context, V value);

typedef DecorationWidgetBuilder = Widget Function(BuildContext context, Widget child);
