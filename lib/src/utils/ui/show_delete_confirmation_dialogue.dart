import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void showDeleteConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required Future<void> Function() onDelete, // Changed to async function
  VoidCallback? whenDelete, // Keep original name
  bool showSuccessDialog = true,
  String confirmButtonText = "Yes, Delete",
  String successTitle = "Success!",
  String successMessage = "The record has been updated successfully.",
}) async {
  // Store context before any async operations
  final dialogContext = context;

  await showDialog(
    context: dialogContext,
    barrierDismissible: false,
    builder: (context) => Dialog(
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.center,
        child: SizedBox(
          width: 300,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ---------------- TOP CONTENT ----------------
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          color: const Color(0xFF616161),
                          fontSize: 14,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                ),

                // ---------------- CONFIRM BUTTON ----------------
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // close confirmation dialog

                    try {
                      // Show loading
                      showDialog(
                        context: dialogContext,
                        barrierDismissible: false,
                        builder: (loadingContext) => Dialog(
                          backgroundColor: Colors.transparent,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  CircularProgressIndicator(
                                    color: Color(0xFFD32F2F),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "Processing...",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      // Perform delete/deactivate action
                      onDelete();

                      // Close loading dialog
                      Navigator.of(dialogContext, rootNavigator: true).pop();

                      // Show success dialog
                      if (showSuccessDialog) {
                        showDialog(
                          context: dialogContext,
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
                                padding: const EdgeInsets.fromLTRB(
                                  20,
                                  16,
                                  20,
                                  12,
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Title
                                    Text(
                                      successTitle,
                                      style: GoogleFonts.poppins(
                                        color: Colors.black,
                                        fontSize: 17,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Message
                                    Text(
                                      successMessage,
                                      style: GoogleFonts.poppins(
                                        color: const Color(0xFF616161),
                                        fontSize: 14,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 20),

                                    // Button aligned right
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        onPressed: () {
                                          Navigator.pop(dialogContext);
                                          whenDelete
                                              ?.call(); // Use original name here
                                        },
                                        style: TextButton.styleFrom(
                                          foregroundColor: const Color(
                                            0xFF4CAF50,
                                          ),
                                          textStyle: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w500,
                                            fontSize: 14,
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 8,
                                          ),
                                          tapTargetSize:
                                              MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: const Text("Back"),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }
                    } catch (error) {
                      // Close loading dialog if it's still open
                      Navigator.of(dialogContext, rootNavigator: true).pop();

                      // Show error dialog
                      showDialog(
                        context: dialogContext,
                        builder: (_) => AlertDialog(
                          title: const Text("Error"),
                          content: Text(error.toString()),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext),
                              child: const Text("OK"),
                            ),
                          ],
                        ),
                      );
                    }
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD14040),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  child: Text(confirmButtonText),
                ),

                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                ),

                // ---------------- CANCEL BUTTON ----------------
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey[700],
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    textStyle: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  child: const Text("No, Return"),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
