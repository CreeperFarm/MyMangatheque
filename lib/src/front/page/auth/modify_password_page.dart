import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/const/routes.dart';

// ignore_for_file: use_build_context_synchronously

class ModifyPasswordPage extends StatefulWidget {
  const ModifyPasswordPage({super.key});

  @override
  State<ModifyPasswordPage> createState() => _ModifyPasswordPageState();
}

class _ModifyPasswordPageState extends State<ModifyPasswordPage> {
  // Define variable
  final oldPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final newPasswordVerifierController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorText = "";
  AppwriteConnector connector = AppwriteConnector();

  // Dispose Variable
  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordVerifierController.dispose();
    super.dispose();
  }

  Future passwordModify() async {
    try {
      await connector.modifyPassword(
        connector.getConnectedUser()!.email,
        oldPasswordController.text,
        newPasswordController.text,
        context,
      );
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      errorText = AppLocalizations.of(context)!.errorOccurred;
      showMessage(errorText, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (connector.getConnectedUser() == null) {
      pushOrGo(context, Routes.profile.signin);
    }
    return Scaffold(
      appBar: AppBar(title: Text(localizations.modifyPassword), elevation: 0),
      body: MyScrollColumn(
        scrollPadding: const EdgeInsets.symmetric(horizontal: 10),
        children: [
          Center(
            child: Column(
              children: [
                SvgPicture.asset(
                  Assets.icons.locker,
                  height: 200,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                const SizedBox(height: 11),
                Text(
                  localizations.modifyPassword,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(height: 11),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextField(
                        controller: oldPasswordController,
                        labelText: localizations.oldPassword,
                        obscureText: true,
                        errorMessage: localizations.provideOldPassword,
                      ),
                      const SizedBox(height: 11),
                      MyTextField(
                        controller: newPasswordController,
                        labelText: localizations.newPassword,
                        obscureText: true,
                        errorMessage: localizations.provideNewPassword,
                      ),
                      const SizedBox(height: 11),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: TextFormField(
                          controller: newPasswordVerifierController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.provideConfirmNewPassword;
                            } else if (value.length < 6) {
                              return localizations.passwordTooShort;
                            } else if (value != newPasswordController.text) {
                              return localizations.passwordsDoNotMatch;
                            } else {
                              return null;
                            }
                          },
                          decoration: InputDecoration(
                            errorBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            filled: true,
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            hintText: localizations.confirmNewPassword,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 11),
                MyButton(
                  text: localizations.modifyPassword,
                  onTap: () {
                    // Verify if all field is complete
                    if (_formKey.currentState!.validate()) {
                      if (newPasswordController.text !=
                          newPasswordVerifierController.text) {
                        errorText = localizations.passwordsDoNotMatch;
                      } else {
                        passwordModify();
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
