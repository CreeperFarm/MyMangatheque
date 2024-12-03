import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_scroll_column.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final connector = PocketBaseAdminConnector();

  // Dispose Variable
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Page de connexion Admin",
          style: GoogleFonts.poppins(),
        ),
      ),
      body: MyScrollColumn(
        scrollPadding: const EdgeInsets.symmetric(horizontal: 8),
        children: [
          Column(
            children: [
              // Display logo
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30.0),
                  child: Image.asset(
                    'assets/images/logo_app.png',
                    width: 200,
                  ),
                ),
              ),
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
          SizedBox(
            height: 15,
          ),
          // Display sign in button
          MyButton(
            text: "Se connecter",
            onTap: () async {
              try {
                await connector.loginAsAdmin(emailController.text, passwordController.text, context).then((value) async {
                  if (value) {
                    setState(() {});
                    await Future.delayed(Duration(milliseconds: 250));
                    GoRouter.of(context).go('/admin');
                    showMessage("You're successfully connected to admins' pages", context);
                  }
                });
              } catch (e) {
                var error = e.toString();
                showMessage(error, context);
              }
            },
          ),
        ],
      ),
    );
  }
}
