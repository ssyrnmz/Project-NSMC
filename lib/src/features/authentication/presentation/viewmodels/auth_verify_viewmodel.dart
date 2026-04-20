import 'package:flutter/material.dart';
import 'dart:async';

import '../../data/client_services/firebase_auth_repository.dart';
import '../../data/account_session.dart';
import '../../../../utils/data/results.dart';

class VerificationViewModel extends ChangeNotifier {
  VerificationViewModel({
    required AuthenticationRepository authRepository,
    required AccountSession accountSession,
  }) : _authRepository = authRepository,
       _accountSession = accountSession;

  //▫️Variables:
  // Repository
  final AuthenticationRepository _authRepository;
  final AccountSession _accountSession;

  // Main contents
  bool _canResendEmail = true;
  Timer? _timer;
  bool _isDisposed = false;

  //▫️Getters:
  bool get canResendEmail => _canResendEmail;

  //▫️Functions:
  // Called when VerificationScreen is shown.
  // Waits 2 seconds for Firebase to be ready, then auto-sends the first email.
  // Also starts the periodic timer to detect when user clicks the link.
  void startVerificationTimer() {
    _timer?.cancel();

    if (!_isDisposed) {
      // Auto-send first verification email after a short delay
      Future.delayed(const Duration(seconds: 2), () async {
        if (!_isDisposed) {
          await sendEmail();
        }
      });

      // Check every 10 seconds if user clicked the verification link
      _timer = Timer.periodic(
        const Duration(seconds: 10),
        (_) => checkEmailVerified(),
      );
    }
  }

  // Check if email has been verified — called every 10 seconds by the timer.
  // Calls AccountSession.refreshEmailVerification() which reloads the Firebase
  // user and calls notifyListeners() if verified — main.dart then routes to HomeScreen.
  Future<void> checkEmailVerified() async {
    await _accountSession.refreshEmailVerification();
    if (_accountSession.isEmailVerified) {
      _timer?.cancel();
    }
  }

  // Send verification email — retries once after 3 seconds if first attempt fails
  Future<Result<void>> sendEmail() async {
    try {
      Result<void> result = await _authRepository.emailVerify();

      // Retry once if first attempt fails (Firebase token may not be ready yet)
      if (result is Error) {
        await Future.delayed(const Duration(seconds: 3));
        if (!_isDisposed) {
          result = await _authRepository.emailVerify();
        }
      }

      if (result is Ok) {
        _canResendEmail = false;
        notifyListeners();

        // Re-enable resend after 1 minute cooldown
        Future.delayed(const Duration(minutes: 1), () {
          if (!_isDisposed) {
            _canResendEmail = true;
            notifyListeners();
          }
        });
      }
      return result;
    } catch (e) {
      debugPrint("Error sending verification email: $e");
      return Result.error(Exception(e));
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
