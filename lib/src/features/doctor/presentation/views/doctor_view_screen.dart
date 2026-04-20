import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'doctor_detail_view_screen.dart';
import 'doctor_modify_screen.dart';
import 'doctor_select_screen.dart';
import 'widgets/doctor_box_displays.dart';
import 'widgets/manage_doctor_button.dart';
import '../viewmodels/doctor_view_viewmodel.dart';
import '../../../authentication/data/account_session.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/find_item_screen.dart';
import '../../../../core/widgets/search_bar.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_snackbar.dart';

class DoctorViewScreen extends StatefulWidget {
  const DoctorViewScreen({super.key});

  @override
  State<DoctorViewScreen> createState() => _DoctorViewScreenState();
}

class _DoctorViewScreenState extends State<DoctorViewScreen> {
  //▫️State initialization:
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vmInitial = context.read<DoctorViewModel>();
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
    final session = context.watch<AccountSession>();
    final vm = context.watch<DoctorViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFf9fafb),
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: (session.role == UserRole.admin) ? false : true,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Specialities',
                style: GoogleFonts.poppins(
                  color: const Color(0xFF1E1E1E),
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),

              // Management button — Admin/SuperAdmin only (not Receptionist)
              if (session.role == UserRole.admin && session.isFullAdmin)
                ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 40),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: ManagementDoctorButton(
                      onAdd: () {
                        Navigator.of(context).push(
                          transitionAnimation(
                            page: AuthWrappper(
                              accessRole: UserRole.admin,
                              child: ModifyDoctorScreen(mode: ScreenRole.add),
                            ),
                          ),
                        );
                      },
                      onEdit: () {
                        Navigator.of(context).push(
                          transitionAnimation(
                            page: AuthWrappper(
                              accessRole: UserRole.admin,
                              child: SelectDoctorScreen(mode: ScreenRole.edit),
                            ),
                          ),
                        );
                      },
                      onDelete: () {
                        Navigator.of(context).push(
                          transitionAnimation(
                            page: AuthWrappper(
                              accessRole: UserRole.admin,
                              child: SelectDoctorScreen(
                                mode: ScreenRole.delete,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(1),
            child: Divider(height: 1, color: Color(0xFFE6E6E6)),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // 🔹 Search bar
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  width: double.infinity,
                  child: SearchBarWidget(
                    hintText: 'Search our doctors',
                    onTapped: () {
                      Navigator.of(context).push(
                        transitionAnimation(
                          page: FindItemScreen(
                            hintText: 'Search for a doctor',
                            items: vm.searchList,
                            leadingIcon: Icons.medical_services,
                            circleColor: Colors.blue,
                            onItemSelected: (value) {
                              Navigator.pop(context); // Close the search screen

                              final speciality = vm.getSpeciality(value);

                              if (speciality != null) {
                                Navigator.of(context).push(
                                  transitionAnimation(
                                    page: AuthWrappper(
                                      accessRole: session.role,
                                      child: DoctorDetailViewScreen(
                                        speciality: speciality,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                showSnackBar(
                                  context: context,
                                  text: "Doctor cannot be found.",
                                  color: Colors.red[900],
                                );
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              const SizedBox(height: 10),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 35.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(thickness: 0.5, color: Colors.grey[400]),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Text(
                        'Or browse by speciality',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(thickness: 0.5, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              DoctorBoxView(role: session.role),
            ],
          ),
        ),
      ),
    );
  }
}
