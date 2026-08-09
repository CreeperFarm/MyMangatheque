import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/front/page/auth/signin_page.dart';
import 'package:mymangatheque/src/models/user.dart';

void main() {
  testWidgets('sign-in blocks duplicate submissions and stays on failure', (
    tester,
  ) async {
    final pending = Completer<User?>();
    var calls = 0;

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SignInPage(
          signInHandler: (email, password, context) {
            calls += 1;
            return pending.future;
          },
        ),
      ),
    );

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'reader@example.com');
    await tester.enterText(fields.at(1), 'correct-password');

    await tester.tap(find.text('Log In'));
    await tester.tap(find.text('Log In'));
    await tester.pump();

    expect(calls, 1);
    expect(find.byType(SignInPage), findsOneWidget);

    pending.complete(null);
    await tester.pump();

    expect(find.text('Log In'), findsOneWidget);
    expect(find.byType(SignInPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
