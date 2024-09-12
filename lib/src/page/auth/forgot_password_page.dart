import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/src/components/my_button.dart';
import 'package:mymangatheque/src/components/my_textfield.dart';

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

  Future passwordReset() async {
    //TODO: Make the password reset
    /*try {
      await FirebaseAuth.instance.setLanguageCode("fr");
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
      Navigator.pop(context);
      showMessage("Réinitialisation du mot de passe envoyé, vérifier votre boite mail.");
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-email") {
        Navigator.pop(context);
        errorText = "Veuillez inséré une adresse mail valide!";
        showMessage(errorText);
      } else if (e.code == "user-not-found") {
        Navigator.pop(context);
        errorText = "L'utilisateur n'a pas été trouvé.";
        showMessage(errorText);
      } else {
        Navigator.pop(context);
        errorText = e.code;
        showMessage(errorText);
      }
    }*/
  }

  // error message to user
  void showMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            title: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mot de passe oublié'),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset(
                  "assets/icons/lock_forgot.svg",
                  height: 150,
                  colorFilter: ColorFilter.mode(
                      Theme.of(context).colorScheme.primary, BlendMode.srcIn),
                ),
                Text(
                  "Entrer votre email et nous vous enverrons un email pour avec un lien pour réinitialiser votre mot de passe.",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 11),
                MyTextField(
                  controller: emailController,
                  labelText: "Email du compte",
                  obscureText: false,
                  errorMessage: "Veuillez enter votre email!",
                ),
                const SizedBox(height: 11),
                MyButton(
                  onTap: passwordReset,
                  text: "Envoyer le mail",
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
