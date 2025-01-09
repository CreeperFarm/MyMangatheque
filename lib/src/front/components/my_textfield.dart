import 'package:flutter/material.dart';

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
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding ?? 5.0, vertical: verticalPadding ?? 0.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText ?? false,
        keyboardType: keyboardType ?? TextInputType.text,
        focusNode: focusNode,
        validator: (customValidator != null)
            ? (value) => customValidator!(value)
            : (value) {
                if (value == null || value.isEmpty) {
                  return errorMessage;
                } else if (skipEmptyVerification != null && skipEmptyVerification!) {
                  return null;
                } else if (value.length < 6 && obscureText!) {
                  return "Votre mot de passe doit contenir au moins 6 caractères!";
                } else {
                  return null;
                }
              },
        onChanged: (customOnChanged != null) ? (value) => customOnChanged!(value) : null,
        decoration: InputDecoration(
          errorBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.error,
            ),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          filled: true,
          labelStyle: TextStyle(
            color: Theme.of(context).colorScheme.onPrimary,
          ),
          hintText: labelText,
        ),
      ),
    );
  }
}
