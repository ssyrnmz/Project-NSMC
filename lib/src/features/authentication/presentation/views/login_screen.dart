import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'register_screen.dart';
import 'forgot_password_screen.dart';
import '../viewmodels/auth_account_viewmodel.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/input_formatters.dart';
import '../../../../utils/ui/show_snackbar.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>(); // Form key
  bool _isLoading = false;
  bool _obscurePassword = true; // Toggle for password visibility

  // Form inputs (Email & Password)
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthenticationAccountViewModel>();
    final size = MediaQuery.of(context).size;
    final height = size.height;
    final width = size.width;

    return LoadingOverlay(
      isLoading: vm.isLoading || _isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        // 🔒 prevents layout from moving up when keyboard appears
        resizeToAvoidBottomInset: false,
        body: Form(
          key: _formKey,
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                //🔹Background Image
                SafeArea(
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor:
                          0.999, // crops top 0.5% of what's inside SafeArea
                      child: SizedBox(
                        height: height * 0.4,
                        width: double.infinity,
                        child: Image.asset(
                          'assets/images/testing_login5.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),

                //🔹Main White Container (fixed position)
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: height * 0.72, // still responsive
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFFFFFFF),
                          Color(0xFFFFFFFF), // soft greenish
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(45),
                        topRight: Radius.circular(45),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, -1),
                        ),
                      ],
                    ),

                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: width * 0.08,
                        vertical: height * 0.04,
                      ),

                      //🔹Main body of the screen
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          return SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxHeight: height * 0.75,
                              ),
                              child: IntrinsicHeight(
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    //🔹Small logo
                                    Transform.translate(
                                      offset: const Offset(
                                        0,
                                        -30,
                                      ), // negative Y to move up
                                      child: SizedBox(
                                        width: width * 0.20,
                                        child: FittedBox(
                                          fit: BoxFit.contain,
                                          child: Image.asset(
                                            'assets/images/NSMC_LOGO_BLUR.png',
                                          ),
                                        ),
                                      ),
                                    ),

                                    Transform.translate(
                                      offset: const Offset(
                                        0,
                                        -60,
                                      ), // negative Y to move up
                                      child: Text(
                                        'Welcome',
                                        style: GoogleFonts.poppins(
                                          color: const Color(0xFF4D7C4A),
                                          fontSize: width * 0.09,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Transform.translate(
                                      offset: const Offset(
                                        0,
                                        -62,
                                      ), // negative Y to move up
                                      child: Text(
                                        'Login to your account to continue',
                                        style: GoogleFonts.poppins(
                                          color: Colors.grey[600],
                                          fontSize: width * 0.028,
                                        ),
                                      ),
                                    ),

                                    // 📧 Email Field
                                    Transform.translate(
                                      offset: const Offset(
                                        0,
                                        -24,
                                      ),
                                      child: TextFormField(
                                        controller: _emailController,
                                        keyboardType: TextInputType.emailAddress,
                                        decoration: _buildInputDecoration(
                                          'Email',
                                        ),
                                        inputFormatters: [
                                          InputFormat.noWhitespace,
                                        ],
                                        validator: (value) {
                                          if (value == null || value.trim().isEmpty) {
                                            return 'Please enter your email address.';
                                          }
                                          if (!value.contains('@') || !value.contains('.')) {
                                            return 'Please enter a valid email address.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    // 🔒 Password Field
                                    Transform.translate(
                                      offset: const Offset(
                                        0,
                                        -12,
                                      ),
                                      child: TextFormField(
                                        obscureText: _obscurePassword,
                                        controller: _passwordController,
                                        decoration: _buildInputDecoration(
                                          'Password',
                                          suffix: IconButton(
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_off_outlined
                                                  : Icons.visibility_outlined,
                                              color: Colors.grey.shade500,
                                              size: 20,
                                            ),
                                            onPressed: () => setState(() =>
                                                _obscurePassword =
                                                    !_obscurePassword),
                                          ),
                                        ),
                                        inputFormatters: [
                                          InputFormat.noLeadingWhitespace,
                                        ],
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter your password.';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 8.0,
                                      ),
                                      child: Align(
                                        alignment: Alignment.centerRight,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.of(context).push(
                                              transitionAnimation(
                                                page:
                                                    const ForgotPasswordScreen(),
                                              ),
                                            );
                                          },
                                          child: Text(
                                            'Forgot Password?',
                                            style: GoogleFonts.poppins(
                                              color: Colors.grey[600],
                                              fontSize: width * 0.032,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),

                                    SizedBox(height: height * 0.06),

                                    //🔹Login Button
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(
                                          0xFF6FBF73,
                                        ),
                                        foregroundColor: Colors.white,
                                        padding: EdgeInsets.symmetric(
                                          vertical: height * 0.018,
                                          horizontal: width * 0.35,
                                        ),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        elevation: 2,
                                      ),
                                      onPressed: () async {
                                        if (_formKey.currentState!.validate()) {
                                          final result = await vm.login(
                                            _emailController.text.trim(),
                                            _passwordController.text.trim(),
                                          );

                                          if (!context.mounted) return;

                                          switch (result) {
                                            case Ok():
                                              // Making sure that when it appears, the home screen will be shown for at least 5 seconds to prevent flashing effect
                                              setState(() {
                                                _isLoading = true;
                                              });

                                              await Future.delayed(
                                                Duration(seconds: 3),
                                              );

                                              setState(() {
                                                _isLoading = false;
                                              });

                                              if (!context.mounted) return;

                                              Navigator.of(context).popUntil((
                                                route,
                                              ) {
                                                return route.isFirst;
                                              });
                                            case Error():
                                              final errMsg = vm.message ?? '';
                                              String displayMsg;
                                              if (errMsg.toLowerCase().contains('password') ||
                                                  errMsg.toLowerCase().contains('wrong') ||
                                                  errMsg.toLowerCase().contains('invalid credential')) {
                                                displayMsg = 'Wrong password. Please try again.';
                                              } else if (errMsg.toLowerCase().contains('user') ||
                                                  errMsg.toLowerCase().contains('no account') ||
                                                  errMsg.toLowerCase().contains('found') ||
                                                  errMsg.toLowerCase().contains('email')) {
                                                displayMsg = 'No registered email found. Please check your email or register.';
                                              } else {
                                                displayMsg = vm.message ?? 'Unknown error occurred. Please try again.';
                                              }
                                              showSnackBar(
                                                context: context,
                                                text: displayMsg,
                                                color: Colors.red[900],
                                              );
                                          }
                                        } else {
                                          showSnackBar(
                                            context: context,
                                            text:
                                                "Your submission is unfinished or invalid, Please check and try again.",
                                            color: Colors.red[900],
                                          );
                                        }
                                      },
                                      child: Text(
                                        'Login',
                                        style: GoogleFonts.poppins(
                                          fontSize: width * 0.045,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: height * 0.03),

                                    // 🔹 Register Link
                                    Transform.translate(
                                      offset: const Offset(
                                        0,
                                        -10,
                                      ), // negative Y to move up
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            "Don't have an account? ",
                                            style: GoogleFonts.poppins(
                                              fontSize: width * 0.035,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              Navigator.of(context).push(
                                                transitionAnimation(
                                                  page: const SignupScreen(),
                                                ),
                                              );
                                            },
                                            child: Text(
                                              'Register',
                                              style: GoogleFonts.poppins(
                                                fontSize: width * 0.035,
                                                color: const Color(0xFF4D7C4A),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
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

  //▫️Helper Widget:
  // Specialized decoration for text fields
  InputDecoration _buildInputDecoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: GoogleFonts.poppins(color: Colors.grey.shade600, fontSize: 14),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 16),
      suffixIcon: suffix,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xffefefef), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFF629E5C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      fillColor: Colors.white,
      filled: true,
    );
  }
}