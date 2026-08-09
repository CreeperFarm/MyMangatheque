import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';
import 'package:mymangatheque/src/back/services/appwrite.dart';
import 'package:mymangatheque/src/const/routes.dart';
import 'package:mymangatheque/src/front/components/my_button.dart';
import 'package:mymangatheque/src/front/components/my_textfield.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';
import 'package:mymangatheque/src/function/show_message_function.dart';

class AuthCallbackPage extends StatefulWidget {
  const AuthCallbackPage({
    super.key,
    this.userId,
    this.secret,
    this.hasError = false,
  });

  final String? userId;
  final String? secret;
  final bool hasError;

  @override
  State<AuthCallbackPage> createState() => _AuthCallbackPageState();
}

class _AuthCallbackPageState extends State<AuthCallbackPage> {
  final AppwriteConnector _connector = AppwriteConnector();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _callbackHandled = false;

  bool get _isRecoveryFlow {
    return (widget.userId ?? '').isNotEmpty && (widget.secret ?? '').isNotEmpty;
  }

  @override
  void initState() {
    super.initState();
    if (!_isRecoveryFlow) {
      _handleOAuthCallback();
    }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleOAuthCallback() async {
    if (_callbackHandled) return;
    _callbackHandled = true;

    setState(() {
      _isLoading = true;
    });

    try {
      await _connector.refreshSession();
      if (!mounted) return;

      if (_connector.isLoggedIn()) {
        pushOrGo(context, Routes.profile.base);
      } else {
        pushOrGo(context, Routes.profile.signin);
      }
    } catch (_) {
      if (!mounted) return;
      pushOrGo(context, Routes.profile.signin);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _submitRecovery() async {
    if (_isLoading) return;
    final localizations = AppLocalizations.of(context);
    if (localizations == null) return;

    if (!_formKey.currentState!.validate()) return;

    if (_newPasswordController.text.length < 8) {
      showMessage(localizations.passwordMinLength, context);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await _connector.completePasswordRecovery(
        userId: widget.userId!,
        secret: widget.secret!,
        newPassword: _newPasswordController.text,
        context: context,
      );

      if (!mounted) return;
      pushOrGo(context, Routes.profile.signin);
    } catch (_) {
      if (!mounted) return;
      showMessage(localizations.errorOccurred, context);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (widget.hasError && !_isRecoveryFlow) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            context.localized(
              en: 'Authentication confirmation',
              fr: 'Confirmation de l’authentification',
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  localizations.errorOccurred,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                MyButton(
                  text: localizations.logIn,
                  onTap: () => pushOrGo(context, Routes.profile.signin),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isRecoveryFlow) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            context.localized(
              en: 'Authentication confirmation',
              fr: 'Confirmation de l’authentification',
            ),
          ),
        ),
        body: Center(
          child: _isLoading
              ? const CircularProgressIndicator()
              : Text(localizations.pleaseWait),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(localizations.passwordReset)),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MyTextField(
                controller: _newPasswordController,
                labelText: localizations.newPassword,
                obscureText: true,
                errorMessage: localizations.provideNewPassword,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return localizations.provideConfirmNewPassword;
                    }
                    if (value != _newPasswordController.text) {
                      return localizations.passwordsDoNotMatch;
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    filled: true,
                    hintText: localizations.confirmNewPassword,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _isLoading
                  ? const CircularProgressIndicator()
                  : MyButton(
                      text: localizations.passwordReset,
                      onTap: _submitRecovery,
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
