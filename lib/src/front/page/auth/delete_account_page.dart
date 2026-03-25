import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

class DeleteAccountPage extends StatefulWidget {
  const DeleteAccountPage({super.key});

  @override
  State<DeleteAccountPage> createState() => _DeleteAccountPageState();
}

class _DeleteAccountPageState extends State<DeleteAccountPage> {
  PocketBaseConnector connector = PocketBaseConnector();

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!connector.isLoggedIn()) {
      pushOrGo(context, "/profile");
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final AlertDialog dialog = AlertDialog(
      constraints: BoxConstraints(maxHeight: 250),
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
                        child: Text(localizations.cancel, textAlign: TextAlign.center),
                      ),
                    ),
                    SizedBox(width: 20),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Close the confirmation dialog first
                          Navigator.of(context, rootNavigator: true).pop();

                          // Safety check
                          final user = connector.getConnectedUser();
                          if (user == null) {
                            showMessage(localizations.errorOccurred, context);
                            if (!kIsWeb) {
                              Navigator.of(context).pop();
                            } else {
                              pushOrGo(context, "/profile");
                            }
                            return;
                          }

                          try {
                            await connector.deleteUser(user.id);
                            // After successful deletion, log out locally and notify the user
                            connector.logOut();
                            showMessage(localizations.deleteAccountSuccess, context);

                            if (!kIsWeb) {
                              Navigator.of(context).pop();
                            } else {
                              pushOrGo(context, "/profile");
                            }
                          } catch (e) {
                            // If deletion failed, still log out and inform the user
                            connector.logOut();
                            showMessage(localizations.deleteAccountFailed, context);

                            if (!kIsWeb) {
                              Navigator.of(context).pop();
                            } else {
                              pushOrGo(context, "/profile");
                            }
                          }
                        },
                        style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.red)),
                        child: Text(
                          localizations.deleteAccount,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
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
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  showDialog(context: context, builder: (BuildContext context) => dialog);
                },
                style: ButtonStyle(backgroundColor: WidgetStateProperty.all<Color>(Colors.red)),
                child: Text(localizations.deleteAccount, style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
