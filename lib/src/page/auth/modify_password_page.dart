import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mymangatheque/src/components/my_button.dart';
import 'package:mymangatheque/src/components/my_textfield.dart';

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

  // Dispose Variable
  @override
  void dispose() {
    oldPasswordController.dispose();
    newPasswordController.dispose();
    newPasswordVerifierController.dispose();
    super.dispose();
  }

  signIn() async {
    /*try {
      await FirebaseAuth.instance.setLanguageCode("fr");
      await FirebaseAuth.instance.signInWithEmailAndPassword(email: user.email.toString(), password: oldPasswordController.text);
      passwordModify();
    } on FirebaseAuthException catch (e) {
      if (e.code == "user-not-found") {
        Navigator.pop(context);
        showMessage("Aucun utilisateur trouvé pour cette adresse email!");
      } else if (e.code == "wrong-password") {
        Navigator.pop(context);
        showMessage("Mot de passe incorrect.");
      } else {
        Navigator.pop(context);
        showMessage(e.code);
      }
    }*/
  }

  Future passwordModify() async {
    //TODO: Make the password reset
    /*try {
      await user.updatePassword(oldPasswordController.text);
      Navigator.pop(context);
      showMessage("Réinitialisation du mot de passe envoyé, vérifier votre boite mail.");
      GoRouter.of(context).go('/profile');
    } on FirebaseAuthException catch (e) {
      if (e.code == "weak-password") {
        Navigator.pop(context);
        errorText = "Veuillez inséré un mot de passe plus fort!";
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
        title: const Text('Modification du mot de passe'),
        elevation: 0,
      ),
      body: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 10),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SvgPicture.asset('assets/icons/locker.svg',
                    height: 200,
                    colorFilter: ColorFilter.mode(
                        Theme.of(context).colorScheme.primary,
                        BlendMode.srcIn)),
                const SizedBox(height: 11),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      MyTextField(
                        controller: oldPasswordController,
                        labelText: "Ancien mot de passe",
                        obscureText: true,
                        errorMessage:
                            "Veuillez enter votre ancien mot de passe!",
                      ),
                      const SizedBox(height: 11),
                      MyTextField(
                        controller: newPasswordController,
                        labelText: "Nouveau mot de passe",
                        obscureText: true,
                        errorMessage:
                            "Veuillez enter votre nouveau mot de passe!",
                      ),
                      const SizedBox(height: 11),
                      MyTextField(
                        controller: newPasswordController,
                        labelText: "Confirmer le mot de passe",
                        obscureText: true,
                        errorMessage:
                            "Veuillez enter votre nouveau mot de passe!",
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 11),
                MyButton(
                  text: "Changer le mot de passe",
                  onTap: () => {
                    // Verify if all field is complete
                    if (_formKey.currentState!.validate())
                      {
                        if (newPasswordController.text !=
                            newPasswordVerifierController.text)
                          {errorText = "Vos mots de passe ne correspondent pas"}
                        else
                          {signIn()}
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
