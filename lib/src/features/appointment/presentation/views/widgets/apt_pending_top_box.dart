import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class PendingTopBox extends StatelessWidget {
  const PendingTopBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF0E0), Color(0xFFFFE2C6), Color(0xFFFFE8D4)],
          ),
          border: Border.all(color: Color(0xFFFFC88A), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 8,
              spreadRadius: 1,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔔 Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFB74D).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.announcement_rounded,
                color: Color(0xFFFF9800),
                size: 26,
              ),
            ),
            const SizedBox(width: 14),

            // 📝 Text
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF5A4632),
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(
                      text: 'Your appointment is awaiting approval.\n',
                    ),
                    const TextSpan(
                      text:
                          'If you haven’t received an update after 2 days, please contact ',
                    ),
                    TextSpan(
                      text: 'NORMAH Customer Service ',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF4D7C4A),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(text: 'at '),
                    TextSpan(
                      text: '+60 16-595 9186',
                      style: GoogleFonts.poppins(
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Clipboard.setData(
                            const ClipboardData(text: '+60 16-595 9186'),
                          );
                        },
                    ),
                    const TextSpan(text: '.'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
