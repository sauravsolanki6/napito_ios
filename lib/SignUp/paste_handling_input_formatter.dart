// paste_handling_input_formatter.dart
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PasteHandlingInputFormatter extends TextInputFormatter {
  final List<TextEditingController> otpControllers;

  PasteHandlingInputFormatter({required this.otpControllers});

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.length > 1) {
      String pasteText = newValue.text;

      // Update each controller with the corresponding character
      for (int i = 0; i < pasteText.length; i++) {
        if (i < otpControllers.length) {
          otpControllers[i].text = pasteText[i];
        }
      }

      // Move the cursor to the last position after pasting
      return TextEditingValue(
        text: pasteText.substring(0, 1),
        selection: TextSelection.collapsed(offset: pasteText.length),
      );
    }
    return newValue;
  }
}
