import 'package:date_field/date_field.dart';
import 'package:mymangatheque/src/components/my_square_tile.dart';
import 'package:mymangatheque/src/components/my_textfield.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';
import 'package:mymangatheque/src/components/my_button.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/src/services/pocketbase.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

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

    connector.createUser(
        usernameController.text,
        emailController.text,
        passwordController.text,
        passwordVerifierController.text,
        selectedGender.text,
        selectedBDayDate.add(const Duration(hours: 1)).toUtc().toString(),
        context
    );
    connector.sendVerification(emailController.text);
    await connector.updateUserData(emailController.text);
    context.go('/profile');
  }

  void signUp() async {

    if (passwordController.text.length < 8) {
      print('Password must be at least 8 characters');
      errorText = 'Password must be at least 8 characters';
      return showMessage(errorText, context);
    }
    else if (!emailController.text.contains('@')) {
      print('Invalid email');
      errorText = 'Invalid email';
      return showMessage(errorText, context);
    }
    else if (usernameController.text.length < 3) {
      print('Username must be at least 3 characters');
      errorText = 'Username must be at least 3 characters';
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

    return Scaffold(
      appBar: AppBar(
        title: Text(
          //TODO: Mettre AppBar title en français ou supprimer
          "Sign-Up Page",
          style: GoogleFonts.poppins(),
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Center(
            child: Column(
              children: [
                const SizedBox(height: 10),

                // Locker Icon
                SvgPicture.asset(
                    'assets/icons/locker.svg',
                    height: 75,
                    colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn)
                ),

                const SizedBox(height: 15),

                Text(
                  "Inscrivez-vous pour pouvoir sauvegarder vos mangas favoris et dans votre collection",
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
                        labelText: "Pseudo",
                        obscureText: false,
                        errorMessage: "Veuillez entrer un pseudo!",
                      ),

                      const SizedBox(height: 11),

                      // Email field
                      MyTextField(
                        controller: emailController,
                        labelText: "Votre Email",
                        obscureText: false,
                        errorMessage: "Veuillez enter votre email!",
                      ),

                      const SizedBox(height: 11),

                      // Password field
                      MyTextField(
                        controller: passwordController,
                        labelText: "Votre mot de passe",
                        obscureText: true,
                        errorMessage: "Veuillez entrer votre mot de passe!",
                      ),

                      const SizedBox(height: 11),

                      // Password Confirm field

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: TextFormField(
                          controller: passwordVerifierController,
                          obscureText: true,
                          validator: (value){
                            if (value == null || value.isEmpty){
                              return "Veuillez confirmer votre mot de passe!";
                            } if (value != passwordController.text) {
                              return "Vos mots de passe ne correspondent pas";
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
                            hintText: "Confirmer le mot de passe",
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
                            hintText: "Votre date de naissance",
                          ),
                          cupertinoDatePickerOptions: CupertinoDatePickerOptions(
                            modalTitleText: "Sélectionnez la date",
                            style: CupertinoDatePickerOptionsStyle(
                              modalTitle: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              )
                            )
                          ),
                          mode: DateTimeFieldPickerMode.date,
                          firstDate: DateTime(1900, 1, 1),
                          lastDate: DateTime(DateTime.now().year - 7, DateTime.now().month, DateTime.now().day),
                          initialPickerDateTime: DateTime(DateTime.now().year - 7, DateTime.now().month, DateTime.now().day),
                          validator: (value) {
                            if (value == null) {
                              return "Veuillez entrer votre date de naissance";
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

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5.0),
                        child: DropdownButtonFormField(
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
                            hintText: "Votre genre",
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: "men",
                              child: Text("Homme"),
                            ),
                            DropdownMenuItem(
                              value: "women",
                              child: Text("Femme"),
                            ),
                            DropdownMenuItem(
                              value: "other",
                              child: Text("Autre"),
                            ),
                          ],
                          validator: (value) {
                            if (value == null) {
                              return "Veuillez choisir votre genre";
                            }
                            return null;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedGender.text = value.toString();
                            });
                          }
                        ),
                      ),
                    ],
                  ),
                ),



                const SizedBox(height: 22),

                // Button who create the account
                MyButton(
                  text: "Créer un compte",
                  onTap: () async {
                    // Verify if all field is complete
                    if (_formKey.currentState!.validate()){
                      if (passwordController.text != passwordVerifierController.text) {
                        errorText = "Vos mots de passe ne correspondent pas";
                      } else {
                        signUp();
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
                        "Ou continuer avec",
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
                        PocketBaseConnector().signInWithGoogle(context),
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
                        "J'ai déjà un compte ?",
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.primary
                        ),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                          onPressed: () => context.go('/profile/signin'),
                          child: const Text(
                            "Se connecter",
                            style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold
                            ),
                          )
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}