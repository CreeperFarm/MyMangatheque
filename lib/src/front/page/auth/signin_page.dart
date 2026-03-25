import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/assets.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_square_tile.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/const/routes.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final connector = PocketBaseConnector();

  Future<User?> signIn(BuildContext context) async {
    try {
      final userData = await connector.loginWithEmail(
        emailController.text,
        passwordController.text,
        context,
      );
      debugPrint(userData.toString());

      debugPrint('connector id ${connector.getConnectedUser()!.id}');

      if (!mounted) return null;
      pushOrGo(context, Routes.profile.base);
      return userData;
    } catch (e) {
      if (!mounted) return null;
      //var error = json.decode(e.toString().replaceAll('ClientException: ', ''));
      //print(error);
      //print(error['response']['message']);
      //showMessage(error['response']['message'], context);
      var error = e.toString();
      showMessage(error, context);
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
                  text: localizations.logIn,
                  onTap: () async {
                    try {
                      await connector.loginWithEmail(
                        emailController.text,
                        passwordController.text,
                        context,
                      );
                      if (!mounted) return;
                      setState(() {});
                      pushOrGo(context, Routes.profile.base);
                    } catch (e) {
                      if (!mounted) return;
                      showMessage(e.toString(), context);
                    }
                  },
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
                        debugPrint("Google Sign In got clicked"),
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
