import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

import '../../../../utils/data/results.dart';

class AuthenticationRepository {
  //▫️Variables:
  final FirebaseAuth _authInstance = FirebaseAuth.instance; // Firebase itself
  bool ignoreSync = false;

  //▫️Functions:
  // Listener whenever there are any changes to Firebase
  Stream<User?> get userChanges => _authInstance.userChanges();

  // Get current user
  User? get currentUser => _authInstance.currentUser;

  // Create a USER account — signs in as the new user on the primary instance.
  // Used during user registration (no one is currently logged in).
  Future<Result<String>> signupWithEmail(String email, String password) async {
    try {
      final userCreds = await _authInstance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCreds.user?.uid;

      if (uid != null) {
        return Result.ok(uid);
      } else {
        return Result.error(Exception("User created, but no UID returned."));
      }
    } on FirebaseAuthException catch (error) {
      return Result.error(Exception('Invalid Firebase Response: $error'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  // Create an ADMIN account — uses a secondary FirebaseApp instance so the
  // currently logged-in admin session is NOT disrupted.
  // Used during admin creation from the Admin Management screen.
  Future<Result<String>> signupWithEmailSecondary(String email, String password) async {
    FirebaseApp? secondaryApp;
    try {
      secondaryApp = await Firebase.initializeApp(
        name: 'secondary_signup_\${DateTime.now().millisecondsSinceEpoch}',
        options: _authInstance.app.options,
      );

      final secondaryAuth = FirebaseAuth.instanceFor(app: secondaryApp);

      final userCreds = await secondaryAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = userCreds.user?.uid;

      await secondaryAuth.signOut();

      if (uid != null) {
        return Result.ok(uid);
      } else {
        return Result.error(Exception("User created, but no UID returned."));
      }
    } on FirebaseAuthException catch (error) {
      return Result.error(Exception('Invalid Firebase Response: \$error'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    } finally {
      await secondaryApp?.delete();
    }
  }

  // Authenticate user account with Firebase
  Future<Result<String>> loginWithEmail(String email, String password) async {
    try {
      final userCreds = await _authInstance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = userCreds.user?.uid;

      if (uid != null) {
        return Result.ok(userCreds.user!.uid);
      } else {
        return Result.error(Exception("User login, but no UID returned."));
      }
    } on FirebaseAuthException catch (error) {
      return Result.error(Exception('Invalid Firebase Response: $error'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  // Disconnect user account from Firebase and application
  Future<Result<String>> logOut() async {
    try {
      await _authInstance.signOut();
      return Result.ok('Success');
    } on FirebaseAuthException catch (error) {
      return Result.error(Exception('Invalid Firebase Response: $error'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  // Check and send Forgot Password to user's email
  Future<Result<String>> forgotPassword(String email) async {
    try {
      await _authInstance.sendPasswordResetEmail(email: email);
      return Result.ok('Success');
    } on FirebaseAuthException catch (error) {
      return Result.error(Exception('Invalid Firebase Response: $error'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  // Check and send Email Verification to user's email
  Future<Result<String>> emailVerify() async {
    try {
      final user = _authInstance.currentUser;

      if (user == null) {
        return Result.error(Exception('No current user.'));
      }

      await user.sendEmailVerification();
      return Result.ok('Success');
    } on FirebaseAuthException catch (error) {
      return Result.error(Exception('Invalid Firebase Response: $error'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }

  // Check if the current user's email is verified
  Future<Result<bool>> isEmailVerified() async {
    try {
      final user = _authInstance.currentUser;

      if (user == null) {
        return Result.error(Exception('No current user.'));
      }

      // Reload to get the latest status
      await user.reload();

      final refreshedUser = _authInstance.currentUser;

      return Result.ok(refreshedUser?.emailVerified ?? false);
    } on FirebaseAuthException catch (error) {
      return Result.error(Exception('Invalid Firebase Response: $error'));
    } catch (e) {
      return Result.error(Exception(e.toString()));
    }
  }
}
