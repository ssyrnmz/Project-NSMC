class HealthScreeningValidators {
  // Check Package's Name
  static String? isNameValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Package's name is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 5 || stringValue.length > 100) {
      return "Must be between 5 and 100 characters";
    }

    return null;
  }

  static String? isPriceValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Package's price is required";
    }

    return null;
  }

  // Check Package's qualifications
  static String? isDescriptionValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Package's description is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 5 || stringValue.length > 1000) {
      return "Must be between 5 and 1000 characters";
    }

    return null;
  }

  // Check Package's specialization
  static String? isIncludedValid(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Package's included is required";
    }

    final stringValue = value.trim();

    if (stringValue.length < 2 || stringValue.length > 300) {
      return "Must be between 2 and 300 characters";
    }

    if (stringValue.contains(RegExp(r'\s{2,}'))) {
      return "Remove extra spaces";
    }

    return null;
  }
}
