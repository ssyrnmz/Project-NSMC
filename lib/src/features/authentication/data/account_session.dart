import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'client_services/firebase_auth_repository.dart';
import 'client_services/admin_service.dart';
import 'client_services/user_service.dart';
import '../domain/session.dart';
import '../domain/user.dart' as patient;
import '../domain/admin.dart';
import '../../../utils/data/results.dart';
import '../../../config/constants/global_values.dart';

class AccountSession extends ChangeNotifier {
  //▫️Constructor:
  AccountSession({
    required AuthenticationRepository authRepository,
    required AdminAccountService adminService,
    required UserAccountService userService,
  }) : _authRepository = authRepository,
       _adminService = adminService,
       _userService = userService {
    _authSubscription = _authRepository.userChanges.listen((User? user) async {
      // If ignoreSync is true, skip the synchronization process
      if (_authRepository.ignoreSync) return;

      // Check if any changes to current account
      bool isSameUser = user?.uid == _lastUid;
      bool isSameVerification = user?.emailVerified == _lastEmailVerified;

      // Return if account and verification status didn't change
      if (isSameUser && isSameVerification && _isInitialized) {
        return;
      }

      // Update tracking variables
      _lastUid = user?.uid;
      _lastEmailVerified = user?.emailVerified;

      // Check if there's current user
      if (user == null) {
        _session = null;
        _isEmailVerified = false;
        // Create session based on current user
      } else {
        final Result<dynamic> result = await _checkType(user.uid);

        if (result is Ok) {
          final value = result.value; // This is the dynamic content

          if (value is patient.User) {
            // Users must verify their email before accessing the app
            _isEmailVerified = user.emailVerified;
            _session = UserSession(value);
          } else if (value is Admin) {
            // Admins do not need email verification — always grant access
            _isEmailVerified = true;
            _session = AdminSession(value);
          } else {
            // Handle unexpected type inside Ok
            await _authRepository.logOut();
          }
        } else {
          // Handle Result.error
          await _authRepository.logOut();
        }
      }
      _isInitialized = true;
      notifyListeners();
    });
  }

  //▫️Variable:
  // Client services
  final AuthenticationRepository _authRepository;
  final AdminAccountService _adminService;
  final UserAccountService _userService;

  StreamSubscription<User?>?
  _authSubscription; // Listener to user changes (Firebase account changes)

  // Main data/states
  bool _isInitialized = false;
  bool _isEmailVerified = false;
  SessionData? _session; // The session itself

  // Tracker data
  String? _lastUid;
  bool? _lastEmailVerified;

  //▫️Functions:
  // Session Getter
  SessionData? get session => _session;

  UserRole get role {
    if (_session is AdminSession) return UserRole.admin;
    if (_session is UserSession) return UserRole.user;
    return UserRole.all;
  }

  /// Returns the specific admin role string (e.g. 'Admin', 'Receptionist', 'SuperAdmin')
  /// Returns null if not logged in as admin.
  String? get adminRole {
    final sess = _session;
    if (sess is AdminSession) return sess.adminAccount.role;
    return null;
  }

  /// Returns true if the logged-in admin can access non-appointment features
  bool get isFullAdmin {
    final role = adminRole;
    return role == 'SuperAdmin' || role == 'Admin';
  }

  // Session Checker
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _session != null;
  bool get isEmailVerified => _isEmailVerified;

  /// Force-checks Firebase email verification and updates session.
  /// Called by VerificationViewModel timer every 10 seconds.
  /// When verified, notifyListeners() triggers main.dart to route to HomeScreen.
  Future<void> refreshEmailVerification() async {
    final user = _authRepository.currentUser;
    if (user == null) return;
    try {
      await user.reload();
      final refreshed = _authRepository.currentUser;
      final verified = refreshed?.emailVerified ?? false;
      if (verified && !_isEmailVerified) {
        _isEmailVerified = true;
        notifyListeners();
        debugPrint('[AccountSession] Email verified — routing to HomeScreen');
      }
    } catch (_) {}
  }

  // Session Setter (For User only)
  void changeUserDetail(patient.User session) {
    _session = UserSession(session);
    notifyListeners();
  }

  // Check and obtain user type if any data is available
  Future<Result> _checkType(String id) async {
    final userResult = await _userService.getUser(id, null);
    if (userResult is Ok<patient.User>) {
      return Result.ok(userResult.value);
    }

    final adminResult = await _adminService.getAdmin(id);
    if (adminResult is Ok<Admin>) {
      return Result.ok(adminResult.value);
    }

    return Result.error(Exception('No authenticated user.'));
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
