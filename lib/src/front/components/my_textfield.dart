import 'package:flutter/material.dart';
import 'package:mymangatheque/l10n/app_localizations.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool? obscureText;
  final String errorMessage;
  final TextInputType? keyboardType;
  final double? verticalPadding;
  final double? horizontalPadding;
  final bool? skipEmptyVerification;
  final FocusNode? focusNode;
  final Function? customValidator;
  final Function? customOnChanged;
  final int? minLength;
  final String? minLengthErrorMessage;
  final int? maxLength;
  final String? maxLengthErrorMessage;

  const MyTextField({
    required this.controller,
    required this.labelText,
    required this.errorMessage,
    this.obscureText,
    this.keyboardType,
    this.verticalPadding,
    this.horizontalPadding,
    this.skipEmptyVerification,
    this.focusNode,
    this.customValidator,
    this.customOnChanged,
    this.minLength,
    this.minLengthErrorMessage,
    this.maxLength,
    this.maxLengthErrorMessage,
    super.key,
  });

  String? _validate(String? value, AppLocalizations localizations) {
    if (skipEmptyVerification == true) {
      return null;
    }
    if (value == null || value.isEmpty) {
      return errorMessage;
    }
    if (minLength != null && value.length < minLength!) {
      return minLengthErrorMessage ??
          localizations.minLengthNotReached(minLength!);
    }
    if (maxLength != null && value.length > maxLength!) {
      return maxLengthErrorMessage ??
          localizations.maxLengthExceeded(maxLength!);
    }
    if ((obscureText ?? false) && value.length < 6) {
      return localizations.passwordTooShort;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Get localization - return early if not available
    var localizations = AppLocalizations.of(context);
    if (localizations == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding ?? 5.0,
        vertical: verticalPadding ?? 0.0,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
        keyboardType: keyboardType ?? TextInputType.text,
        focusNode: focusNode,
        validator: (customValidator != null)
            ? (value) => customValidator!(value)
            : (value) => _validate(value, localizations),
        onChanged: (customOnChanged != null)
            ? (value) => customOnChanged!(value)
            : null,
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(25),
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          filled: true,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.onPrimary),
          hintText: labelText,
        ),
      ),
    );
  }
}
