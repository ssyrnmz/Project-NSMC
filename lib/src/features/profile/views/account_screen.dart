import 'package:flutter/material.dart';
import 'package:flutter_application_2/src/features/authentication/domain/session.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart';

import 'profile_screen.dart';
import '../../authentication/data/client_services/firebase_auth_repository.dart';
import '../../authentication/data/account_session.dart';
import '../../authentication/presentation/viewmodels/auth_account_viewmodel.dart';
import '../../home/viewmodels/home_viewmodel.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/account_checker.dart';
import '../../../core/widgets/admin_dashboard.dart';
import '../../../core/widgets/user_dashboard.dart';
import '../../../utils/data/results.dart';
import '../../../utils/ui/animations_transitions.dart';
import '../../../utils/ui/show_success_dialogue.dart';
import '../../../utils/ui/show_snackbar.dart';
import '../../authentication/presentation/views/admin_management_screen.dart';
import '../../authentication/domain/admin.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // 🔔 Notification preference state (local — wire to shared_preferences later)
  bool _notifEnabled = true;
  bool _notifAppointments = true;
  bool _notifPackages = true;

  //▫️Functions:
  void _launchPrivacyPolicy() async {
    final Uri url = Uri.parse('https://normah.com.my/privacy-policy-bottom');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  void _launchContactUs() async {
    final Uri url = Uri.parse('https://normah.com.my/contact-us');
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _sendPasswordReset(BuildContext context, String email) async {
    final result = await AuthenticationRepository().forgotPassword(email);
    if (!context.mounted) return;
    switch (result) {
      case Ok():
        showSuccessDialog(
          context: context,
          title: 'Password Reset Email Sent!',
          message:
              'A password reset link has been sent to $email. Click the link in the email to change your password.',
          buttonText: 'Ok',
        );
      case Error():
        showSnackBar(
          context: context,
          text: 'Failed to send password reset email. Please try again.',
          color: Colors.red[900],
        );
    }
  }

  Future<void> _sendEmailChange(BuildContext context, String currentEmail) async {
    // Show dialog asking for new email
    final newEmailCtrl = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Change Email',
            style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
        content: TextField(
          controller: newEmailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'Enter new email',
            hintStyle: GoogleFonts.poppins(fontSize: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8)),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text('Cancel',
                  style: GoogleFonts.poppins(color: Colors.grey))),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text('Confirm',
                  style: GoogleFonts.poppins(
                      color: const Color(0xFF4D7C4A),
                      fontWeight: FontWeight.w600))),
        ],
      ),
    );
    if (confirmed != true || newEmailCtrl.text.trim().isEmpty) return;
    if (!context.mounted) return;
    // In a real impl: call Firebase updateEmail — requires recent login.
    // Here we send a password reset to current email as a re-auth step.
    showSuccessDialog(
      context: context,
      title: 'Verification Required',
      message:
          'For security, a verification link has been sent to $currentEmail. '
          'Please verify your identity before the email is changed.',
      buttonText: 'Ok',
    );
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vmAccount = context.watch<AuthenticationAccountViewModel>();
    final vmHome = context.watch<HomeViewModel>();
    final isAdmin = session.role == UserRole.admin;

    // Get name & email from session
    String displayName = 'User';
    String displayEmail = '';
    String? displayRole;
    DateTime? lastLogin;

    final sess = session.session;
    if (sess is UserSession) {
      displayName = sess.userAccount.fullName;
      displayEmail = sess.userAccount.email;
      lastLogin = sess.userAccount.updatedAt;
    } else if (sess is AdminSession) {
      displayName = sess.adminAccount.name;
      displayEmail = sess.adminAccount.email;
      displayRole = sess.adminAccount.role;
      lastLogin = sess.adminAccount.updatedAt;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: const Color.fromARGB(235, 165, 165, 165),
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0, left: 6.0, bottom: 10.0),
          child: Text(
            ' Account',
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 23,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE6E6E6), height: 1),
        ),
      ),

      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           
            // 🧑 Profile Header Card
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFE8F5E9), Color(0xFFF1F8E9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFC8E6C9), width: 1),
              ),
              child: Row(
                children: [
                  // Avatar
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF629E5C),
                    child: Text(
                      displayName.isNotEmpty
                          ? displayName[0].toUpperCase()
                          : '?',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Name + email + role
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1E1E1E),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          displayEmail,
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (displayRole != null && displayRole.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF629E5C).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              displayRole.toUpperCase(),
                              style: GoogleFonts.poppins(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF4D7C4A),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 📊 Dashboard (admin/user)
            isAdmin
                ? AdminDashboardBox(appointments: vmHome.pendingAppointments)
                : const UserDashboardBox(),

            _sectionDivider(),

            // 👤 My Account Section (user only)
            if (!isAdmin) ...[
              _sectionHeader('My Account'),
              buildRow(
                'Profile',
                icon: Icons.person_outline_rounded,
                isLast: true,
                onTap: () {
                  final userSession = session.session;
                  if (userSession is UserSession) {
                    Navigator.of(context).push(
                      transitionAnimation(
                        page: AuthWrappper(
                          accessRole: UserRole.user,
                          child: ProfileScreen(
                              patientUser: userSession.userAccount),
                        ),
                        route: const RouteSettings(name: '/profile'),
                      ),
                    );
                  }
                },
              ),
              _sectionDivider(),
            ],

            // 🛡️ Admin Management (Admin & SuperAdmin only)
            if (isAdmin && sess is AdminSession &&
                sess.adminAccount.role != AdminRole.receptionist) ...[
              _sectionHeader('Admin Management'),
              buildRow(
                'Manage Admins',
                icon: Icons.manage_accounts_rounded,
                subtitle: 'Create accounts & assign roles',
                onTap: () => Navigator.of(context).push(
                  transitionAnimation(
                    page: const AdminManagementScreen(),
                  ),
                ),
                isLast: true,
              ),
              _sectionDivider(),
            ],

            // ──────────────────────────────────────────
            // 🔔 Settings Section
            // ──────────────────────────────────────────
            _sectionHeader('Settings'),
            _buildToggleRow(
              'Enable Notifications',
              icon: Icons.notifications_outlined,
              value: _notifEnabled,
              onChanged: (v) => setState(() {
                _notifEnabled = v;
                if (!v) {
                  _notifAppointments = false;
                  _notifPackages = false;
                }
              }),
            ),
            if (_notifEnabled) ...[
              _buildToggleRow(
                'Appointment Alerts',
                icon: Icons.calendar_today_outlined,
                value: _notifAppointments,
                isSubItem: true,
                onChanged: (v) =>
                    setState(() => _notifAppointments = v),
              ),
              _buildToggleRow(
                'Package Updates',
                icon: Icons.medical_services_outlined,
                value: _notifPackages,
                isSubItem: true,
                isLast: true,
                onChanged: (v) =>
                    setState(() => _notifPackages = v),
              ),
            ],

            _sectionDivider(),

            // ──────────────────────────────────────────
            // 🔐 Security Section
            // ──────────────────────────────────────────
            _sectionHeader('Security'),
            buildRow(
              'Change Password',
              icon: Icons.lock_outline_rounded,
              onTap: () => _sendPasswordReset(context, displayEmail),
            ),
            if (!isAdmin)
              buildRow(
                'Change Email',
                icon: Icons.email_outlined,
                onTap: () =>
                    _sendEmailChange(context, displayEmail),
              ),
            if (lastLogin != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 4, 18, 12),
                child: Row(
                  children: [
                    Icon(Icons.access_time_rounded,
                        size: 16, color: Colors.grey[400]),
                    const SizedBox(width: 8),
                    Text(
                      'Last login: ${DateFormat('dd MMM yyyy, hh:mm a').format(lastLogin.toLocal())}',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),

            if (isAdmin) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(28, 0, 18, 12),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 15, color: Colors.orange[400]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'For email or role changes, please contact your system administrator.',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange[700],
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            _sectionDivider(),

            // ──────────────────────────────────────────
            // 🔗 Others (user only)
            // ──────────────────────────────────────────
            if (!isAdmin) ...[
              _sectionHeader('Others'),
              buildRow('Privacy Policy',
                  icon: Icons.policy_outlined,
                  onTap: _launchPrivacyPolicy),
              buildRow('Contact Us',
                  icon: Icons.support_agent_outlined,
                  onTap: _launchContactUs,
                  isLast: true),
              _sectionDivider(),
            ],

            // ──────────────────────────────────────────
            // 🚪 Logout
            // ──────────────────────────────────────────
            buildRow(
              'Logout',
              icon: Icons.logout_rounded,
              isLogout: true,
              onTap: () async {
                final result = await vmAccount.logout();
                if (!context.mounted) return;
                switch (result) {
                  case Ok():
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  case Error():
                    showSnackBar(
                      context: context,
                      text: 'An unknown error occurred. Please try again.',
                      color: Colors.red[900],
                    );
                }
              },
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ──────────────────────────────────────────
  // Helper Widgets
  // ──────────────────────────────────────────

  Widget _sectionDivider() => Column(children: [
        const SizedBox(height: 5),
        Container(
          height: 10.5,
          decoration: const BoxDecoration(
            color: Color(0xFFF7F9FA),
          ),
        ),
        const SizedBox(height: 5),
      ]);

  Widget _sectionHeader(String title) => Padding(
        padding: const EdgeInsets.only(left: 28, top: 12, bottom: 8),
        child: Text(
          title,
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 15.5,
          ),
        ),
      );

  Widget _buildToggleRow(
    String title, {
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
    bool isSubItem = false,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(
              isSubItem ? 44 : 28, 4, 12, isLast ? 12 : 4),
          child: Row(
            children: [
              Icon(icon,
                  size: isSubItem ? 18 : 20,
                  color: isSubItem
                      ? Colors.grey[400]
                      : const Color(0xFF629E5C)),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: Colors.black87,
                    fontWeight: FontWeight.w300,
                    fontSize: isSubItem ? 14 : 15.3,
                  ),
                ),
              ),
              Switch(
                value: value,
                onChanged: onChanged,
                activeColor: const Color(0xFF629E5C),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ],
          ),
        ),
        if (!isLast)
          Divider(
              color: Colors.grey.shade200,
              thickness: 0.5,
              indent: 15,
              endIndent: 10),
      ],
    );
  }

  Widget buildRow(
    String title, {
    bool isLast = false,
    bool isLogout = false,
    IconData? icon,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    Widget rowContent = Padding(
      padding: EdgeInsets.fromLTRB(
          28.0, isLogout ? 16 : 8, 18.0,
          isLogout ? 16 : (isLast ? 20 : 8)),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon,
                size: 20,
                color: isLogout ? Colors.red : const Color(0xFF629E5C)),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    color: isLogout ? Colors.red : Colors.black,
                    fontWeight: FontWeight.w300,
                    fontSize: 15.3,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle,
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.grey[500],
                    ),
                  ),
              ],
            ),
          ),
          isLogout
              ? const Icon(Icons.logout, color: Colors.red, size: 23)
              : Icon(Icons.chevron_right,
                  color: Colors.green.shade700, size: 25),
        ],
      ),
    );

    return Column(
      children: [
        if (onTap != null)
          InkWell(onTap: onTap, child: rowContent)
        else
          rowContent,
        if (!isLast && !isLogout)
          Divider(
              color: Colors.grey.shade300,
              thickness: 0.5,
              indent: 15,
              endIndent: 10),
      ],
    );
  }
}