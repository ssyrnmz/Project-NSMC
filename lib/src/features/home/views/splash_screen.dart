import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../authentication/presentation/views/login_screen.dart';
import '../../../utils/ui/animations_transitions.dart';
import '../../../utils/ui/show_snackbar.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  //▫️Variable:
  final String emergencyNumber = '+6082311999'; // Emergency helpline

  //▫️Function:
  // Launch dialer to call normah emergency number
  Future<void> _callEmergency() async {
    final Uri launchUri = Uri(scheme: 'tel', path: emergencyNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      if (mounted) {
        showDismissableSnackBar(
          context: context,
          text:
              'Cannot open emergency dialer. Emergency Number: $emergencyNumber',
          timeDuration: Duration(minutes: 10),
        );
      }
    }
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Colors.white,
      body: Stack(
        fit: StackFit.expand,
        children: [
          //🔹Background image
          Image.asset('assets/images/NORMAH_BLUR_BG.png', fit: BoxFit.cover),
          SafeArea(
            child: Stack(
              children: [
                //🔹Logo & Title of Splash Screen (middle)
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRect(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          heightFactor: 0.9,
                          child: Image.asset(
                            'assets/images/bignblurlogo.png',
                            width: width * 0.42,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      SizedBox(height: 0),

                      Text(
                        "We Care Companion",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.045,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2E5231),
                          letterSpacing: 0.5,
                        ),
                      ),

                      SizedBox(height: height * 0.004),

                      Text(
                        "Bringing NORMAH to You",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: width * 0.035,
                          color: Colors.grey[700],
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                //🔹Emergency Helpline Button (top right)
                Positioned(
                  top: height * 0.025,
                  right: width * 0.04,
                  child: GestureDetector(
                    onTap: _callEmergency,
                    child: Container(
                      padding: const EdgeInsets.all(16), // more breathing space
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4CAF50),
                            Color(0xFF81C784),
                          ], // subtle gradient
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(
                              0.15,
                            ), // softer shadow
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 3.5),
                        child: const FaIcon(
                          FontAwesomeIcons.ambulance,
                          color: Colors.white,
                          size: 24.5, // slightly smaller to fit circle better
                        ),
                      ),
                    ),
                  ),
                ),

                //🔹Get Started Button (bottom)
                Positioned(
                  bottom: height * 0.05,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF2E7D32)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.25),
                            offset: const Offset(0, 6),
                            blurRadius: 14,
                          ),
                          BoxShadow(
                            color: Colors.greenAccent.withOpacity(0.15),
                            offset: const Offset(0, 0),
                            blurRadius: 30,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: width * 0.28,
                            vertical: height * 0.02,
                          ),
                        ),
                        onPressed: () {
                          Navigator.of(
                            context,
                          ).push(transitionAnimation(page: const LoginPage()));
                        },
                        child: Text(
                          "Get Started",
                          style: GoogleFonts.poppins(
                            fontSize: width * 0.045,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
