import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'profile_screen.dart';
import '../../authentication/domain/user.dart';
import '../../appointment/presentation/viewmodels/apt_view_viewmodel.dart';
import '../../appointment/presentation/views/apt_history_screen.dart';
import '../../medical_record/presentation/views/mr_view_screen.dart';
import '../../prescription/presentation/views/patient_presc_overview_screen.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/account_checker.dart';
import '../../../utils/ui/animations_transitions.dart';

class PatientDetailsScreen extends StatelessWidget {
  const PatientDetailsScreen({super.key, required this.patient});

  final User patient;

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9fafb),
        elevation: 0.8,
        shadowColor: Colors.grey.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Details',
          style: GoogleFonts.poppins(
            color: const Color(0xFF1E1E1E),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xFFE0E6F5), height: 1),
        ),
      ),

      // BODY
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // ⭐ PATIENT NAME INSTEAD OF "Latest"
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 0),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 20,
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Patient',
                          style: GoogleFonts.poppins(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0),
                    child: Text(
                      patient.fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Admin Account Section
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(color: Colors.white),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0, top: 20),
                    child: Text(
                      'View Details',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  buildRow(
                    'Profile',
                    onTap: () {
                      Navigator.of(context).push(
                        transitionAnimation(
                          page: AuthWrappper(
                            accessRole: UserRole.admin,
                            child: ProfileScreen(patientUser: patient),
                          ),
                          route: const RouteSettings(name: '/profile'),
                        ),
                      );

                      // Go to check user's profile information (no edit)
                    },
                  ),

                  buildRow(
                    'Appointment History',
                    onTap: () {
                      final vmAppointment = context
                          .read<AppointmentViewModel>();

                      vmAppointment.load();

                      Navigator.of(context).push(
                        transitionAnimation(
                          page: AuthWrappper(
                            accessRole: UserRole.admin,
                            child: AppointmentHistoryScreen(id: patient.id),
                          ),
                        ),
                      );
                      // 🚧 FUTURE: change to go to appointment tracking screen
                    },
                    isLast: true,
                  ),

                  buildRow(
                    'Prescription History',
                    onTap: () {
                      Navigator.of(context).push(
                        transitionAnimation(
                          page: AuthWrappper(
                            accessRole: UserRole.admin,
                            child: PatientPrescOverviewScreen(
                              userId: patient.id,
                              patientName: patient.fullName,
                            ),
                          ),
                        ),
                      );
                    },
                    isLast: true,
                  ),
                  const SizedBox(height: 5),

                  Container(
                    height: 10.5, // thickness of the line
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(
                            0xFFF7F9FA,
                          ), // nearly white with a trace of green
                          Color(
                            0xFFF7F9FA,
                          ), // very soft pale green (barely noticeable)
                          Color(0xFFF7F9FA),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  Padding(
                    padding: const EdgeInsets.only(left: 28.0, top: 20),
                    child: Text(
                      'More Management',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.8,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  buildRow(
                    'Medical Report',
                    onTap: () {
                      Navigator.of(context).push(
                        transitionAnimation(
                          page: AuthWrappper(
                            accessRole: UserRole.admin,
                            child: MedicalRecordViewScreen(
                                      id: patient.id,
                                      patientName: patient.fullName,
                                      patientEmail: patient.email,
                                      patientIc: patient.icNumber,
                                    ),
                          ),
                          route: const RouteSettings(name: '/recordList'),
                        ),
                      );
                    },
                    isLast: true,
                  ),

                  // 🚧 Prescription Report Upload Section (WIP)
                  /*
                  buildRow(
                    'Prescription Report',
                    onTap: () {
                      //navigate to screen to upload prescription report

                      transitionAnimation(
                        context,
                        const PatientPrescreportOverview(),
                        500,
                        800,
                      );
                    },
                    isLast: true,
                  ),
                  */
                  const SizedBox(height: 5),

                  Container(
                    height: 10.5, // thickness of the line
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          Color(
                            0xFFF7F9FA,
                          ), // nearly white with a trace of green
                          Color(
                            0xFFF7F9FA,
                          ), // very soft pale green (barely noticeable)
                          Color(0xFFF7F9FA),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // 🚧 Deactive Admin Account Section (WIP)
                  /*
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(color: Colors.white),
                    child: buildRow(
                      'Deactivate Account',
                      isLogout: true,
                      onTap: () {
                        showDeleteConfirmationDialog(
                          context: context,
                          title: "Deactivate Account",
                          message:
                              "Are you sure you want to deactivate this account? This action cannot be undone.",
                          confirmButtonText:
                              "Yes, Proceed", // <-- custom text
                          onDelete: () async {
                            
                            // Add your deactivation logic here
                          },
                        );
                      },
                    ),
                  ),
                  */
                ],
              ),
            ),

            // ADD YOUR FUTURE CONTENT HERE
          ],
        ),
      ),
    );
  }

  //▫️Helper Widget:
  // Row widget
  Widget buildRow(
    String title, {
    bool isLast = false,
    bool isLogout = false,
    VoidCallback? onTap,
  }) {
    Widget rowContent = Padding(
      padding: EdgeInsets.fromLTRB(
        28.0,
        isLogout ? 16 : 8,
        18.0,
        isLogout ? 16 : (isLast ? 20 : 8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              color: isLogout ? Colors.red : Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 15.3,
            ),
          ),
          isLogout
              ? Icon(Icons.logout, color: Colors.red, size: 23)
              : Icon(
                  Icons.chevron_right,
                  color: Colors.green.shade700,
                  size: 25,
                ),
        ],
      ),
    );

    if (onTap != null) {
      return Column(
        children: [
          InkWell(onTap: onTap, child: rowContent),
          if (!isLast && !isLogout)
            Divider(
              color: Colors.grey.shade300,
              thickness: 0.5,
              indent: 15,
              endIndent: 10,
            ),
        ],
      );
    } else {
      return Column(
        children: [
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
  }
}