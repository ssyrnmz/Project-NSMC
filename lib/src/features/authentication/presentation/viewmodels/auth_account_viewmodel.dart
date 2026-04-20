import 'package:flutter/material.dart';

import '../../data/client_services/firebase_auth_repository.dart';
import '../../data/client_services/admin_service.dart';
import '../../data/client_services/user_service.dart';
import '../../domain/session.dart';
import '../../domain/user.dart';
import '../../domain/admin.dart';
import '../../../../utils/data/results.dart';

class AuthenticationAccountViewModel extends ChangeNotifier {
  AuthenticationAccountViewModel({
    required AuthenticationRepository authRepository,
    required UserAccountService userService,
    required AdminAccountService adminService,
  }) : _authRepository = authRepository,
       _userService = userService,
       _adminService = adminService;

  //▫️Variables:
  final AuthenticationRepository _authRepository;
  final UserAccountService _userService;
  final AdminAccountService _adminService;

  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters:
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  // Login function for admin and user
  Future<Result> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final loginResult = await _authRepository.loginWithEmail(email, password);
      switch (loginResult) {
        case Ok<String>():
          debugPrint("Get user through Firebase: ${loginResult.value}");
        case Error<String>():
          _errorMessage =
              "The system had an issue finding user in the system. Please make sure you already have an account, entered accurate information and try again.";
          debugPrint("Failed to get user through Firebase: ${loginResult.error}");
      }
      return loginResult;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register function (Users only)
  Future<Result> userSignup(User user, String password) async {
    _authRepository.ignoreSync = true;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final fbSignupResult = await _authRepository.signupWithEmail(user.email, password);
      switch (fbSignupResult) {
        case Ok<String>():
          debugPrint("Create user for Firebase: \${fbSignupResult.value}");
        case Error<String>():
          _errorMessage = "Failed to create account. The email may already be in use.";
          debugPrint("Failed to create user for Firebase: \${fbSignupResult.error}");
          return fbSignupResult;
      }
      // Step 2: Longer delay to ensure Firebase token is ready
      await Future.delayed(const Duration(milliseconds: 800));
      final newUser = User(
        id: fbSignupResult.value,
        fullName: user.fullName,
        email: user.email,
        icNumber: user.icNumber,
        phoneNumber: user.phoneNumber,
        nationality: user.nationality,
        gender: user.gender,
        birthDate: user.birthDate,
        age: user.age,
        occupation: user.occupation,
        race: user.race,
        religion: user.religion,
        homeAddress: user.homeAddress,
        postCode: user.postCode,
        city: user.city,
        state: user.state,
        country: user.country,
        createdAt: user.createdAt,
        signupMethod: user.signupMethod,
        unactive: user.unactive,
        updatedAt: user.updatedAt,
      );
      final dataSignupResult = await _userService.addUserDetails(newUser);
      switch (dataSignupResult) {
        case Ok<User>():
          debugPrint("Create user for database: \${dataSignupResult.value}");
        case Error<User>():
          _errorMessage =
              "Account was created but your details could not be saved. Please contact support.";
          debugPrint("Failed to create user for database: \${dataSignupResult.error}");
          return dataSignupResult;
      }
      // Step 4: Send verification email before releasing ignoreSync
      await _authRepository.emailVerify();
      debugPrint("Verification email sent");
      return dataSignupResult;
    } finally {
      _authRepository.ignoreSync = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Register function for admins only
  Future<Result> adminSignup(
    Admin admin,
    String password,
    AdminSession currentSession,
  ) async {
    _errorMessage = null;

    _authRepository.ignoreSync = true;
    _isLoading = true;
    notifyListeners();

    try {
      final fbSignupResult = await _authRepository.signupWithEmailSecondary(admin.email, password);
      switch (fbSignupResult) {
        case Ok<String>():
          debugPrint("Create admin for Firebase: ${fbSignupResult.value}");
        case Error<String>():
          _errorMessage = 'Failed to create the admin account. The email may already be in use.';
          debugPrint("Failed to create admin for Firebase: ${fbSignupResult.error}");
          return fbSignupResult;
      }

      final newAdmin = Admin(
        id: fbSignupResult.value,
        name: admin.name,
        email: admin.email,
        role: admin.role,
        unactive: false,
        updatedAt: DateTime.now(),
      );

      final dataSignupResult = await _adminService.addAdmin(newAdmin);
      switch (dataSignupResult) {
        case Ok<Admin>():
          debugPrint("Create admin for database: ${dataSignupResult.value.name}");
        case Error<Admin>():
          _errorMessage = 'Admin account was created but could not be saved to the database. Please contact IT support.';
          debugPrint("Failed to create admin for database: ${dataSignupResult.error}");
      }

      // Step 4: Send verification email before releasing ignoreSync
      await _authRepository.emailVerify();
      debugPrint("Verification email sent");
      return dataSignupResult;
    } finally {
      _authRepository.ignoreSync = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update account details (Users only)
  Future<Result> userUpdate(User user) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final newUser = User(
        id: user.id,
        fullName: user.fullName,
        email: user.email,
        icNumber: user.icNumber,
        phoneNumber: user.phoneNumber,
        nationality: user.nationality,
        gender: user.gender,
        birthDate: user.birthDate,
        age: user.age,
        occupation: user.occupation,
        race: user.race,
        religion: user.religion,
        homeAddress: user.homeAddress,
        postCode: user.postCode,
        city: user.city,
        state: user.state,
        country: user.country,
        createdAt: user.createdAt,
        signupMethod: user.signupMethod,
        unactive: user.unactive,
        updatedAt: user.updatedAt,
      );
      final dataSignupResult = await _userService.updateUserDetails(newUser);
      switch (dataSignupResult) {
        case Ok<User>():
          debugPrint("Update user for database: ${dataSignupResult.value}");
        case Error<User>():
          debugPrint("Failed to update user for database: ${dataSignupResult.error}");
      }
      // Step 4: Send verification email before releasing ignoreSync
      await _authRepository.emailVerify();
      debugPrint("Verification email sent");
      return dataSignupResult;
    } catch (e) {
      debugPrint("Change Info Result: $e");
      return Result.error(Exception(e));
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Reset account's password
  Future<Result> resetPassword(String email) async {
    try {
      final result = await _authRepository.forgotPassword(email);
      switch (result) {
        case Ok<String>(): debugPrint("Reset Password Result: ${result.value}");
        case Error<String>(): debugPrint("Reset Password Result: ${result.error}");
      }
      return result;
    } catch (e) {
      debugPrint("Reset Password Result: $e");
      return Result.error(Exception(e));
    }
  }

  // Logout account from the application
  Future<Result> logout() async {
    try {
      final result = await _authRepository.logOut();
      switch (result) {
        case Ok<String>(): debugPrint("Logout Result: ${result.value}");
        case Error<String>(): debugPrint("Logout Result: ${result.error}");
      }
      return result;
    } catch (e) {
      debugPrint("Logout Result: $e");
      return Result.error(Exception(e));
    }
  }
}
