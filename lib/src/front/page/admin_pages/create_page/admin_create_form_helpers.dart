import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mymangatheque/src/back/services/admin_service.dart';

List<String> parseAdminList(String value) {
  return value
      .split(RegExp(r'[,;\n]'))
      .map((item) => item.trim())
      .where((item) => item.isNotEmpty)
      .toList();
}

Map<String, String> parseAdminMetadata(String value) {
  final result = <String, String>{};
  for (final rawLine in value.split('\n')) {
    final line = rawLine.trim();
    if (line.isEmpty) continue;
    final separator = line.indexOf('=');
    if (separator <= 0 || separator == line.length - 1) {
      throw const AdminInputException(
        'Chaque information doit respecter le format clé=valeur.',
      );
    }
    result[line.substring(0, separator).trim()] = line
        .substring(separator + 1)
        .trim();
  }
  return result;
}

class AdminResponsiveFields extends StatelessWidget {
  const AdminResponsiveFields({required this.children, super.key});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                if (index > 0) const SizedBox(height: 12),
                children[index],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var index = 0; index < children.length; index++) ...[
              if (index > 0) const SizedBox(width: 12),
              Expanded(child: children[index]),
            ],
          ],
        );
      },
    );
  }
}

class AdminDateField extends StatelessWidget {
  const AdminDateField({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      key: ValueKey<DateTime?>(value),
      readOnly: true,
      initialValue: value == null
          ? ''
          : DateFormat('dd/MM/yyyy').format(value!),
      onTap: () async {
        final now = DateTime.now();
        final selected = await showDatePicker(
          context: context,
          initialDate: value ?? now,
          firstDate: DateTime(1900),
          lastDate: DateTime(now.year + 20, 12, 31),
        );
        if (selected != null) onChanged(selected);
      },
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        prefixIcon: const Icon(Icons.event_outlined),
        suffixIcon: value == null
            ? null
            : IconButton(
                onPressed: () => onChanged(null),
                tooltip: 'Effacer la date',
                icon: const Icon(Icons.clear_rounded),
              ),
      ),
    );
  }
}

class AdminAdultContentField extends StatelessWidget {
  const AdminAdultContentField({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SwitchListTile(
        title: const Text('Contenu réservé aux adultes'),
        subtitle: const Text('Masqué lorsque le contenu adulte est désactivé.'),
        secondary: const Icon(Icons.no_adult_content_outlined),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
