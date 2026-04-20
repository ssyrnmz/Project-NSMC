import 'package:flutter/material.dart';

import '../../authentication/data/account_session.dart';
import '../../authentication/domain/session.dart';
import '../../profile/data/emergency_contact_service.dart';
import '../../profile/domain/emergency_contact.dart';
import '../../../utils/data/results.dart';

class EmergencyContactViewModel extends ChangeNotifier {
  EmergencyContactViewModel({
    required EmergencyContactService contactService,
    required AccountSession accountSession,
  }) : _contactService = contactService,
       _accountSession = accountSession;

  //▫️Variables:
  // Repositories
  final EmergencyContactService _contactService;
  final AccountSession _accountSession;

  // Repository data
  EmergencyContact? _contact;

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters:
  EmergencyContact? get contact => _contact;
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  // Load patient's emergency contact based on their ID
  Future<Result> load(String? id) async {
    late final String userUID;
    final session = _accountSession.session;
    _errorMessage = null;

    // Receptionist cannot access patient emergency contacts
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow viewing patient contact information.";
      return Result.error(Exception(_errorMessage));
    }

    // Cancel if the user isn't an admin
    if (session is AdminSession && id != null) {
      userUID = id;
    } else if (session is UserSession) {
      userUID = session.userAccount.id;
    } else {
      _errorMessage =
          "There's an issue where there is no user to check emergency contact of. Please try again.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _contactService.getEmergencyContact(userUID, null);

      switch (result) {
        case Ok<EmergencyContact?>():
          _contact = result.value;
          debugPrint("Get emergency contact: ${result.value}");
        case Error<EmergencyContact?>():
          _errorMessage =
              "There's an issue in fetching user's contact data. Try again later.";
          debugPrint("Failed to get users: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create emergency contact based on input
  Future<Result> addContact(EmergencyContact contact) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! UserSession) {
      _errorMessage =
          "Only users are allowed to add their emergency contact information";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _contactService.addEmergencyContact(contact);
      switch (result) {
        case Ok<EmergencyContact>():
          debugPrint("Add user's emergency contact: ${result.value}");
        case Error<EmergencyContact>():
          _errorMessage =
              "There's an issue when adding your emergency contact's info. Please try again later.";
          debugPrint("Failed to add user's emergency contact: ${result.error}");
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user's emergency contact's detail with updated details
  Future<Result> editContact(EmergencyContact contact) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! UserSession) {
      _errorMessage =
          "Only users are allowed to edit their emergency contact information";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      final result = await _contactService.editEmergencyContact(contact);
      switch (result) {
        case Ok<EmergencyContact>():
          debugPrint("Updated user's emergency contact: ${result.value}");
        case Error<EmergencyContact>():
          _errorMessage =
              "There's an issue when editting your emergency contact's info. Please try again later.";
          debugPrint(
            "Failed to update user's emergency contact: ${result.error}",
          );
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
