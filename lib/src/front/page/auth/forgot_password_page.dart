import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

// ignore_for_file: use_build_context_synchronously

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // Define variable
  final emailController = TextEditingController();
  String errorText = "";

  // Dispose Variable
  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset(email) async {
    try {
      await PocketBaseConnector().resetPassword(email, context);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      errorText = e.toString();
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

    return Scaffold(
      appBar: AppBar(title: Text(localizations.passwordForgot), elevation: 0),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                  Assets.icons.lockForgot,
                  height: 150,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),
                Text(
                  localizations.enterEmailForSendingEmailReset,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 11),
                MyTextField(
                  controller: emailController,
                  labelText: localizations.accountEmail,
                  obscureText: false,
                  errorMessage: localizations.provideAccountEmail,
                ),
                const SizedBox(height: 11),
                MyButton(
                  text: localizations.passwordReset,
                  onTap: () {
                    if (emailController.text.isEmpty) {
                      showMessage(localizations.provideAccountEmail, context);
                    } else if (!emailController.text.contains('@') ||
                        !emailController.text.contains('.')) {
                      showMessage(
                        localizations.provideValidAccountEmail,
                        context,
                      );
                    } else {
                      PocketBaseConnector().resetPassword(
                        emailController.text,
                        context,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
