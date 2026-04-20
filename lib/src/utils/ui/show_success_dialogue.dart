import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<void> showSuccessDialog({
  required BuildContext context,
  required String title,
  required String message,
  String buttonText = "Back",
  VoidCallback? onButtonPressed,
}) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                title,
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),

              // Message
              Text(
                message,
                style: GoogleFonts.poppins(
                  color: const Color(0xFF616161),
                  fontSize: 14,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 20),

              // Button
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed:
                      onButtonPressed ??
                      () {
                        Navigator.pop(context);
                      },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF4CAF50), // green
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(buttonText),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
