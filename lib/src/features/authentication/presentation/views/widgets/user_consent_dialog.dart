import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<bool?> showConsentDialog({required BuildContext context}) async {
  return showDialog(
    context: context,
    barrierDismissible: false, // User must make a choice
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 350, maxHeight: 500),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12), // Slightly softer corners
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              Text(
                "User Data Consent",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),

              // Scrollable Message Area
              Flexible(
                child: SingleChildScrollView(
                  child: Text(
                    "We will collect and use your data in accordance with our Privacy Policy. By proceeding, you consent to the collection and use of your data as described.",
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF616161),
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Decline Button
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: Text(
                      "Decline",
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Agree Button
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      "Agree",
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
