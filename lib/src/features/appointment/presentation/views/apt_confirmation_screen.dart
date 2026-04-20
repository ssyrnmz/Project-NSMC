import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/apt_confirm_warning_box.dart';
import 'apt_reschedule_screen.dart';
import '../viewmodels/apt_modify_viewmodel.dart';
import '../viewmodels/apt_view_viewmodel.dart';
import '../../domain/appointment.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../home/viewmodels/home_viewmodel.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/display_formatters.dart';
import '../../../../utils/ui/show_success_dialogue.dart';
import '../../../../utils/ui/show_snackbar.dart';

class ConfirmAppointmentScreen extends StatelessWidget {
  const ConfirmAppointmentScreen({super.key, required this.appointment});

  final Appointment appointment;

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vmModify = context.watch<AppointmentModifyViewModel>();
    final vmData = context.read<AppointmentViewModel>();
    final vmHome = context
        .read<HomeViewModel>(); // Affects admin's view in home screen

    return LoadingOverlay(
      isLoading: vmModify.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFf9fafb),
          elevation: 0,
          surfaceTintColor: const Color.fromARGB(255, 200, 200, 200),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Confirm Approval',
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
                //🔹Warning Box
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: ConfirmAppointmentWarningBox(role: session.role),
                ),

                const SizedBox(height: 5),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.only(left: 15.0),
                  child: Row(
                    children: [
                      Container(
                        width: 6,
                        height: 20,
                        decoration: BoxDecoration(
                          color: (session.role == UserRole.admin)
                              ? const Color(0xFF6C63FF)
                              : const Color.fromARGB(255, 255, 99, 99),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Appointment Confirmation',
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

                      if (session.role == UserRole.admin)
                        buildRow(
                          'Patient\'s Name',
                          subtitle: (() {
                            try { return vmData.getUser(appointment).fullName; }
                            catch (_) { return 'Patient'; }
                          })(),
                        ),

                      buildRow(
                        'Purpose of Appointment',
                        subtitle: appointment.purpose,
                      ),

                      buildRow('Appointment Type', subtitle: appointment.type),

                      buildRow(
                        'Selected Doctor',
                        subtitle:
                            vmData.getDoctor(appointment)?.name.toUpperCase() ??
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

                      buildRow(
                        'Inquiry',
                        subtitle:
                            appointment.inquiry ??
                            'No additional inquiry provided.',
                        isLast: false,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          const SizedBox(width: 15),

                          Expanded(
                            // Button to return (admin) or reschedule (user)
                            child: ElevatedButton(
                              onPressed: (session.role == UserRole.admin)
                                  ? () {
                                      Navigator.pop(context);
                                    }
                                  : () {
                                      Navigator.of(context).push(
                                        transitionAnimation(
                                          page: AuthWrappper(
                                            accessRole: UserRole.user,
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
                                (session.role == UserRole.admin)
                                    ? 'Return'
                                    : 'Reschedule',
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
                            // Button to approve (admin) or confirm (user) appointment
                            child: ElevatedButton(
                              onPressed: () async {
                                // Confirm/Approve appointment function
                                // Get user and doctor info for notification email
                                // Admin: get patient info from loaded users list
                                // User: get their own info from session
                                final sess = context.read<AccountSession>().session;
                                String notifEmail = '';
                                String notifName = '';
                                if (sess is AdminSession) {
                                  try {
                                    final aptUser = vmData.getUser(appointment);
                                    notifEmail = aptUser.email;
                                    notifName = aptUser.fullName;
                                  } catch (_) {}
                                } else if (sess is UserSession) {
                                  notifEmail = sess.userAccount.email;
                                  notifName = sess.userAccount.fullName;
                                }
                                final aptDoctor = vmData.getDoctor(appointment);

                                final result = await vmModify.confirmAppointment(
                                  appointment,
                                  userEmail: notifEmail,
                                  userName: notifName,
                                  doctorName: aptDoctor?.name ?? 'TBA',
                                );

                                switch (result) {
                                  case Ok():
                                    if (context.mounted) {
                                      showSuccessDialog(
                                        context: context,
                                        title: (session.role == UserRole.admin)
                                            ? "Appointment Approved!"
                                            : "Appointment Confirmed!",
                                        message:
                                            (session.role == UserRole.admin)
                                            ? (() {
                                                try { return "You have successfully approved \${vmData.getUser(appointment).fullName}'s appointment."; }
                                                catch (_) { return "Appointment approved successfully."; }
                                              })()
                                            : "You have successfully confirmed your appointment. Thank you.",
                                        onButtonPressed: () {
                                          vmData.load();
                                          vmHome.load();
                                          Navigator.of(context).popUntil((
                                            route,
                                          ) {
                                            return route.settings.name ==
                                                    '/appointmentListA' ||
                                                route.settings.name ==
                                                    '/appointmentListU' ||
                                                route.isFirst;
                                          });
                                        },
                                      );
                                    }
                                  case Error():
                                    if (context.mounted) {
                                      showSnackBar(
                                        context: context,
                                        text:
                                            vmModify.message ??
                                            "An unknown error occured. Please try again.",
                                        color: Colors.red[900],
                                      );
                                    }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF6FBF73),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 14,
                                ),
                                elevation: 0,
                              ),

                              // 👇 Spinner logic (same pattern as your working button)
                              child: Text(
                                (session.role == UserRole.admin)
                                    ? 'Approved'
                                    : 'Confirm',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(width: 15),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
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
