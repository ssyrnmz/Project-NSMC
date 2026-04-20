import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/apt_box.dart';
import 'apt_detail_screen.dart';
import '../viewmodels/apt_view_viewmodel.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/display_formatters.dart';

class AppointmentHistoryScreen extends StatelessWidget {
  const AppointmentHistoryScreen({super.key, required this.id});

  final String id;

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
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
            'History of Appointments',
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
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 16.0,
                    top: 16.0,
                    right: 20.0,
                    bottom: 10.0,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.history_rounded,
                        color: Color(0xFF6B8BCE),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Recently Attended',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF4A4A4A),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 1,
                          color: const Color(0xFFE0E0E0),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 10),

                // 🔹 Appointment boxes (dynamic)
                ...vm
                    .getHistoryAppointments(id)
                    .map(
                      (apt) => AppointmentBox(
                        date: DisplayFormat().date(apt.date),
                        time: DisplayFormat().timeRange(
                          apt.startTime,
                          apt.endTime,
                        ),
                        doctor: DisplayFormat().shortDoctorName(
                          vm.getDoctor(apt)?.name.toUpperCase() ?? 'Any Doctor',
                        ),
                        onTap: () async {
                          Navigator.of(context).push(
                            transitionAnimation(
                              page: AuthWrappper(
                                accessRole: UserRole.admin,
                                child: AppointmentDetailScreen(
                                  appointment: apt,
                                  advancedAccess: false,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
