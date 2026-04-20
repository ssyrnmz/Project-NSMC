import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionsScreen extends StatelessWidget {
  const TermsConditionsScreen({super.key});

  Future<void> _openPrivacyPolicy() async {
    final Uri url = Uri.parse('https://normah.com.my/privacy-policy-bottom');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9fafb),
        elevation: 0,
        surfaceTintColor: const Color.fromARGB(235, 165, 165, 165),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
              Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Terms & Conditions',
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

      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.policy_outlined,
                      color: Color(0xFF4D7C4A),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Normah Medical Specialist Centre',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1E1E1E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Privacy Policy & Terms of Use',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Open in browser button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _openPrivacyPolicy,
                icon: const Icon(Icons.open_in_browser_rounded,
                    color: Color(0xFF4D7C4A)),
                label: Text(
                  'View Full Policy on Normah Website',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF4D7C4A),
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: Color(0xFF4D7C4A), width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
            _divider(),

            // Section 1 — Collecting Information
            _sectionTitle('1. Collecting Information'),
            _sectionBody(
              'We only collect information that is required for the registration procedure '
              'on our website or when filling up the registration form at our medical centre. '
              'The information we gather is voluntarily submitted by our patients.',
            ),

            _divider(),

            // Section 2 — Personal Identification Details
            _sectionTitle('2. Personal Identification Details'),
            _sectionBody(
              'Your personal identification details are used as identifiers in compliance '
              'with the IPSG standard for our patients\' safety, and also for purposes '
              'of event invitations, updates, news, changes, and promotions where necessary.',
            ),

            _divider(),

            // Section 3 — Confidentiality
            _sectionTitle('3. Confidentiality'),
            _sectionBody(
              'Your personal information such as credit card details and bank account numbers '
              'are kept strictly secret and confidential. We will never share any of your '
              'personal details with any third party.',
            ),

            _divider(),

            // Section 4 — Security
            _sectionTitle('4. Security'),
            _sectionBody(
              'Our application applies appropriate security measures in order to prevent '
              'any leakage of patients\' personal identification details to third parties, '
              'illegal disclosure, and unauthorised access.',
            ),

            _divider(),

            // Section 5 — Changes to Privacy Policy
            _sectionTitle('5. Changes to Privacy Policy'),
            _sectionBody(
              'Normah Medical Specialist Centre reserves the right to impose any '
              'changes or updates to the Privacy Policy contents from time to time '
              'without prior notice. All updated information will be available on '
              'our official website at www.normah.com.my.',
            ),

            _divider(),

            // Section 6 — App Usage
            _sectionTitle('6. Use of This Application'),
            _sectionBody(
              'This mobile application is developed for the purpose of providing '
              'patients and staff of Normah Medical Specialist Centre with convenient '
              'access to appointment booking, health screening packages, medical records, '
              'and prescription management.\n\n'
              'By using this application, you agree to provide accurate and up-to-date '
              'personal information and to use the application only for its intended purposes.',
            ),

            _divider(),

            // Section 7 — Contact
            _sectionTitle('7. Contact Us'),
            _sectionBody(
              'For any enquiries regarding your personal data or this Privacy Policy, '
              'please contact us:\n\n'
              '📍  Normah Medical Specialist Centre (119669-X)\n'
              '       Lot 937, Section 30 KTLD,\n'
              '       Jalan Datuk Patinggi Haji Abdul Rahman Yakub,\n'
              '       Petra Jaya, 93050 Kuching, Sarawak.\n\n'
              '📞  General Line: +6082-440 055\n'
              '🚨  Emergency: +6082-311 999\n'
              '📧  inquiry@normah.com',
            ),

            const SizedBox(height: 28),

            // Footer note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '© 2026 Normah Medical Specialist Centre (119669-X). '
                'All Rights Reserved.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 11.5,
                  color: Colors.grey[500],
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ── Helpers ──────────────────────────────────────

  Widget _sectionTitle(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 14.5,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1E1E1E),
          ),
        ),
      );

  Widget _sectionBody(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 13.5,
            color: Colors.grey[700],
            height: 1.6,
            fontWeight: FontWeight.w400,
          ),
        ),
      );

  Widget _divider() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Divider(color: Colors.grey.shade200, thickness: 1),
      );
}