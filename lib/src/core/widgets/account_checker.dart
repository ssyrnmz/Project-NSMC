import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/features/home/views/home_screen.dart';
import 'package:provider/provider.dart';

import '../../features/authentication/data/account_session.dart';
import '../../features/home/views/splash_screen.dart';
import '../../config/constants/global_values.dart';
import '../../utils/ui/animations_transitions.dart';

// Account checker whenever screens after homepage is clicked
class AuthWrappper extends StatelessWidget {
  final UserRole accessRole;
  final Widget child;

  const AuthWrappper({
    required this.accessRole,
    required this.child,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    // Access user session
    final session = context.watch<AccountSession>();

    // Redirect to splash screen if user is not logged in
    if (!session.isLoggedIn || !session.isEmailVerified) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          transitionAnimation(page: const SplashScreen()),
          (route) => false,
        );
      });
      return const SizedBox.shrink(); // Show nothing while redirecting
    }

    // Redirect to home if user isn't supposed to be in the screen
    if (session.role != accessRole) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.of(context).pushAndRemoveUntil(
          transitionAnimation(page: const HomeScreen()),
          (route) => false,
        );
      });
      return const SizedBox.shrink();
    }

    return child;
  }
}
