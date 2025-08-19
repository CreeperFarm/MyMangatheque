import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/language.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class ErrorPage extends ConsumerWidget {
  final GoException? error;

  const ErrorPage({required this.error, super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (error == null && error?.message == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.unknownError),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                localizations.unknownError,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  pushOrGo(context, "/");
                },
                child: Text(localizations.goHome),
              ),
            ],
          ),
        ),
      );
    }
    if (error!.message.contains('no routes for')) {
      return Scaffold(
        appBar: AppBar(
          title: Text(localizations.pageNotFound),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                localizations.error404,
                style: const TextStyle(fontSize: 36),
                textAlign: TextAlign.center,
              ),
              Text(
                localizations.pageNotFound,
                style: const TextStyle(fontSize: 24),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  pushOrGo(context, "/");
                },
                child: Text(localizations.goHome),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.errorOccurred),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              localizations.errorOccurredMessage(error!.message),
              style: const TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                pushOrGo(context, "/");
              },
              child: Text(localizations.goHome),
            ),
          ],
        ),
      ),
    );
  }
}
