class DoctorValidators {
  // Check Doctor's Name
  static String? isNameValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Doctor's full stringValue is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 5 || stringValue.length > 100) {
      return "Must be between 5 and 100 characters";
    }

    if (!stringValue.contains('Dr. ')) {
      return "Must include 'Dr. '";
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

  // Check Doctor's qualifications
  static String? isQualificationsValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Doctor's qualifications is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 5 || stringValue.length > 255) {
      return "Must be between 5 and 255 characters";
    }

    if (!RegExp(r'^[A-Za-z -(),]+$').hasMatch(stringValue)) {
      return "Only letters, spaces, and basic punctuation are allowed";
    }

    if (stringValue.contains(RegExp(r'\s{2,}'))) {
      return "Remove extra spaces";
    }

    return null;
  }

  // Check Doctor's specialization
  static String? isSpecializationValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Doctor's specialization is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 5 || stringValue.length > 100) {
      return "Must be between 5 and 100 characters";
    }

    if (!RegExp(r'^[A-Za-z -(),&]+$').hasMatch(stringValue)) {
      return "Only letters, spaces, and basic punctuation are allowed";
    }

    if (stringValue.contains(RegExp(r'\s{2,}'))) {
      return "Remove extra spaces";
    }

    return null;
  }
}
