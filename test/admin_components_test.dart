import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';

Widget _app(Widget child, {Locale locale = const Locale('en')}) => MaterialApp(
  locale: locale,
  supportedLocales: const <Locale>[Locale('en'), Locale('fr')],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  home: Scaffold(body: child),
);

void main() {
  testWidgets('AdminActionCard exposes content and invokes its action', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      _app(
        AdminActionCard(
          icon: Icons.people,
          title: 'Users',
          description: 'Manage accounts',
          onTap: () => calls++,
        ),
      ),
    );

    expect(find.text('Users'), findsOneWidget);
    expect(find.text('Manage accounts'), findsOneWidget);
    await tester.tap(find.byType(InkWell));
    expect(calls, 1);
  });

  testWidgets(
    'AdminFeedback hides empty messages and localizes status titles',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(const AdminFeedback(message: '', isError: false)),
      );
      expect(find.byType(AdminStatusBanner), findsNothing);

      await tester.pumpWidget(
        _app(
          const AdminFeedback(message: 'Saved', isError: false),
          locale: const Locale('en'),
        ),
      );
      expect(find.text('Action completed'), findsOneWidget);

      await tester.pumpWidget(
        _app(
          const AdminFeedback(message: 'Erreur', isError: true),
          locale: const Locale('fr'),
        ),
      );
      expect(find.text('Action impossible'), findsOneWidget);
    },
  );

  testWidgets('AdminStatusBanner keeps its trailing action on narrow screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(400, 600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _app(
        AdminStatusBanner(
          icon: Icons.info,
          title: 'Status',
          message: 'Details',
          trailing: TextButton(onPressed: () {}, child: const Text('Retry')),
        ),
      ),
    );

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Details'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'AdminPageScaffold renders title, action and scrollable content',
    (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: AdminPageScaffold(
            title: 'Administration',
            actions: const <Widget>[Icon(Icons.settings)],
            child: Column(
              children: List<Widget>.generate(
                20,
                (index) => Text('Row $index'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('Administration'), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);
    },
  );
}
