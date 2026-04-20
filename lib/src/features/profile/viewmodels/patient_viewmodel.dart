import 'package:flutter/material.dart';

import '../../authentication/data/repositories/user_repository.dart';
import '../../authentication/data/account_session.dart';
import '../../authentication/domain/session.dart';
import '../../authentication/domain/user.dart';
import '../../../utils/data/results.dart';
import '../../../utils/ui/display_formatters.dart';

class PatientViewModel extends ChangeNotifier {
  PatientViewModel({
    required UserRepository userRepository,
    required AccountSession accountSession,
  }) : _userRepository = userRepository,
       _accountSession = accountSession;

  //▫️Variables:
  // Repositories
  final UserRepository _userRepository;
  final AccountSession _accountSession;

  // Repository datas
  List<User> _users = [];
  final Map<String, String> _searchList = {};
  Map<String, User> _usersMap = {}; // Find users fast

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters:
  List<User> get patients => _users;
  Map<String, String> get searchList => _searchList;
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  // Get the patient's details based on their ID
  User? getPatient(String id) {
    return _usersMap[id];
  }

  //▫️Functions:
  // Load data into lists
  Future<Result> load() async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to view users.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    try {
      // Load users/patients only
      final userResult = await _userRepository.getUsers();

      switch (userResult) {
        case Ok<List<User>>():
          _users = userResult.value;
          _usersMap = {for (var u in _users) u.id: u};
          sortData();
          createSearchList();
          debugPrint("Get users: ${userResult.value}");
        case Error<List<User>>():
          _errorMessage =
              "There's an issue in fetching user's data. Try again later.";
          debugPrint("Failed to get users: ${userResult.error}");
      }

      return userResult;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🚧 Deactivate a user, likely needs to connect with (WIP)
  /*
  Future<Result> deleteUser(User patient) async {
    final session = _accountSession.session;
    _errorMessage = null;

    // Cancel if the user isn't an admin
    if (session is! AdminSession) {
      _errorMessage =
          "Only users with higher access are allowed to delete medical record.";
      return Result.error(Exception(_errorMessage));
    }
    // Receptionist role cannot modify this data
    if (session is AdminSession &&
        session.adminAccount.role == 'Receptionist') {
      _errorMessage =
          "Your access level does not allow managing this information.";
      return Result.error(Exception(_errorMessage));
    }

    _isLoading = true;
    notifyListeners();

    User deletePatient = User(
      id: patient.id,
      fullName: patient.fullName,
      email: patient.email,
      icNumber: patient.icNumber,
      phoneNumber: patient.phoneNumber,
      nationality: patient.nationality,
      gender: patient.gender,
      birthDate: patient.birthDate,
      age: patient.age,
      occupation: patient.occupation,
      race: patient.race,
      religion: patient.religion,
      homeAddress: patient.homeAddress,
      postCode: patient.postCode,
      city: patient.city,
      state: patient.state,
      country: patient.country,
      createdAt: patient.createdAt,
      signupMethod: patient.signupMethod,
      unactive: true,
      updatedAt: patient.updatedAt,
    );

    try {
      final result = await _userRepository.editUser(deletePatient);
      switch (result) {
        case Ok<User>():
          debugPrint('Deactivate user: ${result.value}');
        case Error<User>():
          "Unable to deactive ${patient.unactive}'s account. Please try again or check for issues surrounding application.";
          debugPrint('Failed to deactivate: ${result.error}');
      }

      return result;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  */

  // Create the search list
  void createSearchList() {
    _searchList.clear();
    _searchList.addAll(
      Map.fromEntries(
        _users.map(
          (u) => MapEntry(
            "${DisplayFormat().shortUserName(u.fullName)} (${u.icNumber})",
            u.id,
          ),
        ),
      ),
    );
  }

  // Sort repository datas whenever cached
  void sortData() {
    _users.sort(
      (a, b) => a.fullName.toLowerCase().compareTo(b.fullName.toLowerCase()),
    );
  }
}
