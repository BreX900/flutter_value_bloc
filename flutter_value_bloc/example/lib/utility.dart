import 'package:flutter/foundation.dart';

void dumpErrorToConsole(FlutterErrorDetails details, {bool forceReport = false}) {
  assert(details != null);
  assert(details.exception != null);
  bool reportError = details.silent != true; // could be null
  assert(() {
// In checked mode, we ignore the "silent" flag.
    reportError = true;
    return true;
  }());
  if (!reportError && !forceReport) return;
  final packages = [
    'package:flutter/src/widgets/framework.dart',
    'package:flutter/src/rendering/binding.dart',
    'dart:async',
  ];
  var text = TextTreeRenderer(
    wrapWidth: 100,
    wrapWidthProperties: 100,
    maxDescendentsTruncatableNode: 5,
  ).render(details.toDiagnosticsNode(style: DiagnosticsTreeStyle.error)).trimRight();
  text = text.split('\n').map((e) {
    if (!e.startsWith('packages/')) return e;
    return e.replaceFirst('packages/', 'package:');
  }).where((e) {
    return !packages.any((element) => e.contains(element));
  }).join('\n');
  debugPrint(text);
}