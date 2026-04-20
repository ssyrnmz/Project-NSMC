// Info: Main/Index/Starting Screen.
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'src/config/firebase_options.dart';
import 'src/config/provider_dependencies.dart';
import 'src/features/authentication/data/account_session.dart';
import 'src/features/authentication/presentation/views/verify_email_screen.dart';
import 'src/features/home/views/home_screen.dart';
import 'src/features/home/views/initialization_screen.dart';
import 'src/features/home/views/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // i. Connect Firebase to Flutter so that Firebase Products can work for this app
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MultiProvider(providers: mainProviders, child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 2. Define the main theme
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          primary: const Color(0xFF629E5C),
          surface: Colors.white,
          onSurface: Colors.black,
        ),

        // Custom AppBar theme
        appBarTheme: AppBarTheme(
          backgroundColor: const Color(0xFFf7f7f7), // Light grey color
          surfaceTintColor:
              Colors.transparent, // Prevents color change on scroll
          scrolledUnderElevation: 0, // Removes shadow when scrolling
          elevation: 0, // No shadow
          shadowColor: Colors.transparent, // No shadow
          iconTheme: const IconThemeData(color: Color(0xFF4D7C4A)),
          titleTextStyle: GoogleFonts.poppins(
            color: const Color(0xFF4D7C4A),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          toolbarHeight: kToolbarHeight, // Standard height
          centerTitle: true, // Centers the title
        ),
      ),

      home: ListenableBuilder(
        listenable: session,
        builder: (context, _) {
          // Initialize Screen (App not yet initialized)
          if (!session.isInitialized) {
            return const InitializationScreen();
          }

          // Splash Screen (User don't have account OR User have not logged in yet)
          if (!session.isLoggedIn) {
            return const SplashScreen();
          }

          // Verify Screen (User have not verified their email)
          if (!session.isEmailVerified) {
            return const VerificationScreen();
          }

          // Home Screen (All criterias are met)
          return const HomeScreen();
        },
      ),
    );
  }
}
