import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/apt_requested_top_box.dart';
import 'apt_confirmation_screen.dart';
import 'apt_history_screen.dart';
import 'apt_reschedule_screen.dart';
import '../viewmodels/apt_view_viewmodel.dart';
import '../../domain/appointment.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/display_formatters.dart';

class AppointmentDetailScreen extends StatelessWidget {
  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
    required this.advancedAccess,
  });

  final Appointment appointment;
  final bool advancedAccess; // Allow/Disable admin's ability to edit or confirm

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vm = context.read<AppointmentViewModel>();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      appBar: AppBar(
        backgroundColor: const Color(0xFFf9fafb),
        elevation: 0,
        surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF4D7C4A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Appointment Details',
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

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          physics: const ClampingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display patient's name of the appointment (admin only)
              if (session.role == UserRole.admin && advancedAccess == true)
                SizedBox(
                  height: 90,
                  child: AppointmentRequestedTopBox(
                    appointment: appointment,
                    name: DisplayFormat().shortUserName(
                      (() {
                        try { return vm.getUser(appointment).fullName; }
                        catch (_) { return 'Patient'; }
                      })(),
                    ),
                    onTap: (apt) {
                      Navigator.of(context).push(
                        transitionAnimation(
                          page: AuthWrappper(
                            accessRole: UserRole.admin,
                            child: AppointmentHistoryScreen(id: apt.userId),
                          ),
                        ),
                      );
                    },
                  ),
                ),

              SizedBox(
                height:
                    (session.role == UserRole.admin && advancedAccess == true)
                    ? 12
                    : 20,
              ),

              Padding(
                padding: const EdgeInsets.only(left: 15.0),
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
                      'Appointment Details',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                        fontSize: 15.8,
                      ),
                    ),
                  ],
                ),
              ),

              //🔹Appointment details section
              Container(
                width: double.infinity,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),

                    const SizedBox(height: 15),
                    buildRow(
                      'Purpose of Appointment',
                      subtitle: appointment.purpose,
                    ),
                    buildRow('Appointment Type', subtitle: appointment.type),
                    buildRow(
                      'Selected Doctor',
                      subtitle:
                          vm.getDoctor(appointment)?.name.toUpperCase() ??
                          'Any Doctor',
                    ),
                    buildRow(
                      'Preferred Date',
                      subtitle: DisplayFormat().date(appointment.date),
                    ),
                    buildRow(
                      'Preferred Time',
                      subtitle: DisplayFormat().timeRange(
                        appointment.startTime,
                        appointment.endTime,
                      ),
                    ),
                    buildRow('Visit Type', subtitle: appointment.visitType),

                    buildRow('Status', subtitle: appointment.status),

                    buildRow(
                      'Inquiry',
                      subtitle:
                          appointment.inquiry ??
                          'No additional inquiry provided.',
                      isLast: false,
                    ),

                    if (session.role == UserRole.admin &&
                        advancedAccess == true) ...[
                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const SizedBox(width: 15),

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  transitionAnimation(
                                    page: AuthWrappper(
                                      accessRole: UserRole.admin,
                                      child: AppointmentEditScreen(
                                        appointment: appointment,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF607D8B,
                                ), // muted blue-grey
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                //elevation: 3,
                                shadowColor: Colors.black26,
                              ),
                              child: Text(
                                'Edit',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(
                            width: 12,
                          ), // small gap between buttons

                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  transitionAnimation(
                                    page: AuthWrappper(
                                      accessRole: UserRole.admin,
                                      child: ConfirmAppointmentScreen(
                                        appointment: appointment,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(
                                  0xFF6FBF73,
                                ), // keep green
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                //elevation: 3,
                                shadowColor: Colors.black26,
                              ),
                              child: Text(
                                'Proceed',
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
        15.0,
        isLogout ? 16 : 8,
        18.0,
        isLogout ? 16 : (isLast ? 20 : 8),
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
              if (isLogout)
                const Icon(Icons.logout, color: Colors.red, size: 23),
            ],
          ),
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
}
