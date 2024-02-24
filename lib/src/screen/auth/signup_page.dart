import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_date/dart_date.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/src/components/my_button.dart';
import 'package:mymangatheque/src/components/my_textfield.dart';
import 'package:mymangatheque/src/components/square_tile.dart';
import 'package:mymangatheque/src/services/auth_services.dart';

// ignore_for_file: use_build_context_synchronously

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
  final pseudoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String errorText = "";
  // For Ui

  // Dispose Variable
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    passwordVerifierController.dispose();
    pseudoController.dispose();
    super.dispose();
  }

  /*Future userDetails() async {

    await FirebaseFirestore.instance.collection('users').snapshots();

  }*/

  void signUserUp() async {
    // show circular progress
    showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
    );

    try {
      // Authenticate user
      await FirebaseAuth.instance.setLanguageCode("fr");
      await FirebaseAuth.instance.createUserWithEmailAndPassword(email: emailController.text, password: passwordController.text);

      // Add detail about user
      final todayDay = DateTime.now().format('dd');
      final todayMonth = DateTime.now().format('MM');
      final todayYear = DateTime.now().format('yyyy');
      Map month = {
        '01': 'Janvier',
        '02': 'Février',
        '03': 'Mars',
        '04': 'Avril',
        '05': 'Mai',
        '06': 'Juin',
        '07': 'Billet',
        '08': 'Août',
        '09': 'Septembre',
        '10': 'Octobre',
        '11': 'Novembre',
        '12': 'Décembre',
      };

      final user = FirebaseAuth.instance.currentUser!;

      await user.sendEmailVerification();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'pseudo': pseudoController.text,
        'email': user.email,
        'imageUrl': 'https://cdn.statically.io/gh/CreeperFarm/AppManga/main/default_pdp.jpg',
        'createdOn': '$todayDay ${month[todayMonth]} $todayYear',
        'authType': 'emailpass',
        'uid': user.uid,
      });

      // Go to profile page
      context.go('/profile');
    } on FirebaseAuthException catch (e){
      if (e.code == "weak-password") {
        Navigator.pop(context);
        errorText = "Veuillez inséré un mot de passe plus fort!";
        showMessage(errorText);
      } else if (e.code == "invalid-email" || e.code == "wrong-password") {
        Navigator.pop(context);
        errorText = "Email ou mot de passe incorrect.";
        showMessage(errorText);
      } else if (e.code == "email-already-in-use") {
        Navigator.pop(context);
        errorText = "L'Email est déjà utilisé.";
        showMessage(errorText);
      } else {
        Navigator.pop(context);
        errorText = e.code;
        showMessage(errorText);
      }
    }

  }

  // error message to user
  void showMessage(String message) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.blueGrey,
            title: Center(
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
          );
        }
    );
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
                const Icon(
                  Icons.lock,
                  size: 75,
                ),

                const SizedBox(height: 15),

                Text(
                  "Inscrivez-vous pour pouvoir sauvegarder vos mangas favoris et dans votre collection",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey,
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
                        controller: pseudoController,
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
                            enabledBorder: const OutlineInputBorder(),
                            focusedBorder: const OutlineInputBorder(
                              borderSide: BorderSide(),
                            ),
                            filled: true,
                            labelStyle: TextStyle(
                              color: Colors.grey[400],
                            ),
                            hintText: "Confirmer le mot de passe",
                          ),
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
                        signUserUp();
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
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(
                        "Ou continuer avec",
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
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
                        AuthServices().signInWithGoogle(),
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
                            color: Colors.grey[700]
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
