import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

import 'widget/edit_personal_box.dart';
import '../../authentication/data/account_session.dart';
import '../../authentication/domain/user.dart';
import '../../authentication/presentation/viewmodels/auth_account_viewmodel.dart';
import '../../../config/constants/global_values.dart';
import '../../../core/widgets/loading_screen.dart';
import '../../../utils/data/results.dart';
import '../../../utils/ui/display_formatters.dart';
import '../../../utils/ui/show_snackbar.dart';
import '../../../utils/ui/show_success_dialogue.dart';

class EditPersonalInfoScreen extends StatefulWidget {
  const EditPersonalInfoScreen({super.key, required this.patientUser});

  final User patientUser;

  @override
  State<EditPersonalInfoScreen> createState() => _EditPersonalInfoScreenState();
}

class _EditPersonalInfoScreenState extends State<EditPersonalInfoScreen> {
  //▫️Variables:

  // TextField Controllers (For viewing)
  final _nameController = TextEditingController();
  final _dobController = TextEditingController();
  final _nricController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  // Can delete later (Use Nationality & Gender value instead)
  final _nationalityController = TextEditingController();
  final _genderController = TextEditingController();

  // TextField Controllers (For editting)
  final _raceController = TextEditingController();
  final _religionController = TextEditingController();
  final _occupationController = TextEditingController();
  final _addressController = TextEditingController();

  String? _race;
  String? _religion;
  String? _occupation;

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();

    final patient = widget.patientUser;
    _nameController.text = patient.fullName;
    _nricController.text = patient.icNumber;
    _dobController.text = DisplayFormat().dateSlash(patient.birthDate);
    _emailController.text = patient.email;
    _phoneController.text = patient.phoneNumber;
    _nationalityController.text = patient.nationality;
    _genderController.text = patient.gender;
    _raceController.text = patient.race ?? '';
    _religionController.text = patient.religion ?? '';
    _occupationController.text = patient.occupation ?? '';
    _addressController.text = patient.homeAddress ?? '';

