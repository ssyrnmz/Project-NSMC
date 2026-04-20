import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../utils/ui/show_snackbar.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

  //▫️Function:
  Future<void> openEmail({
    required String email,
    String subject = '',
    String body = '',
  }) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject, 'body': body},
    );

    if (!await launchUrl(emailUri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not open email app');
    }
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF6FBF73)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Contact Us',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E1E1E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE6E6E6), // light grey divider
            height: 1,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER TEXT
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                '  Need assistance?',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '  Reach out to us through one of the options below.',
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            // CALL CARD
            _actionCard(
              icon: FontAwesomeIcons.phone,
              iconColor: const Color(0xFF4A90E2),
              title: 'Call Us',
              subtitle: '+6082-440 055',
              onTap: () async {
                final Uri phoneUri = Uri(
                  scheme: 'tel',
                  path: '+6082440055', // no spaces for safety
                );

                if (await canLaunchUrl(phoneUri)) {
                  await launchUrl(phoneUri);
                } else {
                  debugPrint('Could not launch dialer');

                  if (context.mounted) {
                    showDismissableSnackBar(
                      context: context,
                      text:
                          'The system cannot open your phone dialer. Please contact +6082-440 055 manually.',
                    );
                  }
                }
              },
            ),

            const SizedBox(height: 13),

            // EMAIL CARD
            _actionCard(
              icon: FontAwesomeIcons.envelope,
              iconColor: const Color(0xFF4A90E2),
              title: 'Email Us',
              subtitle: 'inquiry@normah.com',
              onTap: () async {
                try {
                  await openEmail(
                    email: 'inquiry@normah.com',
                    subject: 'Inquiry',
                  );
                } catch (e) {
                  if (context.mounted) {
                    showSnackBar(
                      context: context,
                      text:
                          'The system cannot open your email app directly. Please contact support@hospital.com manually.',
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  // Reusable widget - action card
  Widget _actionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: FaIcon(icon, color: iconColor, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
