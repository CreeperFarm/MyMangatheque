import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_square_tile.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/const/routes.dart';

typedef EmailSignInHandler =
    Future<User?> Function(
      String email,
      String password,
      BuildContext context,
    );

class SignInPage extends StatefulWidget {
  const SignInPage({this.signInHandler, super.key});

  final EmailSignInHandler? signInHandler;

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final connector = AppwriteConnector();
  bool _isSubmitting = false;

  Future<User?> signIn() async {
    if (_isSubmitting) return null;
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return null;
    if (emailController.text.trim().isEmpty) {
      showMessage(localizations.provideYourEmail, context);
      return null;
    }
    if (passwordController.text.isEmpty) {
      showMessage(localizations.provideYourPassword, context);
      return null;
    }

    setState(() => _isSubmitting = true);
    try {
      final handler = widget.signInHandler;
      final Future<User?> request;
      if (handler != null) {
        request = handler(
          emailController.text.trim(),
          passwordController.text,
          context,
        );
      } else {
        request = connector.loginWithEmail(
          emailController.text.trim(),
          passwordController.text,
          context,
        );
      }
      final userData = await request;

      if (!mounted || userData == null) return null;
      pushOrGo(context, Routes.profile.base);
      return userData;
    } catch (_) {
      if (!mounted) return null;
      showMessage(localizations.userLoginFailed, context);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
    return null;
  }

  // Dispose Variable
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.signInPage, style: GoogleFonts.poppins()),
        elevation: 0.0,
      ),
      body: MyScrollColumn(
        scrollPadding: const EdgeInsets.symmetric(horizontal: 20.0),
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Locker Icon
                SvgPicture.asset(
                  Assets.icons.locker,
                  height: 100,
                  colorFilter: ColorFilter.mode(
                    Theme.of(context).colorScheme.primary,
                    BlendMode.srcIn,
                  ),
                ),

                const SizedBox(height: 15),

                Text(
                  localizations.whyLogInDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17,
                  ),
                ),

                const SizedBox(height: 15),

                Column(
                  children: [
                    // Email field
                    MyTextField(
                      controller: emailController,
                      labelText: localizations.yourEmail,
                      obscureText: false,
                      errorMessage: localizations.provideYourEmail,
                    ),

                    const SizedBox(height: 15),

                    // Password field
                    MyTextField(
                      controller: passwordController,
                      labelText: localizations.yourPassword,
                      obscureText: true,
                      errorMessage: localizations.provideYourPassword,
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () =>
                        pushOrGo(context, Routes.profile.forgotPassword),
                    style: const ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                    ),
                    child: Text(
                      localizations.passwordForgot,
                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),

                // Display sign in button
                MyButton(
                  text: _isSubmitting
                      ? localizations.pleaseWait
                      : localizations.logIn,
                  onTap: _isSubmitting ? null : signIn,
                ),
                const SizedBox(height: 35),

                // Separation between login form and other way to connect
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        localizations.orContinueWith,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // Google + ??? sign in button
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Google Button
                    SquareTile(
                      imagePath: Assets.images.google,
                      onTap: () => {
                        RuntimeLocalization.debug(
                          en: 'Google sign-in selected.',
                          fr: 'Connexion Google sélectionnée.',
                        ),
                        connector.signInWithGoogle(context),
                      },
                    ),

                    // const SizedBox(width: 25),

                    // ??? Button
                  ],
                ),

                const SizedBox(height: 15),

                // Not a Member ? Register now
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.noAccountYet,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () =>
                            pushOrGo(context, Routes.profile.signup),
                        child: Text(
                          localizations.createAccount,
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
