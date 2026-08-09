import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/front/page/admin_pages/admin_components.dart';
import 'package:mymangatheque/src/function/auto_push_or_go.dart';

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final AdminConnector _admin = AdminConnector();
  final TextEditingController _apiKeyController = TextEditingController();
  bool _loading = false;
  bool _messageIsError = false;
  bool _obscureKey = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _admin.init().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _loginWithManualKey() async {
    if (_apiKeyController.text.trim().isEmpty) {
      setState(() {
        _message = context.localized(
          en: 'Enter an administrator API key.',
          fr: 'Saisis une clé API admin.',
        );
        _messageIsError = true;
      });
      return;
    }

    setState(() {
      _loading = true;
      _message = '';
      _messageIsError = false;
    });

    try {
      final ok = await _admin.loginAsAdmin(_apiKeyController.text.trim());
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messageIsError = !ok;
        _message = ok
            ? context.localized(
                en: 'Administrator sign-in successful.',
                fr: 'Connexion admin réussie.',
              )
            : context.localized(
                en: 'Invalid API key or insufficient permissions.',
                fr: 'Clé API invalide ou non admin.',
              );
      });
      if (ok) {
        _apiKeyController.clear();
        pushOrGo(context, '/admin');
      }
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messageIsError = true;
        _message = redactSensitiveText(error);
      });
    }
  }

  Future<void> _loginWithSessionKey() async {
    setState(() {
      _loading = true;
      _message = '';
      _messageIsError = false;
    });

    try {
      final ok = await _admin.loginWithCurrentSessionKey();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messageIsError = !ok;
        _message = ok
            ? context.localized(
                en: 'Administrator sign-in through the current session succeeded.',
                fr: 'Connexion admin via session réussie.',
              )
            : context.localized(
                en: 'The current session does not have administrator permissions.',
                fr: 'La session courante n’a pas les droits admin.',
              );
      });

      if (ok) {
        pushOrGo(context, '/admin');
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _messageIsError = true;
        _message = context.localized(
          en: 'Unable to use the current session: ${redactSensitiveText(e)}',
          fr: 'Impossible d’utiliser la session courante : ${redactSensitiveText(e)}',
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = _admin.isLoggedIn();
    return AdminPageScaffold(
      title: context.localized(
        en: 'Administrator sign-in',
        fr: 'Connexion administration',
      ),
      maxWidth: 680,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AdminPageHeader(
            icon: Icons.shield_outlined,
            title: context.localized(en: 'Secure access', fr: 'Accès sécurisé'),
            description: context.localized(
              en: 'Use a key with the permissions required by the management tools.',
              fr: 'Utilisez une clé disposant des permissions nécessaires aux outils de gestion.',
            ),
          ),
          const SizedBox(height: 20),
          AdminStatusBanner(
            icon: isLoggedIn
                ? Icons.verified_user_outlined
                : Icons.key_off_outlined,
            title: isLoggedIn
                ? context.localized(
                    en: 'Already signed in',
                    fr: 'Déjà connecté',
                  )
                : context.localized(
                    en: 'No active key',
                    fr: 'Aucune clé active',
                  ),
            message: isLoggedIn
                ? _admin.maskedKey
                : context.localized(
                    en: 'The key is kept in the device secure storage.',
                    fr: 'La clé est conservée dans le stockage sécurisé de l’appareil.',
                  ),
            tone: isLoggedIn ? AdminBannerTone.success : AdminBannerTone.info,
          ),
          const SizedBox(height: 16),
          Card(
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    context.localized(en: 'API key', fr: 'Clé API'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _apiKeyController,
                    maxLength: 4096,
                    autocorrect: false,
                    enableSuggestions: false,
                    obscureText: _obscureKey,
                    onSubmitted: (_) => _loading ? null : _loginWithManualKey(),
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: context.localized(
                        en: 'Administrator or moderator key',
                        fr: 'Clé administrateur ou modérateur',
                      ),
                      hintText: 'mmt_xxx...',
                      prefixIcon: const Icon(Icons.key_rounded),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureKey = !_obscureKey;
                          });
                        },
                        tooltip: _obscureKey
                            ? context.localized(
                                en: 'Show key',
                                fr: 'Afficher la clé',
                              )
                            : context.localized(
                                en: 'Hide key',
                                fr: 'Masquer la clé',
                              ),
                        icon: Icon(
                          _obscureKey
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _loading ? null : _loginWithManualKey,
                    icon: const Icon(Icons.login_rounded),
                    label: Text(
                      context.localized(
                        en: 'Sign in with this key',
                        fr: 'Se connecter avec cette clé',
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _loading ? null : _loginWithSessionKey,
                    icon: const Icon(Icons.person_outline_rounded),
                    label: Text(
                      context.localized(
                        en: 'Use current session',
                        fr: 'Utiliser la session courante',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_loading) ...[
            const SizedBox(height: 16),
            const LinearProgressIndicator(),
          ] else if (_message.isNotEmpty) ...[
            const SizedBox(height: 16),
            AdminFeedback(message: _message, isError: _messageIsError),
          ],
        ],
      ),
    );
  }
}
