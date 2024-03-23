import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final bool obscureText;
  final String errorMessage;
  final Color textColor;

  const MyTextField({
    required this.controller,
    required this.labelText,
    required this.obscureText,
    required this.errorMessage,
    required this.textColor,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return errorMessage;
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
            color: textColor,
          ),
          hintText: labelText,
        ),
      ),
    );
  }
}
