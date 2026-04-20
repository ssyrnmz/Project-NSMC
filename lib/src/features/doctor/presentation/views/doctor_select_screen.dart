import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

import 'doctor_modify_screen.dart';
import '../viewmodels/doctor_modify_viewmodel.dart';
import '../viewmodels/doctor_view_viewmodel.dart';
import '../../domain/doctor.dart';
import '../../domain/speciality.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/account_checker.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_delete_confirmation_dialogue.dart';
import '../../../../utils/ui/show_snackbar.dart';

class SelectDoctorScreen extends StatefulWidget {
  const SelectDoctorScreen({super.key, required this.mode});

  final ScreenRole mode;

  @override
  State<SelectDoctorScreen> createState() => _SelectDoctorScreenState();
}

class _SelectDoctorScreenState extends State<SelectDoctorScreen> {
  //▫️Variables:
  Speciality? _selectedSpeciality;
  Doctor? _selectedDoctor;

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vmModify = context.watch<DoctorModifyViewModel>();
    final vmData = context.watch<DoctorViewModel>();

    return LoadingOverlay(
      isLoading: vmModify.isLoading || vmData.isLoading,
      loadingIndicator: vmData.isLoading ? false : true,
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
              color: Color(0xFF6FBF73),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Select Doctor Information',
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 30.0,
                vertical: 20.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  Text(
                    ' Select Doctor Specialization',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF050505),
                    ),
                  ),

                  const SizedBox(height: 10),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton2<Speciality>(
                          isExpanded: true,
                          value: _selectedSpeciality,
                          hint: Text(
                            'Select specialization',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          items: vmData.specialities.map((Speciality item) {
                            return DropdownMenuItem<Speciality>(
                              value: item,
                              child: SizedBox(
                                width:
                                    constraints.maxWidth -
                                    32, // Account for padding
                                child: Text(
                                  item.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2, // Allow 2 lines
                                  overflow: TextOverflow.ellipsis,
                                  softWrap:
                                      true, // IMPORTANT: Enable text wrapping
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Speciality? value) {
                            if (value != null) {
                              setState(() {
                                _selectedSpeciality = value;
                                _selectedDoctor =
                                    null; // Reset if there was a value
                              });
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 52,
                            width: constraints.maxWidth,
                            padding: const EdgeInsets.only(left: 16, right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xffefefef),
                                width: 1.5,
                              ),
                              color: Colors.white,
                            ),
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[700],
                              size: 28,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 400,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            offset: const Offset(0, -8),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all<double>(4),
                              thumbVisibility: MaterialStateProperty.all<bool>(
                                true,
                              ),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height:
                                48, // Increase height to accommodate 2 lines
                            padding: EdgeInsets.only(left: 16, right: 16),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 5),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                    child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    ' Select Doctor',
                    textAlign: TextAlign.left,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: const Color(0xFF050505),
                    ),
                  ),

                  const SizedBox(height: 10),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      return DropdownButtonHideUnderline(
                        child: DropdownButton2<Doctor>(
                          isExpanded: true,
                          value: _selectedDoctor,
                          hint: Text(
                            'Select doctor',
                            style: GoogleFonts.poppins(
                              color: const Color(0xFF9E9E9E),
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          items: vmData.doctorList(_selectedSpeciality).map((
                            Doctor item,
                          ) {
                            return DropdownMenuItem<Doctor>(
                              value: item,
                              child: SizedBox(
                                width:
                                    constraints.maxWidth -
                                    32, // Account for padding
                                child: Text(
                                  item.name.toUpperCase(),
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  maxLines: 2, // Allow 2 lines
                                  overflow: TextOverflow.ellipsis,
                                  softWrap:
                                      true, // IMPORTANT: Enable text wrapping
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (Doctor? value) {
                            if (value != null) {
                              setState(() {
                                _selectedDoctor = value;
                              });
                            }
                          },
                          buttonStyleData: ButtonStyleData(
                            height: 52,
                            width: constraints.maxWidth,
                            padding: const EdgeInsets.only(left: 16, right: 12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: const Color(0xffefefef),
                                width: 1.5,
                              ),
                              color: Colors.white,
                            ),
                          ),
                          iconStyleData: IconStyleData(
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Colors.grey[700],
                              size: 28,
                            ),
                          ),
                          dropdownStyleData: DropdownStyleData(
                            maxHeight: 400,
                            width: constraints.maxWidth,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            offset: const Offset(0, -8),
                            scrollbarTheme: ScrollbarThemeData(
                              radius: const Radius.circular(40),
                              thickness: MaterialStateProperty.all<double>(4),
                              thumbVisibility: MaterialStateProperty.all<bool>(
                                true,
                              ),
                            ),
                          ),
                          menuItemStyleData: const MenuItemStyleData(
                            height:
                                48, // Increase height to accommodate 2 lines
                            padding: EdgeInsets.only(left: 16, right: 16),
                          ),
                        ),
                      );
                    },
                  ),

                  // Added button to complete the page
                  const SizedBox(height: 40),

                  Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (widget.mode == ScreenRole.delete)
                            ? const Color(0xFFD32F2F)
                            : const Color(0xFF6FBF73),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          //horizontal: 100,
                          vertical: 16,
                        ),
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        //elevation: 4,
                      ),
                      onPressed: () {
                        final selected = _selectedDoctor;

                        // Change function based on the screen's role
                        if (widget.mode == ScreenRole.delete) {
                          // Delete Function - Delete Doctor
                          if (selected != null) {
                            setState(() {
                              _selectedDoctor = null;
                              _selectedSpeciality = null;
                            });

                            showDeleteConfirmationDialog(
                              context: context,
                              title: "Deactivate Doctor",
                              message:
                                  "Are you sure you want to deactivate ${selected.name} information? This action cannot be undone.",
                              confirmButtonText: "Yes, Deactivate",
                              successTitle: "Doctor Deactivated!",
                              successMessage:
                                  "${selected.name}’s information has successfully been archived.",
                              onDelete: () async {
                                final result = await vmModify.deleteDoctor(
                                  selected,
                                );

                                if (!context.mounted) return;

                                if (result is Error) {
                                  showSnackBar(
                                    context: context,
                                    text:
                                        vmModify.message ??
                                        "An unknown error occured. Please try again.",
                                    color: Colors.red[900],
                                  );
                                }
                              },
                              whenDelete: () async {
                                final result = await vmData.load();

                                if (!context.mounted) return;

                                if (result is Error) {
                                  showSnackBar(
                                    context: context,
                                    text:
                                        vmData.message ??
                                        "An unknown error occured. Please try again.",
                                    color: Colors.red[900],
                                  );
                                }
                                /*
                                Navigator.pushReplacement(
                                  context,
                                  transitionAnimation(
                                    page: const AuthWrappper(
                                      accessRole: UserRole.admin,
                                      child: SelectDoctorScreen(
                                        mode: ScreenRole.delete,
                                      ),
                                    ),
                                    type: TransitionOption.scaled,
                                  ),
                                );*/
                              },
                            );
                          } else {
                            showSnackBar(
                              context: context,
                              text: "No doctor selected for deletion.",
                            );
                          }
                        } else if (widget.mode == ScreenRole.edit) {
                          // Edit Function - Go to Edit Page (with Doctor's Value)
                          if (selected != null) {
                            Navigator.of(context).push(
                              transitionAnimation(
                                page: AuthWrappper(
                                  accessRole: UserRole.admin,
                                  child: ModifyDoctorScreen(
                                    mode: ScreenRole.edit,
                                    doctor: selected,
                                  ),
                                ),
                              ),
                            );
                          } else {
                            showSnackBar(
                              context: context,
                              text: "No doctor selected for editting.",
                            );
                          }
                        } else {
                          // Null
                          null;
                        }
                      },
                      child: Text(
                        (widget.mode == ScreenRole.delete)
                            ? 'Deactivate Doctor'
                            : 'Proceed',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
