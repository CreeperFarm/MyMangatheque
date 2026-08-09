import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/const/routes.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  final AppwriteConnector connector = AppwriteConnector();
  bool _isDeleting = false;
  bool _redirectScheduled = false;

  void _returnToProfile() {
    if (!mounted) return;
    if (!kIsWeb && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      pushOrGo(context, Routes.profile.base);
    }
  }

  Future<void> _deleteAccount(AppLocalizations localizations) async {
    if (_isDeleting) return;
    final user = connector.getConnectedUser();
    if (user == null) {
      showMessage(localizations.errorOccurred, context);
      _returnToProfile();
      return;
    }

    setState(() => _isDeleting = true);
    try {
      await connector.deleteUser(user.id);
      if (!mounted) return;
      showMessage(localizations.deleteAccountSuccess, context);
      _returnToProfile();
    } catch (_) {
      if (!mounted) return;
      // A failed deletion must keep the session available so the user can
      // retry or contact support instead of being silently logged out.
      showMessage(localizations.deleteAccountFailed, context);
    } finally {
      if (mounted) {
        setState(() => _isDeleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!connector.isLoggedIn()) {
      if (!_redirectScheduled) {
        _redirectScheduled = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) pushOrGo(context, Routes.profile.base);
        });
      }
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final AlertDialog dialog = AlertDialog(
      constraints: const BoxConstraints(maxHeight: 250),
      backgroundColor: Theme.of(context).colorScheme.onPrimary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      elevation: 10,
      content: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                localizations.areYouSureDeleteAccount,
                textAlign: TextAlign.center,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
              ),
              SizedBox(
                height: 40,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context, rootNavigator: true).pop();
                          if (!kIsWeb) {
                            Navigator.of(context).pop();
                          } else {
                            pushOrGo(context, "/profile");
                          }
                        },
                        child: Text(
                          localizations.cancel,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isDeleting
                            ? null
                            : () {
                                // Close the confirmation dialog first
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).pop();
                                _deleteAccount(localizations);
                              },
                        style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.all<Color>(
                            Colors.red,
                          ),
                        ),
                        child: Text(
                          localizations.deleteAccount,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(title: Text(localizations.deleteAccount)),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Text(
                  localizations.deleteAccountConfirmation,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: _isDeleting
                    ? null
                    : () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) => dialog,
                        );
                      },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.red),
                ),
                child: Text(
                  localizations.deleteAccount,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              if (_isDeleting) ...[
                const SizedBox(height: 16),
                const CircularProgressIndicator(),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
