import 'package:flutter/services.dart';

/// Reusable input formatters and validators for consistent form handling.

/// Formatter: Allow only digits (0-9).
final digitsOnly = FilteringTextInputFormatter.digitsOnly;

/// Formatter: Allow only letters (a-z A-Z) and spaces for names.
final nameFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[a-zA-Z\s]'),
  replacementString: '',
);

/// Formatter: Phone digits only, length limited.
TextInputFormatter phoneFormatter({int maxLength = 10}) {
  return TextInputFormatter.withFunction((oldValue, newValue) {
    String newText = newValue.text;
    // Digits only
    newText = newText.replaceAll(RegExp(r'[^0-9]'), '');
    // Limit length
    if (newText.length > maxLength) {
      newText = newText.substring(0, maxLength);
    }
    // Preserve cursor position
    final newLength = newText.length;
    final newOffset = newValue.selection.baseOffset.clamp(0, newLength);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newOffset),
      composing: TextRange.empty,
    );
  });
}

/// Formatter: Price/money - digits, one '.', up to 2 decimals (e.g., 1234.56).
final priceFormatter = TextInputFormatter.withFunction((oldValue, newValue) {
  final regExp = RegExp(r'^\d*\.?\d{0,2}$');
  return regExp.hasMatch(newValue.text) ? newValue : oldValue;
});

/// Formatter: Email - basic pre-filter (alphanumeric + common chars).
final emailFormatter = FilteringTextInputFormatter.allow(
  RegExp(r'[a-zA-Z0-9._%+-@]'),
);

/// Validator: Email regex check.
String? emailValidator(String? value) {
  if (value == null || value.isEmpty) return 'Email is required';
  final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  if (!emailRegExp.hasMatch(value)) {
    return 'Enter valid email';
  }
  return null;
}

/// Validator: Required non-empty string.
String? requiredValidator(String? value, [String field = 'This field']) {
  if (value == null || value.trim().isEmpty) {
    return '$field is required';
  }
  return null;
}

/// Validator: Password min 8 chars, 1 uppercase, 1 number.
String? passwordValidator(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  if (value.length < 8) return 'Password must be at least 8 characters';
  if (!RegExp(r'(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
    return 'Password needs 1 uppercase & 1 number';
  }
  return null;
}

/// Validator: Pincode 6 digits.
String? pincodeValidator(String? value) {
  if (value == null || value.isEmpty) return 'Pincode required';
  if (!RegExp(r'^\d{6}$').hasMatch(value)) {
    return 'Enter valid 6-digit pincode';
  }
  return null;
}

