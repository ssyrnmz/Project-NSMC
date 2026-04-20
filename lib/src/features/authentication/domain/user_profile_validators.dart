class AccountValidators {
  //▫️Validator Functions:
  //🔹Register Validators (Specific messages for each error)
  // Check email's address if its valid
  static String? isEmailValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Email address is required";
    }

    final stringValue = value.trim();

    if (stringValue.length > 100) {
      return "Only email address within 100 characters are accepted";
    }

    if (!stringValue.contains('@')) {
      return "Must include @";
    }

    if (!stringValue.contains('.')) {
      return "Must include .";
    }

    if (!RegExp(r'^[^@]+@').hasMatch(stringValue)) {
      return "Must include the email's name before @";
    }

    if (!RegExp(r'@[^@]+\.[^@]{2,}$').hasMatch(stringValue)) {
      return "Must include the domain's name after @ (e.g. @gmail.com)";
    }

    return null;
  }

  // Check full name if its valid
  static String? isFullNameValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Full Name is required";
    }

    final stringValue = value.trim();

    if (stringValue.length > 100) {
      return "Only full name within 100 characters are accepted";
    }

    if (!RegExp(r'^[\p{L}\s]+$', unicode: true).hasMatch(stringValue)) {
      return "Full name can only contain letters and spaces";
    }

    if (stringValue.contains(RegExp(r'\s{2,}'))) {
      return "Remove extra spaces";
    }

    final words = stringValue.split(RegExp(r'\s+'));

    if (words.length < 2) {
      return "Enter at least a first name and a last name";
    }

    return null;
  }

  // Check password if it follows password rules
  static String? isPasswordValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Password is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 8 || stringValue.length > 64) {
      return "Must be between 8 to 64 characters only";
    }

    if (!stringValue.contains(RegExp(r'[A-Z]'))) {
      return "Must contain at least a uppercase character";
    }

    if (!stringValue.contains(RegExp(r'[a-z]'))) {
      return "Must contain at least a lowercase character";
    }

    if (!stringValue.contains(RegExp(r'[0-9]'))) {
      return "Must contain at least 1 numeric";
    }

    if (!stringValue.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return "Must contain at least 1 special character";
    }

    return null;
  }

  static String? isConfirmPasswordValid(String? value, String mainValue) {
    if (value == null || value.trim().isEmpty) {
      return "Confirm Password is required";
    }

    final stringValue = value.trim();
    final stringMainValue = mainValue.trim();

    if (stringMainValue != stringValue) {
      return "Password written are not the same";
    }

    return null;
  }

  /*
  // Check Doctor's specialization
  static String? isSpecializationValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Doctor's specialization is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 5 || stringValue.length > 100) {
      return "Doctor specialization must be between 5 and 100 characters";
    }

    if (!RegExp(r'^[A-Za-z -(),&]+$').hasMatch(stringValue)) {
      return "Only letters, spaces, and basic punctuation are allowed";
    }

    if (stringValue.contains(RegExp(r'\s{2,}'))) {
      return "Remove extra spaces";
    }

    return null;
  }
  */
}
