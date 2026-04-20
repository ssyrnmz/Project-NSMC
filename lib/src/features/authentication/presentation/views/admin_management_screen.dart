import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import '../viewmodels/auth_account_viewmodel.dart';
import '../../domain/admin.dart';
import '../../domain/session.dart';
import '../../data/client_services/admin_service.dart';
import '../../data/account_session.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_snackbar.dart';

class AdminManagementScreen extends StatefulWidget {
  const AdminManagementScreen({super.key});

  @override
  State<AdminManagementScreen> createState() => _AdminManagementScreenState();
}

class _AdminManagementScreenState extends State<AdminManagementScreen> {
  // ── Create form ────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _selectedRole = AdminRole.admin;
  bool _obscurePass = true;

  // ── Admin list ─────────────────────────────────────────────
  List<Admin> _admins = [];
  bool _listLoading = true;
  String? _listError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadAdmins());
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  // ── Load existing admins ───────────────────────────────────
  Future<void> _loadAdmins() async {
    setState(() {
      _listLoading = true;
      _listError = null;
    });
    final service = context.read<AdminAccountService>();
    final result = await service.getAdmins();
    if (!mounted) return;
    switch (result) {
      case Ok<List<Admin>>():
        setState(() {
          _admins = result.value;
          _listLoading = false;
        });
      case Error<List<Admin>>():
        setState(() {
          _listError = 'Could not load admin list. Check your connection.';
          _listLoading = false;
        });
    }
  }

  // ── Create new admin ───────────────────────────────────────
  Future<void> _submitCreateAdmin() async {
    if (!_formKey.currentState!.validate()) return;

    final session = context.read<AccountSession>().session;
    if (session is! AdminSession) return;

    // Receptionist cannot create admin accounts
    if (session.adminAccount.role == 'Receptionist') {
      showSnackBar(
        context: context,
        text: 'Your access level does not allow creating admin accounts.',
        color: Colors.red[900],
      );
      return;
    }

    final vm = context.read<AuthenticationAccountViewModel>();

    final newAdmin = Admin(
      id: '',
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      role: _selectedRole,
      unactive: false,
      updatedAt: DateTime.now(),
    );

    final result = await vm.adminSignup(
      newAdmin,
      _passCtrl.text.trim(),
      session,
    );

    if (!mounted) return;

    switch (result) {
      case Ok():
        _nameCtrl.clear();
        _emailCtrl.clear();
        _passCtrl.clear();
        setState(() => _selectedRole = AdminRole.admin);
        showSnackBar(
          context: context,
          text: 'Admin account created successfully.',
          color: const Color(0xFF4D7C4A),
        );
        await _loadAdmins(); // Refresh list
      case Error():
        showSnackBar(
          context: context,
          text: vm.message ?? 'Failed to create admin. Please try again.',
          color: Colors.red[900],
        );
    }
  }

  // ── UI ─────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthenticationAccountViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFFf7f7f7),
          elevation: 0,
          centerTitle: true,
          scrolledUnderElevation: 4,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new,
                color: Color(0xFF4D7C4A)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Admin Management',
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1E1E1E),
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
              // ── Role legend ──────────────────────────────
              _roleLegendCard(),
              const SizedBox(height: 24),

              // ── Create admin form ────────────────────────
              _sectionHeader('Create New Admin Account'),
              const SizedBox(height: 12),
              _createAdminForm(),
              const SizedBox(height: 28),

              // ── Existing admins list ─────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _sectionHeader('Current Admins'),
                  IconButton(
                    icon: const Icon(Icons.refresh_rounded,
                        color: Color(0xFF629E5C), size: 20),
                    onPressed: _loadAdmins,
                    tooltip: 'Refresh',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              _adminList(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ── Role legend ────────────────────────────────────────────
  Widget _roleLegendCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F7F0),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFD0E8CC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.shield_outlined,
                  color: Color(0xFF4D7C4A), size: 16),
              const SizedBox(width: 8),
              Text(
                'Role Permissions',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...AdminRole.all.map((role) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(top: 5, right: 8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _roleColor(role),
                    ),
                  ),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: GoogleFonts.poppins(
                            fontSize: 12.5, color: Colors.black87),
                        children: [
                          TextSpan(
                            text: '$role — ',
                            style: const TextStyle(
                                fontWeight: FontWeight.w600),
                          ),
                          TextSpan(
                            text: AdminRole.permissions[role] ?? '',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Create admin form ──────────────────────────────────────
  Widget _createAdminForm() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name
            _fieldLabel('Full Name'),
            const SizedBox(height: 6),
            _textField(
              controller: _nameCtrl,
              hint: 'Enter full name',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Name is required' : null,
            ),
            const SizedBox(height: 14),

            // Email
            _fieldLabel('Email Address'),
            const SizedBox(height: 6),
            _textField(
              controller: _emailCtrl,
              hint: 'Enter email address',
              keyboardType: TextInputType.emailAddress,
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email is required';
                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),

            // Password
            _fieldLabel('Temporary Password'),
            const SizedBox(height: 6),
            _textField(
              controller: _passCtrl,
              hint: 'Enter a strong password',
              obscure: _obscurePass,
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePass
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: Colors.grey,
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePass = !_obscurePass),
              ),
              onChanged: (_) => setState(() {}),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Password is required';
                if (v.length < 8 || v.length > 64) {
                  return 'Password must be 8–64 characters';
                }
                if (!v.contains(RegExp(r'[A-Z]'))) {
                  return 'Add at least 1 uppercase letter';
                }
                if (!v.contains(RegExp(r'[a-z]'))) {
                  return 'Add at least 1 lowercase letter';
                }
                if (!v.contains(RegExp(r'[0-9]'))) {
                  return 'Add at least 1 number';
                }
                if (!v.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]'))) {
                  return 'Add at least 1 special character';
                }
                return null;
              },
            ),

            // Password requirement box
            _buildPasswordRequirements(_passCtrl.text),

            const SizedBox(height: 14),

            // Role dropdown
            _fieldLabel('Role'),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _selectedRole,
              decoration: _inputDecoration(),
              isExpanded: true,
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(10),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey),
              items: AdminRole.all.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _roleColor(role),
                            ),
                          ),
                          Text(
                            role,
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          AdminRole.descriptions[role] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (v) {
                if (v != null) setState(() => _selectedRole = v);
              },
              style: GoogleFonts.poppins(
                  fontSize: 14, color: Colors.black87),
            ),

            const SizedBox(height: 20),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _submitCreateAdmin,
                icon: const Icon(Icons.person_add_outlined, size: 18),
                label: Text(
                  'Create Admin Account',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4D7C4A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Admin list ─────────────────────────────────────────────
  Widget _adminList() {
    if (_listLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: CircularProgressIndicator(color: Color(0xFF629E5C)),
        ),
      );
    }
    if (_listError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _listError!,
            style: GoogleFonts.poppins(
                fontSize: 13, color: Colors.orange[700]),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    if (_admins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.group_outlined,
                  color: Colors.grey[400], size: 36),
              const SizedBox(height: 10),
              Text(
                'No admins found.',
                style: GoogleFonts.poppins(
                    fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: _admins.map((admin) => _adminTile(admin)).toList(),
    );
  }

  Widget _adminTile(Admin admin) {
    final roleColor = _roleColor(admin.role);
    final initial =
        admin.name.isNotEmpty ? admin.name[0].toUpperCase() : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: admin.unactive ? Colors.grey[50] : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E9F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: roleColor.withOpacity(0.15),
            child: Text(
              initial,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                color: roleColor,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        admin.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: admin.unactive
                              ? Colors.grey
                              : Colors.black87,
                        ),
                      ),
                    ),
                    if (admin.unactive)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Inactive',
                          style: GoogleFonts.poppins(
                              fontSize: 10, color: Colors.grey[600]),
                        ),
                      ),
                  ],
                ),
                Text(
                  admin.email,
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Role badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: roleColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: roleColor.withOpacity(0.4)),
            ),
            child: Text(
              admin.role ?? 'Unknown',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: roleColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────
  Widget _sectionHeader(String title) => Text(
        title,
        style: GoogleFonts.poppins(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1E1E1E),
        ),
      );

  Widget _fieldLabel(String label) => Text(
        label,
        style: GoogleFonts.poppins(fontSize: 13, color: Colors.black87),
      );

  Widget _textField({
    required TextEditingController controller,
    String? hint,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      onChanged: onChanged,
      decoration: _inputDecoration(hint: hint).copyWith(
        suffixIcon: suffixIcon,
      ),
      style: GoogleFonts.poppins(fontSize: 14),
    );
  }

  InputDecoration _inputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle:
          GoogleFonts.poppins(color: Colors.grey[500], fontSize: 14),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xffefefef), width: 2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            const BorderSide(color: Color(0xFF629E5C), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide:
            BorderSide(color: Colors.red.shade900, width: 2),
      ),
    );
  }

  // ── Password requirement box ──────────────────────────────
  Widget _buildPasswordRequirements(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    final requirements = [
      {
        'label': '8–64 characters',
        'met': password.length >= 8 && password.length <= 64,
      },
      {
        'label': 'Uppercase letter (A-Z)',
        'met': password.contains(RegExp(r'[A-Z]')),
      },
      {
        'label': 'Lowercase letter (a-z)',
        'met': password.contains(RegExp(r'[a-z]')),
      },
      {
        'label': 'Number (0-9)',
        'met': password.contains(RegExp(r'[0-9]')),
      },
      {
        'label': r'Special character (!@#$...)',
        'met': password.contains(RegExp(r'[!@#\$%^&*(),.?":{}|<>]')),
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password must contain:',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            ...requirements.map((req) {
              final bool met = req['met'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      met
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 15,
                      color: met
                          ? const Color(0xFF4CAF50)
                          : Colors.red.shade300,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      req['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: met ? Colors.green[700] : Colors.red[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Color _roleColor(String? role) {
    switch (role) {
      case AdminRole.superAdmin:
        return const Color(0xFF6B21A8);
      case AdminRole.admin:
        return const Color(0xFF175CD3);
      case AdminRole.receptionist:
        return const Color(0xFF027A48);
      default:
        return Colors.grey;
    }
  }
}