    _race = patient.race;
    _religion = patient.religion;
    _occupation = patient.occupation;
  }

  @override
  void dispose() {
    // Dispose all controllers when done
    _nameController.dispose();
    _nricController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _nationalityController.dispose();
    _genderController.dispose();
    _raceController.dispose();
    _religionController.dispose();
    _occupationController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vm = context.watch<AuthenticationAccountViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          backgroundColor: const Color(0xFFFFFFFF),
          elevation: 0,
          surfaceTintColor: const Color.fromARGB(235, 165, 165, 165),
          centerTitle: true,
          title: Text(
            'Edit Personal Details',
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
          physics: const ClampingScrollPhysics(),
          child: Center(
            child: Column(
              children: [
                //import 'package:flutter_application_2/src/common_widgets/widgets/editPersonalDetails_notiBox.dart';
                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.only(
                    left: 18.0,
                    right: 18.0,
                    bottom: 10.0,
                  ),
                  child: const EditPersonalDetailsBox(),
                ),

                const SizedBox(height: 5),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                  child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                ),

                const SizedBox(height: 0),

                inputField(_nameController, 'Full Name'),

                const SizedBox(height: 5),

                inputField(
                  _nationalityController,
                  'Nationality',
                  readOnly: true,
                ),

                // Use dropdown below if nationality can be editted
                /*
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Nationality selectedValue =
                          (patient.nationality == "malaysian")
                          ? Nationality.malaysian
                          : Nationality.nonMalaysian;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label (same as choiceFields)
                          Text(
                            'Nationality',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 6),

                          DropdownButtonHideUnderline(
                            child: DropdownButton2<Nationality>(
                              isExpanded: true,
                              value: selectedValue,
                              hint: Text(
                                'Select nationality',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF9E9E9E),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),

                              // 🔒 SAME BACKEND ITEMS
                              items: Nationality.values.map((v) {
                                return DropdownMenuItem<Nationality>(
                                  value: v,
                                  child: SizedBox(
                                    width: constraints.maxWidth - 32,
                                    child: Text(
                                      v.displayText,
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: const Color.fromARGB(
                                          255,
                                          5,
                                          5,
                                          5,
                                        ),
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true,
                                    ),
                                  ),
                                );
                              }).toList(),

                              // 🔒 SAME BACKEND SETTER
                              onChanged: (Nationality? value) {
                                setState(() {
                                  nationality = value;
                                });
                              },

                              // 🎨 Button UI
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: constraints.maxWidth,
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
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

                              // 🎨 Dropdown UI
                              dropdownStyleData: DropdownStyleData(
                                maxHeight: 300,
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
                                  thickness: MaterialStateProperty.all<double>(
                                    4,
                                  ),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),

                              menuItemStyleData: const MenuItemStyleData(
                                height: 48,
                                padding: EdgeInsets.only(left: 16, right: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
                */
                const SizedBox(height: 5),

                inputField(
                  _nricController,
                  'NRIC/Passport Number',
                  readOnly: true,
                ),

                const SizedBox(height: 0),

                inputField(_dobController, 'Date of Birth', readOnly: true),

                const SizedBox(height: 5),

                inputField(_genderController, 'Gender', readOnly: true),

                // Use dropdown below if gender can be editted
                /*
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final Gender selectedValue = (patient.gender == "male")
                          ? Gender.male
                          : Gender.female;

                      return Padding(
                        padding: const EdgeInsets.only(left: 0.0, right: 0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Label
                            Text(
                              'Gender',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),

                            const SizedBox(height: 6),

                            DropdownButtonHideUnderline(
                              child: DropdownButton2<Gender>(
                                isExpanded: true,
                                value: selectedValue,
                                hint: Text(
                                  'Select gender',
                                  style: GoogleFonts.poppins(
                                    color: const Color(0xFF9E9E9E),
                                    fontSize: 14,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),

                                // 🔒 SAME BACKEND ITEMS
                                items: Gender.values.map((v) {
                                  return DropdownMenuItem<Gender>(
                                    value: v,
                                    child: SizedBox(
                                      width: constraints.maxWidth - 32,
                                      child: Text(
                                        v.displayText,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: const Color.fromARGB(
                                            255,
                                            5,
                                            5,
                                            5,
                                          ),
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                      ),
                                    ),
                                  );
                                }).toList(),

                                // 🔒 SAME BACKEND SETTER
                                onChanged: (Gender? value) {
                                  setState(() {
                                    gender = value;
                                  });
                                },

                                // 🎨 Button UI
                                buttonStyleData: ButtonStyleData(
                                  height: 50,
                                  width: constraints.maxWidth,
                                  padding: const EdgeInsets.only(
                                    left: 16,
                                    right: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
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

                                // 🎨 Dropdown UI
                                dropdownStyleData: DropdownStyleData(
                                  maxHeight: 250,
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
                                    thickness:
                                        MaterialStateProperty.all<double>(4),
                                    thumbVisibility:
                                        MaterialStateProperty.all<bool>(true),
                                  ),
                                ),

                                menuItemStyleData: const MenuItemStyleData(
                                  height: 48,
                                  padding: EdgeInsets.only(left: 16, right: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                */
                const SizedBox(height: 5),

                inputField(
                  _emailController,
                  'Email Address',
                  readOnly: true,
                  keyboardType: TextInputType.emailAddress,
                ),

                const SizedBox(height: 0),
                inputField(
                  _phoneController,
                  'Mobile Phone',
                  keyboardType: TextInputType.phone,
                ),

                const SizedBox(height: 9),

                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Preselected value if any
                      final String? selectedEthnicity =
                          _raceController.text.isEmpty
                          ? null
                          : _raceController.text;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label on top
                          Text(
                            'Ethnicity',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 6),

                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              value: selectedEthnicity,
                              hint: Text(
                                'Select ethnicity',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF9E9E9E),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              items:
                                  const [
                                    'Malay',
                                    'Chinese',
                                    'Indian',
                                    'Bumiputera Sabah',
                                    'Bumiputera Sarawak',
                                    'Orang Asli',
                                    'Others',
                                  ].map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: SizedBox(
                                        width: constraints.maxWidth - 32,
                                        child: Text(
                                          item,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? value) {
                                if (session.role == UserRole.user) {
                                  setState(() {
                                    _raceController.text = value ?? '';
                                    _race = value;
                                  });
                                }
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 48,
                                width: constraints.maxWidth,
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
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
                                maxHeight: 300,
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
                                  thickness: MaterialStateProperty.all<double>(
                                    4,
                                  ),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 48,
                                padding: EdgeInsets.only(left: 16, right: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Preselected value if any
                      final String? selectedReligion =
                          _religionController.text.isEmpty
                          ? null
                          : _religionController.text;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label on top
                          Text(
                            'Religion',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 6),

                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              value: selectedReligion,
                              hint: Text(
                                'Select religion',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF9E9E9E),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              items:
                                  const [
                                    'Islam',
                                    'Christianity',
                                    'Buddhism',
                                    'Hinduism',
                                    'Sikhism',
                                    'Confucianism',
                                    'Taoism',
                                    'Others',
                                  ].map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: SizedBox(
                                        width: constraints.maxWidth - 32,
                                        child: Text(
                                          item,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? value) {
                                if (session.role == UserRole.user) {
                                  setState(() {
                                    _religionController.text = value ?? '';
                                    _religion = value;
                                  });
                                }
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: constraints.maxWidth,
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
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
                                maxHeight: 300,
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
                                  thickness: MaterialStateProperty.all<double>(
                                    4,
                                  ),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 48,
                                padding: EdgeInsets.only(left: 16, right: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),
                Padding(
                  padding: const EdgeInsets.only(left: 30.0, right: 30.0),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      // Preselected value if any
                      final String? selectedOccupation =
                          _occupationController.text.isEmpty
                          ? null
                          : _occupationController.text;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Label on top
                          Text(
                            'Occupation',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 6),

                          DropdownButtonHideUnderline(
                            child: DropdownButton2<String>(
                              isExpanded: true,
                              value: selectedOccupation,
                              hint: Text(
                                'Select occupation',
                                style: GoogleFonts.poppins(
                                  color: const Color(0xFF9E9E9E),
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              items:
                                  const [
                                    'Government',
                                    'Non-Government',
                                    'Self-Employed',
                                    'Student',
                                    'Unemployed',
                                    'Retired',
                                    'Others',
                                  ].map((String item) {
                                    return DropdownMenuItem<String>(
                                      value: item,
                                      child: SizedBox(
                                        width: constraints.maxWidth - 32,
                                        child: Text(
                                          item,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: true,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                              onChanged: (String? value) {
                                if (session.role == UserRole.user) {
                                  setState(() {
                                    _occupationController.text = value ?? '';
                                    _occupation = value;
                                  });
                                }
                              },
                              buttonStyleData: ButtonStyleData(
                                height: 50,
                                width: constraints.maxWidth,
                                padding: const EdgeInsets.only(
                                  left: 16,
                                  right: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
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
                                maxHeight: 240,
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
                                  thickness: MaterialStateProperty.all<double>(
                                    4,
                                  ),
                                  thumbVisibility:
                                      MaterialStateProperty.all<bool>(true),
                                ),
                              ),
                              menuItemStyleData: const MenuItemStyleData(
                                height: 48,
                                padding: EdgeInsets.only(left: 16, right: 16),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),

                const SizedBox(height: 15),

                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 30.0,
                    vertical: 10.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
                        child: Text(
                          'Full Address',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: const Color.fromARGB(255, 5, 5, 5),
                          ),
                        ),
                      ),

                      TextField(
                        controller: _addressController,
                        maxLines: 8,
                        readOnly: session.role == UserRole.admin,
                        style: TextStyle(
                          fontSize: 14,
                          color: session.role == UserRole.admin
                              ? Colors.grey[500]
                              : Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText:
                              'Enter your full address including postcode, city, and state',
                          hintStyle: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                          filled: true,
                          fillColor: session.role == UserRole.admin
                              ? const Color(0xFFF5F5F5)
                              : Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: session.role == UserRole.admin
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFFE0E0E0),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide(
                              color: session.role == UserRole.admin
                                  ? const Color(0xFFE0E0E0)
                                  : const Color(0xFF629E5C),
                              width: session.role == UserRole.admin ? 1.0 : 2.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Save button
                SizedBox(
                  width: 300,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (session.role == UserRole.user)
                        ? () async {
                            final saveData = User(
                              id: widget.patientUser.id,
                              fullName: _nameController.text.trim(),
                              email: widget.patientUser.email,
                              icNumber: widget.patientUser.icNumber,
                              phoneNumber: _phoneController.text.trim(),
                              nationality: widget.patientUser.nationality,
                              gender: widget.patientUser.gender,
                              birthDate: widget.patientUser.birthDate,
                              age: widget.patientUser.age,
                              occupation: _occupation,
                              race: _race,
                              religion: _religion,
                              homeAddress: _addressController.text.trim(),
                              postCode: null,
                              city: null,
                              state: null,
                              country: null,
                              createdAt: widget.patientUser.createdAt,
                              signupMethod: widget.patientUser.signupMethod,
                              unactive: widget.patientUser.unactive,
                              updatedAt: widget.patientUser.updatedAt,
                            );

                            final result = await vm.userUpdate(saveData);

                            if (!context.mounted) return;

                            if (result is Ok) {
                              showSuccessDialog(
                                context: context,
                                title: "Account Details Update!",
                                message:
                                    "Your information has been successfully updated.",
                                onButtonPressed: () {
                                  session.changeUserDetail(saveData);

                                  Navigator.of(context).popUntil((route) {
                                    return route.settings.name == '/profile' ||
                                        route.isFirst;
                                  });
                                },
                              );
                            } else {
                              showSnackBar(
                                context: context,
                                text:
                                    vm.message ??
                                    "An unknown error occured. Please try again.",
                                color: Colors.red[900],
                              );
                            }
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: (session.role == UserRole.admin)
                          ? Colors.grey[400]
                          : Color(0xFF629E5C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Confirm Changes',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
    );
  }

  //▫️Helper Widget:
  // Input field widget (Textfield, can change to TextFormField)
  Widget inputField(
    TextEditingController controller,
    String title, {
    bool readOnly = false,
    int maxlines = 1,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title label — shows lock icon if read-only
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
            child: Row(
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: const Color.fromARGB(255, 5, 5, 5),
                  ),
                ),
                if (readOnly) ...[
                  const SizedBox(width: 5),
                  Icon(Icons.lock_outline_rounded,
                      size: 13, color: Colors.grey[400]),
                ],
              ],
            ),
          ),
          // Text field box
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            readOnly: readOnly,
            maxLines: maxlines,
            style: TextStyle(
              fontSize: 14,
              color: readOnly ? Colors.grey[500] : Colors.black87,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              filled: true,
              // Read-only fields get a grey background; editable ones stay white
              fillColor: readOnly
                  ? const Color(0xFFF5F5F5)
                  : Colors.white,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: readOnly
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xffefefef),
                  width: readOnly ? 1.0 : 2.0,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  // Read-only fields don't show focus colour
                  color: readOnly
                      ? const Color(0xFFE0E0E0)
                      : const Color(0xFF629E5C),
                  width: readOnly ? 1.0 : 2.0,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
