import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_account_viewmodel.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_success_dialogue.dart';
import '../../../../utils/ui/show_snackbar.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  //▫️Variables
  late TextEditingController _emailController; // Email Input
  bool _emailSent = false; // Tracks if email was already sent once

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthenticationAccountViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FBF8),
        appBar: AppBar(
          backgroundColor: const Color(0xFFf9fafb),
          elevation: 0,
          surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
          centerTitle: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
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
                        const SizedBox(height: 80),

                        // ✉️ Email icon
                        SizedBox(
                          height: 200,
                          width: 200,
                          child: Image.asset(
                            'assets/images/forEV.png',
                            fit: BoxFit.contain,
                          ),
                        ),

                        // 🧾 Title
                        Transform.translate(
                          offset: const Offset(0, -20),
                          child: Text(
                            'Reset Password',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF6FBF73),
                              fontSize: 26,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),

                        Transform.translate(
                          offset: const Offset(0, -10),
                          child: TextField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              hintText: 'Enter Email',
                              hintStyle: GoogleFonts.poppins(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 15,
                                vertical: 16,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: const BorderSide(
                                  color: Color(0xffefefef),
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(11),
                                borderSide: const BorderSide(
                                  color: Color(0xFF629E5C),
                                  width: 2,
                                ),
                              ),
                              fillColor: Colors.white,
                              filled: true,
                            ),
                          ),
                        ),

                        /*
                        // 💬 Description
                        Transform.translate(
                          offset: const Offset(0, -15),
                          child: Text(
                            'We’ve sent a password reset link to your email. Please click the link to reset your password.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              color: Colors.grey[850],
                              fontSize: 15,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        */

                        // 📨 Sub-description
                        Transform.translate(
                          offset: const Offset(0, 10),
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

                        const SizedBox(height: 80),

                        // 💚 Send / Resend Email Button
                        ElevatedButton.icon(
                          icon: Icon(
                            _emailSent
                                ? Icons.refresh_rounded
                                : Icons.send_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6FBF73),
                            foregroundColor: Colors.white,
                            minimumSize: const Size(double.infinity, 50),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            shadowColor: const Color(
                              0xFF4D7C4A,
                            ).withOpacity(0.4),
                            elevation: 4,
                          ),
                          onPressed: () async {
                            if (_emailController.text.isNotEmpty &&
                                _emailController.text != '') {
                              final result = await vm.resetPassword(
                                _emailController.text.trim(),
                              );

                              switch (result) {
                                case Ok<void>():
                                  if (context.mounted) {
                                    setState(() => _emailSent = true);
                                    showSuccessDialog(
                                      context: context,
                                      title: _emailSent
                                          ? 'Email Resent!'
                                          : 'Email Has Been Successfully Found!',
                                      message:
                                          'The password reset email has been sent to your email account. Click the link provided in the email to reset your password.',
                                      buttonText: "Ok",
                                    );
                                  }
                                case Error<void>():
                                  if (context.mounted) {
                                    showSnackBar(
                                      context: context,
                                      text:
                                          'Failed to send password reset email. Please check if you entered the correct email and try again.',
                                      color: Colors.red[900],
                                    );
                                  }
                              }
                            }
                          },
                          label: Text(
                            _emailSent ? 'Resend Email' : 'Send Email',
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
      ),
    );
  }
}
