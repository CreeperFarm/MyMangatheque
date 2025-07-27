import 'package:date_field/date_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbase.dart';
import 'package:mymangatheque/src/const/own_icon.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_square_tile.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:pocketbase/pocketbase.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // Define variable

  // For Sign Up
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final passwordVerifierController = TextEditingController();
  final usernameController = TextEditingController();
  DateTime selectedBDayDate = DateTime(DateTime.now().year - 7, DateTime.now().month, DateTime.now().day);
  final selectedGender = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final pb = PocketBase('https://api.mymangatheque.com', lang: "fr-FR");

  String errorText = "";

  void signingUpProcess() async {
    PocketBaseConnector connector = PocketBaseConnector();

    connector.createUser(usernameController.text, emailController.text, passwordController.text, passwordVerifierController.text, selectedGender.text,
        selectedBDayDate.add(const Duration(hours: 1)).toUtc().toString(), context);
    connector.sendVerification(emailController.text);
    await connector.updateUserData(emailController.text);
    context.go('/profile');
  }

  void signUp(AppLocalizations localizations) async {
    if (passwordController.text.length < 8) {
      print('Password must be at least 8 characters');
      errorText = localizations.passwordMinLength;
      return showMessage(errorText, context);
    } else if (!emailController.text.contains('@')) {
      print('Invalid email');
      errorText = localizations.invalidEmail;
      return showMessage(errorText, context);
    } else if (usernameController.text.length < 3) {
      print('Username must be at least 3 characters');
      errorText = localizations.usernameMinLength;
      return showMessage(errorText, context);
    } else {
      signingUpProcess();
    }
  }

  // For Ui

  // Dispose Variable
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordVerifierController.dispose();
    usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final PocketBaseConnector connector = PocketBaseConnector();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.signUpPage,
          style: GoogleFonts.poppins(),
        ),
        elevation: 0.0,
      ),
      body: MyScrollColumn(
        scrollPadding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: [
          Center(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Locker Icon
                SvgPicture.asset('assets/icons/locker.svg',
                    height: 75, colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn)),

                const SizedBox(height: 15),

                Text(
                  localizations.whySignUpDescription,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 15),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Display Name field
                      MyTextField(
                        controller: usernameController,
                        labelText: localizations.username,
                        obscureText: false,
                        errorMessage: localizations.provideUsername,
                      ),

                      const SizedBox(height: 11),

                      // Email field
                      MyTextField(
                        controller: emailController,
                        labelText: localizations.yourEmail,
                        obscureText: false,
                        errorMessage: localizations.provideYourEmail,
                      ),

                      const SizedBox(height: 11),

                      // Password field
                      MyTextField(
                        controller: passwordController,
                        labelText: localizations.yourPassword,
                        obscureText: true,
                        errorMessage: localizations.provideYourPassword,
                      ),

                      const SizedBox(height: 11),

                      // Password Confirm field

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: TextFormField(
                          controller: passwordVerifierController,
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return localizations.pleaseConfirmPassword;
                            }
                            if (value != passwordController.text) {
                              return localizations.passwordsDoNotMatch;
                            }
                            return null;
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
                            hintText: localizations.confirmYourPassword,
                          ),
                        ),
                      ),

                      const SizedBox(height: 11),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: DateTimeFormField(
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
                            hintText: localizations.yourBirthday,
                          ),
                          cupertinoDatePickerOptions: CupertinoDatePickerOptions(
                              modalTitleText: localizations.selectDate,
                              style: CupertinoDatePickerOptionsStyle(
                                  modalTitle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ))),
                          mode: DateTimeFieldPickerMode.date,
                          firstDate: DateTime(1900, 1, 1),
                          lastDate: DateTime(DateTime.now().year - 7, DateTime.now().month, DateTime.now().day),
                          initialPickerDateTime: DateTime(DateTime.now().year - 7, DateTime.now().month, DateTime.now().day),
                          validator: (value) {
                            if (value == null) {
                              return localizations.provideYourBirthday;
                            }
                            return null;
                          },
                          onChanged: (DateTime? value) {
                            setState(() {
                              selectedBDayDate = value!;
                            });
                          },
                        ),
                      ),

                      const SizedBox(height: 11),

                      DropdownButtonFormField(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
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
                            labelStyle: TextStyle(
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                            hintText: localizations.yourGender,
                          ),
                          items: [
                            DropdownMenuItem(
                              value: "male",
                              child: Text(localizations.male),
                            ),
                            DropdownMenuItem(
                              value: "female",
                              child: Text(localizations.female),
                            ),
                            DropdownMenuItem(
                              value: "other",
                              child: Text(localizations.other),
                            ),
                          ],
                          icon: OwnIcon(iconColor: Theme.of(context).colorScheme.primary, iconName: 'arrow-down'),
                          validator: (value) {
                            if (value == null) {
                              return localizations.provideYourGender;
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedGender.text = value.toString();
                            });
                          }),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // Button who create the account
                MyButton(
                  text: localizations.createAccount,
                  onTap: () async {
                    // Verify if all field is complete
                    if (_formKey.currentState!.validate()) {
                      if (passwordController.text != passwordVerifierController.text) {
                        errorText = localizations.passwordsDoNotMatch;
                      } else {
                        signUp(localizations);
                      }
                    }
                  },
                ),

                const SizedBox(height: 15),

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
                      imagePath: 'assets/images/google.png',
                      onTap: () => {
                        connector.signInWithGoogle(context),
                        context.go('/profile'),
                      },
                    ),

                    // const SizedBox(width: 25),

                    // ??? Button
                  ],
                ),

                const SizedBox(height: 15),

                // Already a Member ? Sign In now
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        localizations.alreadyHaveAnAccount,
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                        onPressed: () => context.go('/profile/signin'),
                        child: Text(
                          localizations.signIn,
                          style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
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
