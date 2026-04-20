import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'widgets/apt_card.dart';
import 'apt_detail_screen.dart';
import '../viewmodels/apt_view_viewmodel.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../core/widgets/no_feature_screen.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/display_formatters.dart';
import '../../../../utils/ui/show_snackbar.dart';

class AppointmentRequestedScreen extends StatefulWidget {
  const AppointmentRequestedScreen({super.key});

  @override
  State<AppointmentRequestedScreen> createState() =>
      _AppointmentRequestedScreenState();
}

class _AppointmentRequestedScreenState
    extends State<AppointmentRequestedScreen> {
  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vmInitial = context.read<AppointmentViewModel>();
      final result = await vmInitial.load();

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
    final vm = context.watch<AppointmentViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        appBar: AppBar(
          backgroundColor: const Color(0xFFf9fafb),
          elevation: 0.8,
          shadowColor: Colors.grey.withOpacity(0.2),
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Requested Appointments',
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

        body: (vm.pending.isNotEmpty)
            ? ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  Row(
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
                        'Awaiting Approval',
                        style: GoogleFonts.poppins(
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Wrap(
                    spacing: 10,
                    children: [
                      ChoiceChip(
                        label: Text(
                          'Newest to Oldest',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        selected: vm.currentSort,
                        onSelected: (selected) {
                          if (!vm.currentSort) {
                            vm.sortAppointments();
                          }
                        },
                        selectedColor: const Color(
                          0xFF6C63FF,
                        ).withOpacity(0.15),
                        backgroundColor: const Color(0xFFF1F3FF),
                        labelStyle: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      ChoiceChip(
                        label: Text(
                          'Oldest to Newest',
                          style: GoogleFonts.poppins(fontSize: 13),
                        ),
                        selected: !vm.currentSort,
                        onSelected: (selected) {
                          if (vm.currentSort) {
                            vm.sortAppointments();
                          }
                        },
                        selectedColor: const Color(
                          0xFF6C63FF,
                        ).withOpacity(0.15),
                        backgroundColor: const Color(0xFFF1F3FF),
                        labelStyle: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),
                  // Flattened list: show all appointments
                  ...vm.pending.map((apt) {
                    return AppointmentCard(
                      name: (() {
                        try { return vm.getUser(apt).fullName; }
                        catch (_) { return 'Patient'; }
                      })(),
                      date: DisplayFormat().date(apt.date),
                      time: DisplayFormat().timeRange(
                        apt.startTime,
                        apt.endTime,
                      ),
                      doctor:
                          vm.getDoctor(apt)?.name.toUpperCase() ?? 'Any Doctor',
                      onTap: () {
                        Navigator.of(context).push(
                          transitionAnimation(
                            page: AuthWrappper(
                              accessRole: UserRole.admin,
                              child: AppointmentDetailScreen(
                                appointment: apt,
                                advancedAccess: true,
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }),
                ],
              )
            : SingleChildScrollView(
                child: NoFeatureScreen(screenFeature: Feature.appointmentA),
              ),
      ),
    );
  }
}
