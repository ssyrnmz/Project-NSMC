import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppointmentBookingWarningBox extends StatelessWidget {
  const AppointmentBookingWarningBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFFEBEE), // soft pinkish red tone
              Color(0xFFFFE6E6), // light coral cream
              Color(0xFFFFF2F2), // pale rose mist
            ],
          ),
          border: Border.all(
            color: Color(0xFFFFB3B3), // soft coral-red border
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.redAccent.withOpacity(0.08),
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
                color: const Color(
                  0xFFFFCDD2,
                ).withOpacity(0.3), // light red tint
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFE53935), // coral red
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
                    const TextSpan(text: 'Please note that '),
                    TextSpan(
                      text: 'this is NOT a confirmation ',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD32F2F), // stronger red tone
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const TextSpan(
                      text:
                          'until our nurse contacts you regarding slot availability.',
                    ),
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
