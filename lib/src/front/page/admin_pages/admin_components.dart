import 'package:flutter/material.dart';
import 'package:mymangatheque/src/back/language/runtime_localization.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';
import 'package:mymangatheque/src/back/services/security/security_utils.dart';
import 'package:mymangatheque/src/const/layout.dart';

class AdminPageScaffold extends StatelessWidget {
  const AdminPageScaffold({
    required this.title,
    required this.child,
    this.actions = const <Widget>[],
    this.appBarBottom,
    this.scrollable = true,
    this.maxWidth = 1080,
    this.padding = const EdgeInsets.fromLTRB(16, 20, 16, 24),
    super.key,
  });

  final String title;
  final Widget child;
  final List<Widget> actions;
  final PreferredSizeWidget? appBarBottom;
  final bool scrollable;
  final double maxWidth;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Text(title),
        actions: actions,
        bottom: appBarBottom,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomNavigationInset =
              constraints.maxWidth <= phoneNavigationMaxWidth
              ? phoneBottomNavigationClearance
              : 0.0;
          final content = Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: child,
            ),
          );

          if (!scrollable) {
            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomNavigationInset),
                child: content,
              ),
            );
          }

          return SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: padding.copyWith(
                bottom: padding.bottom + bottomNavigationInset,
              ),
              child: content,
            ),
          );
        },
      ),
    );
  }
}

class AdminPageHeader extends StatelessWidget {
  const AdminPageHeader({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: colorScheme.tertiaryFixed.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: colorScheme.tertiaryFixed, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 4),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class AdminSectionTitle extends StatelessWidget {
  const AdminSectionTitle({required this.title, this.trailing, super.key});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class AdminActionCard extends StatelessWidget {
  const AdminActionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colorScheme.onPrimaryContainer),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.chevron_right_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminStatusBanner extends StatelessWidget {
  const AdminStatusBanner({
    required this.icon,
    required this.title,
    required this.message,
    this.tone = AdminBannerTone.info,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String message;
  final AdminBannerTone tone;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = _bannerColors(context, tone);
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackAction = trailing != null && constraints.maxWidth < 520;
        final text = Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colors.foreground),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: colors.foreground,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        );

        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colors.background,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: colors.foreground.withValues(alpha: 0.28),
            ),
          ),
          child: stackAction
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    text,
                    const SizedBox(height: 12),
                    Align(alignment: Alignment.centerRight, child: trailing!),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: text),
                    if (trailing != null) ...[
                      const SizedBox(width: 12),
                      trailing!,
                    ],
                  ],
                ),
        );
      },
    );
  }
}

enum AdminBannerTone { info, success, warning, error }

({Color background, Color foreground}) _bannerColors(
  BuildContext context,
  AdminBannerTone tone,
) {
  final colorScheme = Theme.of(context).colorScheme;
  final foreground = switch (tone) {
    AdminBannerTone.info => colorScheme.tertiaryFixed,
    AdminBannerTone.success => const Color(0xFF26834A),
    AdminBannerTone.warning => const Color(0xFF956400),
    AdminBannerTone.error => colorScheme.error,
  };
  return (
    background: foreground.withValues(alpha: 0.09),
    foreground: foreground,
  );
}

class AdminFormView extends StatelessWidget {
  const AdminFormView({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return LayoutBuilder(
      builder: (context, constraints) => SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Card(
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminFeedback extends StatelessWidget {
  const AdminFeedback({
    required this.message,
    required this.isError,
    super.key,
  });

  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return AdminStatusBanner(
      icon: isError ? Icons.error_outline_rounded : Icons.task_alt_rounded,
      title: isError
          ? context.localized(en: 'Action failed', fr: 'Action impossible')
          : context.localized(en: 'Action completed', fr: 'Action terminée'),
      message: message,
      tone: isError ? AdminBannerTone.error : AdminBannerTone.success,
    );
  }
}

class AdminExportButton extends StatefulWidget {
  const AdminExportButton({required this.resource, super.key});

  final String resource;

  @override
  State<AdminExportButton> createState() => _AdminExportButtonState();
}

class _AdminExportButtonState extends State<AdminExportButton> {
  final AdminConnector _admin = AdminConnector();
  bool _busy = false;

  Future<void> _request() async {
    setState(() => _busy = true);
    try {
      final response = await _admin.requestAdminExport(
        resource: widget.resource,
      );
      if (!mounted) return;
      final rawData = response['data'];
      final data = rawData is Map
          ? Map<String, dynamic>.from(rawData)
          : response;
      final reference = data['exportId'] ?? data['id'] ?? data['message'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            reference.toString().trim().isEmpty
                ? context.localized(
                    en: 'Export requested. Its download will appear in the audit module.',
                    fr: 'Export demandé. Son téléchargement apparaîtra dans le module d’audit.',
                  )
                : context.localized(
                    en: 'Export requested: $reference',
                    fr: 'Export demandé : $reference',
                  ),
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(redactSensitiveText(error))),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _busy ? null : _request,
      tooltip: context.localized(
        en: 'Request CSV export',
        fr: 'Demander un export CSV',
      ),
      icon: _busy
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Icon(Icons.download_outlined),
    );
  }
}
