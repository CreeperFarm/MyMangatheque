import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/pocketbaseadmin.dart';
import 'package:mymangatheque/src/const/assets.dart';
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
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.adminLoginPage, style: GoogleFonts.poppins()),
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
                    Assets.logo.blueToneAndWhiteSquare,
                    width: 200,
                  ),
                ),
              ),
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
          const SizedBox(height: 15),
          // Display sign in button
          MyButton(
            text: localizations.logIn,
            onTap: () async {
              try {
                await connector
                    .loginAsAdmin(
                      emailController.text,
                      passwordController.text,
                      context,
                    )
                    .then((value) async {
                      if (value) {
                        if (!mounted) return;
                        setState(() {});
                        await Future.delayed(const Duration(milliseconds: 250));
                        if (!mounted) return;
                        GoRouter.of(context).push('/admin');
                        showMessage(localizations.adminLoginSuccess, context);
                      }
                    });
              } catch (e) {
                if (!mounted) return;
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
