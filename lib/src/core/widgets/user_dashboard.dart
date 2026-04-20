import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class UserDashboardBox extends StatelessWidget {
  const UserDashboardBox({super.key});

  // ----------------------------------
  // EMERGENCY CARD (UNCHANGED)
  // ----------------------------------
  Widget _buildEmergencyCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFF),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD0E3FF), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.35),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 6.0),
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 21,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),

          // 🔥 Tappable phone icon
          GestureDetector(
            onTap: () async {
              final Uri phoneUri = Uri(scheme: 'tel', path: value);

              if (await canLaunchUrl(phoneUri)) {
                await launchUrl(phoneUri);
              } else {
                print("Could not launch dialer");
              }
            },
            child: FaIcon(icon, color: iconColor, size: 21),
          ),
        ],
      ),
    );
  }

  // ----------------------------------
  // MAIN BUILD (ZUS-INSPIRED SEMI-PROFESSIONAL LOOK)
  // ----------------------------------
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          // Zus-like clean white background
          color: Colors.white,
          // Clean, moderate border radius
          borderRadius: BorderRadius.circular(16),
          // Subtle border like Zus
          border: Border.all(color: const Color(0xFFE5E9F0), width: 1.0),
          // Very subtle shadow like Zus app
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF000000).withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 0,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Clean header like Zus
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Access',
                  style: GoogleFonts.poppins(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: const Color(
                      0xFF1D2939,
                    ), // Darker, professional color
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F7FF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Emergency',
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF175CD3), // Zus-like blue
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            _buildEmergencyCard(
              title: 'Emergency Helpline',
              value: "+6082-311 999",
              icon: FontAwesomeIcons.phone,
              iconColor: const Color(0xFF175CD3), // Matching Zus blue
            ),

            // Zus-like subtle separator
            const SizedBox(height: 9),
            Divider(height: 1, thickness: 1, color: const Color(0xFFF2F4F7)),
            const SizedBox(height: 12),

            // Optional: Add quick tip like Zus does
            Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: const Color(0xFF667085),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Available 24/7. Tap the phone icon to call immediately.',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF667085),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
