import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../contact_us_screen.dart';
import '../../../appointment/presentation/views/apt_booking_screen.dart';
import '../../../appointment/presentation/views/apt_tracking_screen.dart';
import '../../../appointment/presentation/views/apt_requested_screen.dart';
import '../../../doctor/presentation/views/doctor_view_screen.dart';
import '../../../health_screening/presentation/views/hsp_view_screen.dart';
import '../../../medical_record/presentation/views/mr_view_screen.dart';
import '../../../profile/viewmodels/patient_viewmodel.dart';
import '../../../profile/views/patient_details_screen.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/find_item_screen.dart';
import '../../../../core/widgets/icon_box_container.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../authentication/data/account_session.dart';
import '../../../appointment/presentation/views/holiday_management_screen.dart';
import '../../../prescription/presentation/views/presc_management_screen.dart';

class ServicesBox extends StatelessWidget {
  const ServicesBox({super.key, required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PatientViewModel>();
    final session = context.read<AccountSession>();

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    double scaleWidth(double w) => w / 400 * screenWidth;
    double scaleHeight(double h) => h / 800 * screenHeight;

    // isFullAdmin = Admin or SuperAdmin (not Receptionist)
    final isFullAdmin = role == UserRole.admin && session.isFullAdmin;

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: screenWidth * 0.03,
      crossAxisSpacing: screenWidth * 0.03,
      padding: EdgeInsets.all(screenWidth * 0.06),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: role == UserRole.admin
          //🔹 Admin Service Boxes
          ? [
              // All admins — Requested Appointments
              boxContainer(
                text: 'Requested \nAppointments',
                svgAsset: 'assets/svg/RA4.svg',
                iconWidth: scaleWidth(35),
                iconHeight: scaleHeight(65),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.admin,
                        child: const AppointmentRequestedScreen(),
                      ),
                      route: const RouteSettings(name: '/appointmentListA'),
                    ),
                  );
                },
              ),

              // All admins — Our Doctor (view only for Receptionist)
              boxContainer(
                text: 'Our Doctor',
                svgAsset: 'assets/svg/dp1.svg',
                iconWidth: scaleWidth(42),
                iconHeight: scaleHeight(67),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.admin,
                        child: const DoctorViewScreen(),
                      ),
                      route: const RouteSettings(name: '/doctorList'),
                    ),
                  );
                },
              ),

              // All admins — Patient Details (view only for Receptionist)
              boxContainer(
                text: 'Patient Details',
                svgAsset: 'assets/svg/medrep2.svg',
                iconWidth: scaleWidth(65),
                iconHeight: scaleHeight(70),
                onTap: () async {
                  final result = await vm.load();
                  if (!context.mounted) return;
                  if (result is Error) {
                    showSnackBar(
                      context: context,
                      text: vm.message ?? "An unknown error occured. Please try again.",
                      color: Colors.red[900],
                    );
                    return;
                  }
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: FindItemScreen(
                        hintText: "Search for patient",
                        items: vm.searchList,
                        leadingIcon: Icons.person,
                        circleColor: Colors.green,
                        iconColor: Colors.white,
                        onItemSelected: (value) async {
                          Navigator.pop(context);
                          final patient = vm.getPatient(value);
                          if (patient != null) {
                            Navigator.of(context).push(
                              transitionAnimation(
                                page: AuthWrappper(
                                  accessRole: UserRole.admin,
                                  child: PatientDetailsScreen(patient: patient),
                                ),
                              ),
                            );
                          }
                        },
                      ),
                    ),
                  );
                },
              ),

              // All admins — Health Packages (view only for Receptionist)
              boxContainer(
                text: 'Health Packages',
                svgAsset: 'assets/svg/hp3.svg',
                iconWidth: scaleWidth(47),
                iconHeight: scaleHeight(76),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.admin,
                        child: const HealthScreeningViewScreen(),
                      ),
                      route: const RouteSettings(name: '/packageList'),
                    ),
                  );
                },
              ),


              // Admin/SuperAdmin only — Manage Holidays
              if (isFullAdmin)
                boxContainer(
                  text: 'Manage \nHolidays',
                  svgAsset: 'assets/svg/RA4.svg',
                  iconWidth: scaleWidth(35),
                  iconHeight: scaleHeight(65),
                  onTap: () {
                    Navigator.of(context).push(
                      transitionAnimation(
                        page: AuthWrappper(
                          accessRole: UserRole.admin,
                          child: const HolidayManagementScreen(),
                        ),
                      ),
                    );
                  },
                ),
            ]
          //🔹 User Service Boxes
          : [
              boxContainer(
                text: 'Request Appointment',
                svgAsset: 'assets/svg/RA4.svg',
                iconWidth: scaleWidth(42),
                iconHeight: scaleHeight(72),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.user,
                        child: const AppointmentBookingScreen(),
                      ),
                    ),
                  );
                },
              ),
              boxContainer(
                text: 'Our Doctor',
                svgAsset: 'assets/svg/dp1.svg',
                iconWidth: scaleWidth(42),
                iconHeight: scaleHeight(67),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.user,
                        child: const DoctorViewScreen(),
                      ),
                      route: const RouteSettings(name: '/doctorList'),
                    ),
                  );
                },
              ),
              boxContainer(
                text: 'Medical Report',
                svgAsset: 'assets/svg/medrep2.svg',
                iconWidth: scaleWidth(65),
                iconHeight: scaleHeight(70),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.user,
                        child: const MedicalRecordViewScreen(),
                      ),
                    ),
                  );
                },
              ),
              boxContainer(
                text: 'Appointment Tracking',
                svgAsset: 'assets/svg/at4.svg',
                iconWidth: scaleWidth(40),
                iconHeight: scaleHeight(68),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.user,
                        child: const AppointmentTrackingViewScreen(),
                      ),
                      route: const RouteSettings(name: '/appointmentListU'),
                    ),
                  );
                },
              ),
              boxContainer(
                text: 'Prescription',
                svgAsset: 'assets/svg/med5.svg',
                iconWidth: scaleWidth(35),
                iconHeight: scaleHeight(65),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.user,
                        child: const PrescManagementScreen(),
                      ),
                    ),
                  );
                },
              ),
              boxContainer(
                text: 'Health Screening',
                svgAsset: 'assets/svg/hp3.svg',
                iconWidth: scaleWidth(47),
                iconHeight: scaleHeight(76),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.user,
                        child: const HealthScreeningViewScreen(),
                      ),
                      route: const RouteSettings(name: '/packageList'),
                    ),
                  );
                },
              ),
              boxContainer(
                text: 'Contact Us',
                svgAsset: 'assets/svg/ctcus2.svg',
                iconWidth: scaleWidth(47),
                iconHeight: scaleHeight(73),
                onTap: () {
                  Navigator.of(context).push(
                    transitionAnimation(
                      page: AuthWrappper(
                        accessRole: UserRole.user,
                        child: const ContactUsScreen(),
                      ),
                    ),
                  );
                },
              ),
            ],
    );
  }
}
