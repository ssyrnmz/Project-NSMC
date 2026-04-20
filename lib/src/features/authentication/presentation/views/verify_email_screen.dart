import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/utils/ui/show_snackbar.dart';
import 'package:flutter_application_2/src/utils/ui/show_success_dialogue.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_verify_viewmodel.dart';
import '../viewmodels/auth_account_viewmodel.dart';
import '../../../../utils/data/results.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  bool _emailSent = false; // Tracks if email was sent at least once

  //▫️State initialization:
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<VerificationViewModel>();
      vm.startVerificationTimer();
    });
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<VerificationViewModel>();
    final vmAccount = context.read<AuthenticationAccountViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBF8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9fafb),
        elevation: 0,
        surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
          onPressed: () async {
            final result = await vmAccount.logout();

            if (!context.mounted) return;

            if (result is Error) {
              showSnackBar(
                context: context,
                text: "An unknown error occured. Please try again.",
                color: Colors.red[900],
              );
            }

            // Auto change to login screen when user logs out
          },
        ),
        title: Text(
          'Go Back',
          textAlign: TextAlign.start,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E1E1E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE6E6E6), height: 1),
        ),
      ),
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 255, 255, 255),
                Color(0xFFF4FBFF),
                Color.fromARGB(255, 255, 255, 255),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // ✉️ Email icon
                      SizedBox(
                        height: 300,
                        width: 300,
                        child: Image.asset(
                          'assets/images/forEV.png',
                          fit: BoxFit.contain,
                        ),
                      ),

                      // 🧾 Title
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Text(
                          'Email Verification',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: const Color(0xFF6FBF73),
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.4,
                          ),
                        ),
                      ),

                      // 💬 Description
                      Transform.translate(
                        offset: const Offset(0, -18),
                        child: Text(
                          'A verification email has been sent to your email address. Please check your inbox and click the link to verify your account.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[850],
                            fontSize: 15,
                            height: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                      // 📨 Sub-description
                      Transform.translate(
                        offset: const Offset(0, 25),
                        child: Text(
                          'Didn’t get it? Check your spam folder or tap the button below to resend.',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
                            fontSize: 12.5,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 40),

                      // 💚 Send / Resend Verification Button
                      ElevatedButton.icon(
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: vm.canResendEmail
                              ? const Color(0xFF6FBF73)
                              : const Color(0xFFB5CDB5),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 45,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          shadowColor: const Color(0xFF4D7C4A).withOpacity(0.4),
                          elevation: 4,
                        ),
                        onPressed: vm.canResendEmail
                            ? () async {
                                final result = await vm.sendEmail();

                                switch (result) {
                                  case Ok<void>():
                                    setState(() => _emailSent = true);
                                    showSuccessDialog(
                                      context: context,
                                      title: "Verification Email Successfully Sent!",
                                      message:
                                          "The verification email has been sent to your email account. Please click the link inside the email to verify your account.",
                                      buttonText: "Ok",
                                    );
                                  case Error<void>():
                                    showSnackBar(
                                      context: context,
                                      text:
                                          "Could not send email. Please wait a moment and try again.",
                                      color: Colors.orange[800],
                                    );
                                }
                              }
                            : null,
                        label: Text(
                          _emailSent
                              ? 'Resend Verification Email'
                              : 'Resend Verification Email',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
