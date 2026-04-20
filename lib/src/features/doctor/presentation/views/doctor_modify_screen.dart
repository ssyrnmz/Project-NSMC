import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

import '../viewmodels/doctor_modify_viewmodel.dart';
import '../viewmodels/doctor_view_viewmodel.dart';
import '../../domain/doctor.dart';
import '../../domain/speciality.dart';
import '../../domain/doctor_validators.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_success_dialogue.dart';
import '../../../../utils/ui/input_formatters.dart';

class ModifyDoctorScreen extends StatefulWidget {
  const ModifyDoctorScreen({super.key, required this.mode, this.doctor});

  final ScreenRole mode;
  final Doctor? doctor;

  @override
  State<ModifyDoctorScreen> createState() => _ModifyDoctorScreenState();
}

class _ModifyDoctorScreenState extends State<ModifyDoctorScreen> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>(); // Form key

  // Form inputs
  late TextEditingController _nameController;
  late TextEditingController _qualificationsController;
  late TextEditingController _specialistController;
  DoctorStatus? _residencyStatus;
  Speciality? _speciality;

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    final doctor = widget.doctor;

    // Initialize depending on edit existing info or adding new info
    if (doctor != null) {
      final vmInitial = context.read<DoctorViewModel>();

      _nameController = TextEditingController(text: doctor.name);
      _qualificationsController = TextEditingController(
        text: doctor.qualifications,
      );
      _specialistController = TextEditingController(
        text: doctor.specialization,
      );

      _residencyStatus =
          (doctor.status.compareTo(DoctorStatus.resident.value) == 0)
          ? DoctorStatus.resident
          : DoctorStatus.visiting;

      _speciality = vmInitial.getSpeciality(doctor.specialityId);
    } else {
      _nameController = TextEditingController();
      _qualificationsController = TextEditingController();
      _specialistController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _qualificationsController.dispose();
    _specialistController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vmModify = context.watch<DoctorModifyViewModel>();
    final vmData = context.watch<DoctorViewModel>();

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
              color: Color(0xFF6FBF73),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            (widget.mode == ScreenRole.add)
                ? 'Add New Doctor'
                : 'Edit Doctor Information',
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
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 15.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Doctor's Full Name
                    buildTextField(
                      " Full Name",
                      _nameController,
                      hintText: "Enter doctor's full name",
                      validator: (value) => DoctorValidators.isNameValid(value),
                      inputFormatter: [InputFormat.noLeadingWhitespace],
                    ),

                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 0.5,
                      indent: 3,
                      endIndent: 3,
                    ),

                    // Doctor's Specialization
                    buildTextField(
                      " Specialization",
                      _specialistController,
                      hintText: "Enter doctor's specialization",
                      validator: (value) =>
                          DoctorValidators.isSpecializationValid(value),
                      inputFormatter: [InputFormat.noLeadingWhitespace],
                    ),

                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 0.5,
                      indent: 3,
                      endIndent: 3,
                    ),

                    const SizedBox(height: 10),

                    // Doctor's Speciality
                    buildDropdownField(
                      " Select Doctor Speciality",
                      vmData.specialities,
                    ),

                    const SizedBox(height: 10),

                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 0.5,
                      indent: 3,
                      endIndent: 3,
                    ),

                    // Doctor Residency
                    Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            " Residency Status",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 20,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<DoctorStatus>(
                                    value: DoctorStatus.resident,
                                    groupValue: _residencyStatus,
                                    onChanged: (DoctorStatus? value) {
                                      setState(() {
                                        _residencyStatus = value;
                                      });
                                      FocusScope.of(context).unfocus();
                                    },
                                    activeColor: const Color(0xFF629E5C),
                                  ),
                                  Text(
                                    "Resident",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Radio<DoctorStatus>(
                                    value: DoctorStatus.visiting,
                                    groupValue: _residencyStatus,
                                    onChanged: (DoctorStatus? value) {
                                      setState(() {
                                        _residencyStatus = value;
                                      });
                                      FocusScope.of(context).unfocus();
                                    },
                                    activeColor: const Color(0xFF629E5C),
                                  ),
                                  Text(
                                    "Visiting",
                                    style: GoogleFonts.poppins(fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Divider(
                      color: Colors.grey.shade300,
                      thickness: 0.5,
                      indent: 3,
                      endIndent: 3,
                    ),

                    // Doctor qualifications
                    buildTextField(
                      "Education Background / Medical History",
                      _qualificationsController,
                      maxLines: 5,
                      hintText: "Enter the education and medical history here.",
                      validator: (value) =>
                          DoctorValidators.isQualificationsValid(value),
                      inputFormatter: [InputFormat.noLeadingWhitespace],
                    ),

                    const SizedBox(height: 40),

                    // Register Button
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FBF73),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 50),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onPressed: () async {
                          // Button's function to create add or edit doctor's details
                          // Create doctor's information
                          if (widget.mode == ScreenRole.add) {
                            if (_formKey.currentState!.validate() &&
                                _speciality != null &&
                                _residencyStatus != null) {
                              final saveData = Doctor(
                                id: 0,
                                name: _nameController.text,
                                status: _residencyStatus!.value,
                                qualifications: _qualificationsController.text,
                                specialization: _specialistController.text,
                                image: null,
                                specialityId: _speciality!.id,
                                archived: false,
                                updatedAt: DateTime.timestamp(),
                              );

                              final result = await vmModify.addDoctor(saveData);

                              if (!context.mounted) return;

                              if (result is Ok) {
                                showSuccessDialog(
                                  context: context,
                                  title: "Doctor Added!",
                                  message:
                                      "${saveData.name}'s information has been successfully created.",
                                  onButtonPressed: () {
                                    vmData.load();
                                    Navigator.of(context).popUntil((route) {
                                      return route.settings.name ==
                                              '/doctorList' ||
                                          route.isFirst;
                                    });
                                  },
                                );
                              } else {
                                showSnackBar(
                                  context: context,
                                  text:
                                      vmModify.message ??
                                      "An unknown error occured. Please try again.",
                                  color: Colors.red[900],
                                );
                              }
                            } else {
                              showSnackBar(
                                context: context,
                                text:
                                    "Your submission is unfinished or invalid, Please check and try again.",
                                color: Colors.red[900],
                              );
                            }
                          } // Edit doctor's information
                          else if (widget.mode == ScreenRole.edit) {
                            if (_formKey.currentState!.validate() &&
                                _speciality != null &&
                                _residencyStatus != null) {
                              // Doctor data with new details
                              final saveData = Doctor(
                                id: widget.doctor!.id,
                                name: _nameController.text.trim(),
                                status: _residencyStatus!.value,
                                qualifications: _qualificationsController.text
                                    .trim(),
                                specialization: _specialistController.text
                                    .trim(),
                                image: widget.doctor!.image,
                                specialityId: _speciality!.id,
                                archived: widget.doctor!.archived,
                                updatedAt: widget.doctor!.updatedAt,
                              );

                              final result = await vmModify.editDoctor(
                                saveData,
                              );

                              if (!context.mounted) return;

                              if (result is Ok) {
                                showSuccessDialog(
                                  context: context,
                                  title: "Doctor Updated!",
                                  message:
                                      "${saveData.name}'s information has been successfully updated.",
                                  onButtonPressed: () {
                                    vmData.load();
                                    Navigator.of(context).popUntil((route) {
                                      return route.settings.name ==
                                              '/doctorList' ||
                                          route.isFirst;
                                    });
                                  },
                                );
                              } else {
                                showSnackBar(
                                  context: context,
                                  text:
                                      vmModify.message ??
                                      "An unknown error occured. Please try again.",
                                  color: Colors.red[900],
                                );
                              }
                            } else {
                              showSnackBar(
                                context: context,
                                text:
                                    "Your submission is unfinished or invalid, Please check and try again.",
                                color: Colors.red[900],
                              );
                            }
                          } // No function if given none/wrong screen's role
                          else {
                            null;
                          }
                        },
                        child: Text(
                          (widget.mode == ScreenRole.add)
                              ? 'Register'
                              : 'Save Changes',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  //▫️Helper Widget:
  // Stylized text field
  Widget buildTextField(
    String label,
    TextEditingController controller, {
    int maxLines = 1,
    String? hintText,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatter,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: const Color(0xFF050505),
            ),
          ),

          const SizedBox(height: 8),

          TextFormField(
            controller: controller,
            maxLines: maxLines,
            validator: validator,
            inputFormatters: inputFormatter,
            decoration: InputDecoration(
              hintText: hintText,
              hintStyle: GoogleFonts.poppins(
                color: const Color(0xFF9E9E9E),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              filled: true,
              fillColor: Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF629E5C)),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.red),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: Colors.red.shade900),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Dropdown field
  Widget buildDropdownField(String label, List<Speciality> specialityOptions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 5),

        Text(
          label,
          textAlign: TextAlign.left,
          style: GoogleFonts.poppins(
            fontSize: 14,
            color: const Color(0xFF050505),
          ),
        ),

        const SizedBox(height: 5),

        LayoutBuilder(
          builder: (context, constraints) {
            return DropdownButtonHideUnderline(
              child: DropdownButton2<Speciality>(
                isExpanded: true,
                value: _speciality,
                hint: Text(
                  'Select specialization',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 15,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                items: specialityOptions.map((Speciality item) {
                  return DropdownMenuItem<Speciality>(
                    value: item,
                    child: Container(
                      width: constraints.maxWidth - 32, // Account for padding
                      child: Text(
                        item.name,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: const Color(0xFF050505),
                        ),
                        maxLines: 2, // Allow 2 lines
                        overflow: TextOverflow.ellipsis,
                        softWrap: true, // IMPORTANT: Enable text wrapping
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (Speciality? value) {
                  setState(() {
                    _speciality = value;
                  });
                },
                buttonStyleData: ButtonStyleData(
                  height: 52,
                  width: constraints.maxWidth,
                  padding: const EdgeInsets.only(left: 16, right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFE0E0E0),
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
                  maxHeight: 295,
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
                    thumbVisibility: MaterialStateProperty.all<bool>(true),
                  ),
                ),
                menuItemStyleData: const MenuItemStyleData(
                  height: 48, // Increase height to accommodate 2 lines
                  padding: EdgeInsets.only(left: 16, right: 16),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
