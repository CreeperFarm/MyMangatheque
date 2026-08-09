import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';

void pushOrGo(BuildContext context, String routeName) {
  RuntimeLocalization.debug(
    en: 'Navigating to an application route.',
    fr: 'Navigation vers une route de l’application.',
  );
  if (kIsWeb) {
    context.go(routeName);
  } else {
    context.push(routeName);
  }
}
