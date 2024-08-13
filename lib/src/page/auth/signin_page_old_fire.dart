import 'package:mymangatheque/src/components/my_square_tile.dart';
import 'package:mymangatheque/src/components/my_textfield.dart';
import 'package:mymangatheque/src/services/auth_services.dart';
import 'package:mymangatheque/src/components/my_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Dispose Variable
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // sign-in user method
  void signUserIn(context) async {
    // show circular progress
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: emailController.text, password: passwordController.text);
      GoRouter.of(context).go('/profile');
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        Navigator.pop(context);
        showMessage("Aucun utilisateur trouvé pour cette adresse email!");
      } else if (e.code == "invalid-email" || e.code == "wrong-password") {
        Navigator.pop(context);
        showMessage("Email ou mot de passe incorrect.");
      } else {
        Navigator.pop(context);
        showMessage(e.code);
      }
    }
  }

  // error message to user
  void showMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.cyanAccent,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        });
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          //TODO: Mettre AppBar title en français ou supprimer
          "Sign-In Page",
          style: GoogleFonts.poppins(),
        ),
        elevation: 0.0,
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 10),

                // Locker Icon
                SvgPicture.asset(
                  'assets/icons/locker.svg',
                  height: 100,
                  colorFilter: ColorFilter.mode(Theme.of(context).colorScheme.primary, BlendMode.srcIn)
                ),

                const SizedBox(height: 15),

                Text(
                  "Connectez-vous pour pouvoir sauvegarder vos mangas favoris et dans votre collection et vous éviter les doublons.",
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
                      labelText: "Votre Email",
                      obscureText: false,
                      errorMessage: "Veuillez enter votre email!",
                    ),

                    const SizedBox(height: 15),

                    // Password field
                    MyTextField(
                      controller: passwordController,
                      labelText: "Votre Mot de passe",
                      obscureText: true,
                      errorMessage: "Veuillez entrer votre mot de passe!",
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: TextButton(
                    onPressed: () => GoRouter.of(context).go('/profile/forgot_password'),
                    style: const ButtonStyle(
                      alignment: Alignment.centerRight,
                      padding: WidgetStatePropertyAll(EdgeInsets.all(0)),
                    ),
                    child: Text(
                      "Mot de passe oublié ?",
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
                  text: "Se connecter",
                  onTap: () => signUserIn(context),
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
                        AuthServices().signInWithGoogle(context),
                        context.go('/profile'),
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
                        "Pas encore de compte ?",
                        style: TextStyle(color: Theme.of(context).colorScheme.primary),
                      ),
                      const SizedBox(width: 4),
                      TextButton(
                          onPressed: () => GoRouter.of(context).go('/profile/signup'),
                          child: const Text(
                            "Créer en un maintenant",
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
