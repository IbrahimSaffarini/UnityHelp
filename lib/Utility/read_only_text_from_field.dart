import 'package:flutter/material.dart';

class ReadOnlyTextFormField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextStyle textStyle;
  final OutlineInputBorder borderStyle;

  ReadOnlyTextFormField({super.key, 
    required this.controller,
    required this.label,
    this.textStyle = const TextStyle(fontSize: 20, color: Colors.white),
    OutlineInputBorder? borderStyle,
  }) : borderStyle = borderStyle ?? OutlineInputBorder(
      borderSide: const BorderSide(color: Colors.white),
      borderRadius: BorderRadius.circular(15),
  );

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      style: textStyle,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: textStyle,
        border: borderStyle,
        enabledBorder: borderStyle,
        focusedBorder: borderStyle.copyWith(
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
