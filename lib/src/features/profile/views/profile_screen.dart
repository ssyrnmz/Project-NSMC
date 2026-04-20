import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'edit_personal_info_screen.dart';
import 'edit_emergency_contact_screen.dart';
import '../viewmodels/emergency_contact_viewmodel.dart';
import '../../authentication/data/account_session.dart';
import '../../authentication/domain/session.dart';
import '../../authentication/domain/user.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/account_checker.dart';
import '../../../core/widgets/loading_screen.dart';
import '../../../utils/ui/animations_transitions.dart';
import '../../../utils/ui/display_formatters.dart';
import '../../../utils/ui/show_snackbar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.patientUser});

  final User patientUser;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vmInitial = context.read<EmergencyContactViewModel>();
      final result = await vmInitial.load(widget.patientUser.id);

      if (!mounted) return;

      if (result is Error) {
        showSnackBar(
          context: context,
          text:
              vmInitial.message ??
              "An unknown error occured. Please try again.",
          color: Colors.red[900],
        );
      }
    });
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vm = context.watch<EmergencyContactViewModel>();

    final userSession = session.session;

    final user = (userSession is UserSession)
        ? userSession.userAccount
        : widget.patientUser;

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F9FA),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
          elevation: 0,
          surfaceTintColor: const Color.fromARGB(235, 165, 165, 165),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            'Profile Details',
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

        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(), // smoother scroll
          child: Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //🔹Personal Details Section
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 28.0,
                          right: 18.0,
                          top: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (session.role == UserRole.admin)
                                  ? "Patient Details"
                                  : "Personal Details",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 15.8,
                              ),
                            ),

                            IconButton(
                              onPressed: () {
                                // Allow user to add their missing info & admin to view patient's details
                                Navigator.of(context).push(
                                  transitionAnimation(
                                    page: AuthWrappper(
                                      accessRole: session.role,
                                      child: EditPersonalInfoScreen(
                                        patientUser: user,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                (session.role == UserRole.admin)
                                    ? Icons.visibility_outlined
                                    : Icons.edit_outlined,
                                color: Color(0xFF4D7C4A),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 5),

                      buildRow('Full Name', subtitle: user.fullName),
                      buildRow('Nationality', subtitle: user.nationality),
                      buildRow('NRIC', subtitle: user.icNumber),
                      buildRow(
                        'Date of Birth',
                        subtitle: DisplayFormat().dateSlash(user.birthDate),
                      ),
                      buildRow('Gender', subtitle: user.gender),
                      buildRow('Email Address', subtitle: user.email),
                      buildRow('Mobile Phone', subtitle: user.phoneNumber),
                      buildRow('Ethnicity', subtitle: user.race ?? ''),
                      buildRow('Religion', subtitle: user.religion ?? ''),
                      buildRow('Occupation', subtitle: user.occupation ?? ''),
                      buildRow(
                        'Address',
                        subtitle: user.homeAddress ?? '',
                        isLast: true,
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                //🔹Others Section
                Container(
                  width: double.infinity,
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 28.0,
                          right: 18.0,
                          top: 10,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              (session.role == UserRole.admin)
                                  ? "Patient Emergency's Details"
                                  : "Next of Kin / Emergency Contact",
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.w500,
                                fontSize: 15.8,
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                // Allow user to add their emergency contact info and admin to view
                                Navigator.of(context).push(
                                  transitionAnimation(
                                    page: AuthWrappper(
                                      accessRole: session.role,
                                      child: EditEmergencyContactScreen(
                                        patientUser: user,
                                        contact: vm.contact,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(
                                (session.role == UserRole.admin)
                                    ? Icons.visibility_outlined
                                    : Icons.edit_outlined,
                                color: Color(0xFF4D7C4A),
                                size: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),

                      buildRow('Name', subtitle: vm.contact?.name ?? ''),
                      buildRow(
                        'Relationship',
                        subtitle: vm.contact?.relationship ?? '',
                      ),
                      buildRow('Email', subtitle: vm.contact?.email ?? ''),
                      buildRow(
                        'Mobile Phone',
                        subtitle: vm.contact?.phoneNumber ?? '',
                      ),
                      buildRow(
                        'Full Address',
                        subtitle: vm.contact?.homeAddress ?? '',
                        isLast: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),

                /*
                    const SizedBox(height: 12),
            
                    // 🚧 Deactivate Account Section (WIP)
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: GestureDetector(
                          onTap: () async {
                            // Add delete account logic here
                          },
                          child: Text(
                            'Delete Account',
                            style: GoogleFonts.poppins(
                              fontSize: 15.8,
                              color: Color.fromARGB(255, 214, 59, 59),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // 🚧 Save Details Section (WIP)
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FBF73),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 154,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          //elevation: 4,
                        ),
                        onPressed: () {
                          // Add save logic here
                        },
                        child: Text(
                          'Save',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    */
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

//▫️Helper Widget:
// Row widget (With subtitle)
Widget buildRow(
  String title, {
  String? subtitle,
  bool isLast = false,
  bool isLogout = false,
  VoidCallback? onTap,
}) {
  Widget rowContent = Padding(
    padding: EdgeInsets.fromLTRB(
      28.0, // left
      isLogout ? 16 : 8, // top
      18.0, // right
      isLogout ? 16 : (isLast ? 20 : 8), // bottom
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.poppins(
                color: isLogout ? Colors.red : Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 15.3,
              ),
            ),
            if (isLogout) const Icon(Icons.logout, color: Colors.red, size: 23),
          ],
        ),

        // ✅ Optional subtitle
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 5.0),
            child: Text(
              subtitle,
              style: GoogleFonts.poppins(
                color: const Color(0xFF666666),
                fontWeight: FontWeight.w300,
                fontSize: 14,
              ),
            ),
          ),
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
          endIndent: 10,
        ),
    ],
  );
}
