import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'widgets/apt_awaiting_top_box.dart';
import 'widgets/apt_pending_top_box.dart';
import 'widgets/apt_box.dart';
import 'apt_detail_screen.dart';
import 'apt_confirmation_screen.dart';
import '../viewmodels/apt_view_viewmodel.dart';
import '../../domain/appointment.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/find_item_screen.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../core/widgets/no_feature_screen.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/display_formatters.dart';
import '../../../../utils/ui/show_snackbar.dart';

// Only used in this screen (if any other screens also use, add in global values file)
enum AppointmentStatus {
  confirmed('Upcoming'),
  approved('Awaiting Approval'),
  pending('Pending');

  final String display;
  const AppointmentStatus(this.display);
}

// Main Widget
class AppointmentTrackingViewScreen extends StatefulWidget {
  const AppointmentTrackingViewScreen({super.key});

  @override
  State<AppointmentTrackingViewScreen> createState() =>
      _AppointmentTrackingViewScreenState();
}

class _AppointmentTrackingViewScreenState
    extends State<AppointmentTrackingViewScreen>
    with SingleTickerProviderStateMixin {
  //▫️Variables:
  late TabController
  _tabController; // Tab controller (Upcoming, Awaiting, Pending)

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
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppointmentViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Appointment Tracking',
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: TabBar(
            controller: _tabController,
            indicatorColor: const Color(0xFF4D7C4A),
            indicatorWeight: 3,
            labelColor: const Color(0xFF4D7C4A),
            unselectedLabelColor: Colors.grey,
            labelStyle: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            unselectedLabelStyle: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w400,
            ),
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'To Confirm'),
              Tab(text: 'Pending'),
            ],
          ),
        ),
        // Follow the tabs above
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildTabContent(context, AppointmentStatus.confirmed, vm),
            _buildTabContent(context, AppointmentStatus.approved, vm),
            _buildTabContent(context, AppointmentStatus.pending, vm),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent(
    BuildContext context,
    AppointmentStatus type,
    AppointmentViewModel vm,
  ) {
    final selectedAppointments = context
        .select<AppointmentViewModel, List<Appointment>>((vm) {
          switch (type) {
            case AppointmentStatus.confirmed:
              return vm.upcoming;
            case AppointmentStatus.approved:
              return vm.approved;
            case AppointmentStatus.pending:
              return vm.pending;
          }
        });

    return SingleChildScrollView(
      child: (selectedAppointments.isNotEmpty)
          ? Column(
              children: [
                const SizedBox(height: 10),

                //🔹Search bar with FindItemScreen navigation
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: SearchBarWidget(
                      hintText:
                          'Search for ${type.display.toLowerCase()} appointment',
                      onTapped: () {
                        Navigator.of(context).push(
                          transitionAnimation(
                            page: FindItemScreen(
                              hintText:
                                  'Search for your ${type.display.toLowerCase()} appointment',
                              items: vm.createSearchList(selectedAppointments),
                              leadingIcon: Icons.calendar_today,
                              onItemSelected: (value) {
                                Navigator.pop(
                                  context,
                                ); // Close the search screen

                                final appointment = vm.getAppointment(value);

                                if (appointment != null) {
                                  Navigator.of(context).push(
                                    transitionAnimation(
                                      page: AuthWrappper(
                                        accessRole: UserRole.user,
                                        child: AppointmentDetailScreen(
                                          appointment: appointment,
                                          advancedAccess: false,
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            type: TransitionOption.vertical,
                          ),
                        );
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 0),

                //🔸Show PendingNotiBox ONLY on Pending tab
                if (type == AppointmentStatus.pending) const PendingTopBox(),
                if (type == AppointmentStatus.approved) const AwaitingTopBox(),

                const SizedBox(height: 0),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 9,
                  ),
                  child: Divider(
                    color: const Color.fromARGB(255, 232, 232, 232),
                    thickness: 1.0,
                  ),
                ),

                //🔹Appointment boxes (dynamic)
                for (Appointment apt in selectedAppointments)
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                    child: AppointmentBox(
                      date: DisplayFormat().date(apt.date),
                      time: DisplayFormat().timeRange(
                        apt.startTime,
                        apt.endTime,
                      ),
                      doctor: DisplayFormat().shortDoctorName(
                        vm.getDoctor(apt)?.name.toUpperCase() ?? 'Any Doctor',
                      ),
                      onTap: () {
                        if (type == AppointmentStatus.approved) {
                          Navigator.of(context).push(
                            transitionAnimation(
                              page: AuthWrappper(
                                accessRole: UserRole.user,
                                child: ConfirmAppointmentScreen(
                                  appointment: apt,
                                ),
                              ),
                            ),
                          );
                        } else {
                          Navigator.of(context).push(
                            transitionAnimation(
                              page: AuthWrappper(
                                accessRole: UserRole.user,
                                child: AppointmentDetailScreen(
                                  appointment: apt,
                                  advancedAccess: false,
                                ),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                const SizedBox(height: 50),
              ],
            )
          : ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height * 0.6,
              ),
              child: NoFeatureScreen(screenFeature: Feature.appointmentU),
            ),
    );
  }
}
