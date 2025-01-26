import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

void pushOrGo(BuildContext context, String routeName) {
  if (kIsWeb) {
    context.go(routeName);
  } else {
    context.push(routeName);
  }
}
