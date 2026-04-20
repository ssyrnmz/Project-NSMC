import 'package:flutter/services.dart';

class InputFormat {
  //❕Shared formatter for input fields

  //▫️Individual Formatters:
  // Restrict by only allowing list of these characters
  static final onlyWholeNumbers = FilteringTextInputFormatter.digitsOnly;

  static final onlyLetters = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z\s]'),
  );

  static final onlyAlphaNumerics = FilteringTextInputFormatter.allow(
    RegExp(r'[a-zA-Z0-9\s]'),
  );

  // Restrict by disallowing immediately list of these characters
  static final noLeadingWhitespace = FilteringTextInputFormatter.deny(
    RegExp(r'^\s+'),
  );

  static final noWhitespace = FilteringTextInputFormatter.deny(RegExp(r'\s'));
}
