import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:phone_form_field/phone_form_field.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:provider/provider.dart';

import 'widgets/user_consent_dialog.dart';
import 'widgets/passport_scan_widget.dart';
import 'terms_conditions_screen.dart';
import '../viewmodels/auth_account_viewmodel.dart';
import '../../domain/user.dart';
import '../../domain/user_profile_validators.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/animations_transitions.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/input_formatters.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>(); // Form key
  final _scrollController = ScrollController(); // For auto-scroll to errors

  // TextField Controllers
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();
  final _nameController = TextEditingController();
  final _nricController = TextEditingController();
  final _phoneController = PhoneController(
    initialValue: PhoneNumber(isoCode: IsoCode.MY, nsn: ''),
  );

  // Dropdown & Radio values
  Nationality? _nationality;
  Gender? _gender;
  DateTime? _dobDate;
  int? _age;
  bool _isTncChecked = false;
  String _icType = 'MyKad'; // IC type for Malaysian users

  // Other State Variables
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _useManualPassport = false; // Show text field instead of scan widget
  String? _scannedPassportNumber; // Tracks if passport was already scanned

  // Dynamic IC texts (Changes whenever nationality is picked)
  String _titleIC = 'NRIC Number ';
  String _exampleIC = "xxxxxx-xx-xxxx";

  final fieldNRICNode = FocusNode();

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();

    // Auto-fill DOB from IC number when Malaysian user finishes typing
    fieldNRICNode.addListener(() {
      // Trigger when user leaves the NRIC field
      if (!fieldNRICNode.hasFocus &&
          _nricController.text.isNotEmpty &&
          _nationality == Nationality.malaysian) {
        final ic = _nricController.text.trim();
        // Malaysian IC is 12 digits: YYMMDDXXXXXX
        if (ic.length == 12 && RegExp(r'^\d{12}$').hasMatch(ic)) {
          try {
            final int yearLimit = int.parse(
              DateTime.now().year.toString().substring(2, 4),
            );
            final int yy = int.parse(ic.substring(0, 2));
            final int month = int.parse(ic.substring(2, 4));
            final int day = int.parse(ic.substring(4, 6));

            // Determine full year: if yy <= current 2-digit year → 2000s, else → 1900s
            final int fullYear = yy <= yearLimit ? 2000 + yy : 1900 + yy;

            // Validate month and day are reasonable before setting
            if (month >= 1 && month <= 12 && day >= 1 && day <= 31) {
              final DateTime dob = DateTime(fullYear, month, day);
              setState(() {
                _dobDate = dob;
                _age = _calculateAge(dob);
              });
            }
          } catch (_) {
            // If parsing fails silently, user can pick date manually
          }
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    _nameController.dispose();
    _nricController.dispose();
    _phoneController.dispose();
    fieldNRICNode.dispose();
    super.dispose();
  }

  // Calculate age from DOB
  int _calculateAge(DateTime dob) {
    final today = DateTime.now();
    int age = today.year - dob.year;

    // If birthday hasn’t occurred yet this year, subtract 1
    if (today.month < dob.month ||
        (today.month == dob.month && today.day < dob.day)) {
      age--;
    }
    return age;
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AuthenticationAccountViewModel>();

    return LoadingOverlay(
      isLoading: vm.isLoading,
      child: Scaffold(
        backgroundColor: const Color(0xFFFFFFFF),
        appBar: AppBar(
          backgroundColor: const Color(0xFFf7f7f7),
          elevation: 0,
          surfaceTintColor: const Color(0xEBFFFFFF),
          centerTitle: true,
          scrolledUnderElevation: 4.0,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            'Register Account',
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

        // ✅ Body
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            controller: _scrollController,
            child: SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 0),

                  Center(
                    child: Column(
                      children: [
                        const SizedBox(height: 10),

                        //🔹 Name (Textfield)
                        inputField(
                          controller: _nameController,
                          title: "Full Name",
                          hint: "Enter your full legal name",
                          validator: (value) {
                            return AccountValidators.isFullNameValid(value);
                          },
                          inputFormatters: [InputFormat.noLeadingWhitespace],
                        ),

                        const SizedBox(height: 5),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 5),

                        //🔹 Nationality (Radio)
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 32.0,
                            top: 10.0,
                            bottom: 10.0,
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nationality',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Force align radios to the left
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<Nationality>(
                                      value: Nationality.malaysian,
                                      groupValue: _nationality,
                                      onChanged: (Nationality? value) {
                                        setState(() {
                                          _nationality = value;
                                          _titleIC = 'NRIC';
                                          _exampleIC =
                                              "Example: 990315138967"; // <-- ADD THIS
                                          _nricController.text = "";
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                      activeColor: const Color(0xFF629E5C),
                                    ),
                                    Text(
                                      'Malaysian',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    const SizedBox(width: 20),
                                    Radio<Nationality>(
                                      value: Nationality.nonMalaysian,
                                      groupValue: _nationality,
                                      onChanged: (Nationality? value) {
                                        setState(() {
                                          _nationality = value;
                                          _titleIC = 'Passport';
                                          _exampleIC = "Example: C1234567";
                                          _nricController.text = "";
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                      activeColor: const Color(0xFF629E5C),
                                    ),
                                    Text(
                                      'Non-Malaysian',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // 🔹 IC Type dropdown (shown only for Malaysians)
                        if (_nationality == Nationality.malaysian)
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 32.0,
                              right: 32.0,
                              bottom: 10.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'IC Type',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<String>(
                                  value: _icType,
                                  isExpanded: true,
                                  decoration: InputDecoration(
                                    contentPadding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 15, vertical: 14),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Color(0xffefefef), width: 2),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                          color: Color(0xFF629E5C), width: 2),
                                    ),
                                    filled: true,
                                    fillColor: Colors.white,
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: 'MyKad',
                                      child: Text('MyKad — Citizens'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MyPR',
                                      child: Text('MyPR — Permanent Resident'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MyKAS',
                                      child:
                                          Text('MyKAS — Temporary Resident'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MyTentera',
                                      child: Text('MyTentera — Armed Forces'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MyPolis',
                                      child: Text('MyPolis — Police'),
                                    ),
                                    DropdownMenuItem(
                                      value: 'MyKid',
                                      child: Text('MyKid — Children'),
                                    ),
                                  ],
                                  onChanged: (val) {
                                    if (val != null) {
                                      setState(() => _icType = val);
                                    }
                                  },
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black87,
                                  ),
                                  dropdownColor: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  icon: const Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.grey),
                                ),
                              ],
                            ),
                          ),

                        const SizedBox(height: 5),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 5),

                        //🔹 NRIC (Malaysian) or Passport scan/manual (Non-Malaysian)
                        if (_nationality == Nationality.malaysian)
                          inputField(
                            controller: _nricController,
                            title: "$_titleIC ID",
                            hint: _exampleIC,
                            focusNode: fieldNRICNode,
                            inputFormatters: [
                              InputFormat.onlyAlphaNumerics,
                              InputFormat.noWhitespace,
                              LengthLimitingTextInputFormatter(12),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'NRIC number is required';
                              }
                              if (value.length != 12) {
                                return 'NRIC must be exactly 12 digits';
                              }
                              if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                                return 'NRIC must contain numbers only';
                              }
                              return null;
                            },
                            onChanged: (val) {
                              setState(() {}); // update requirement box live
                              if (val.length == 12 &&
                                  RegExp(r'^\d{12}$').hasMatch(val)) {
                                try {
                                  final int yearLimit = int.parse(
                                    DateTime.now()
                                        .year
                                        .toString()
                                        .substring(2, 4),
                                  );
                                  final int yy =
                                      int.parse(val.substring(0, 2));
                                  final int month =
                                      int.parse(val.substring(2, 4));
                                  final int day =
                                      int.parse(val.substring(4, 6));
                                  final int fullYear =
                                      yy <= yearLimit
                                          ? 2000 + yy
                                          : 1900 + yy;
                                  if (month >= 1 &&
                                      month <= 12 &&
                                      day >= 1 &&
                                      day <= 31) {
                                    final DateTime dob =
                                        DateTime(fullYear, month, day);
                                    setState(() {
                                      _dobDate = dob;
                                      _age = _calculateAge(dob);
                                    });
                                  }
                                } catch (_) {}
                              }
                            },
                          ),

                        // NRIC requirement box
                        if (_nationality == Nationality.malaysian)
                          _buildNricRequirements(_nricController.text),

                        if (_nationality == Nationality.nonMalaysian) ...[
                          // Show scan widget only if user hasn't gone manual yet
                          if (!_useManualPassport)
                            PassportScanWidget(
                              onScanned: ({
                                required String passportNumber,
                                String? fullName,
                                DateTime? dateOfBirth,
                              }) {
                                setState(() {
                                  _nricController.text = passportNumber;
                                  _scannedPassportNumber = passportNumber;
                                  if (fullName != null &&
                                      _nameController.text.isEmpty) {
                                    _nameController.text = fullName;
                                  }
                                  if (dateOfBirth != null) {
                                    _dobDate = dateOfBirth;
                                    _age = _calculateAge(dateOfBirth);
                                  }
                                  _useManualPassport = true;
                                });
                              },
                              onManualEntry: () =>
                                  setState(() => _useManualPassport = true),
                            ),

                          // Passport number text field (shown after scan or manual choice)
                          if (_useManualPassport)
                            inputField(
                              controller: _nricController,
                              title: "Passport Number",
                              hint: "Example: A12345678",
                              inputFormatters: [
                                InputFormat.onlyAlphaNumerics,
                                InputFormat.noWhitespace,
                                LengthLimitingTextInputFormatter(9),
                              ],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Passport number is required';
                                }
                                if (value.length < 6 || value.length > 9) {
                                  return 'Passport must be 6–9 characters';
                                }
                                if (!RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value)) {
                                  return 'Passport must be alphanumeric only';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                            ),

                          // Passport requirement box
                          if (_useManualPassport)
                            _buildPassportRequirements(_nricController.text),

                          // Scan again link (shown after a scan was done)
                          if (_useManualPassport)
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 32, bottom: 4),
                              child: TextButton.icon(
                                onPressed: () => setState(() {
                                  _useManualPassport = false;
                                  _scannedPassportNumber = null;
                                  _nricController.clear();
                                }),
                                icon: const Icon(
                                  Icons.camera_alt_outlined,
                                  size: 15,
                                  color: Color(0xFF629E5C),
                                ),
                                label: Text(
                                  'Scan passport again',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12.5,
                                    color: const Color(0xFF629E5C),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            ),
                        ],

                        const SizedBox(height: 5),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 5),

                        //🔹 Date of Birth
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
                            vertical: 10.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Date Of Birth",
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),

                              const SizedBox(height: 6),

                              TextFormField(
                                readOnly: true,
                                controller: TextEditingController(
                                  text: _dobDate == null
                                      ? ''
                                      : "${_dobDate!.day.toString().padLeft(2, '0')}/${_dobDate!.month.toString().padLeft(2, '0')}/${_dobDate!.year}",
                                ),
                                decoration: InputDecoration(
                                  hintText: 'DD/MM/YYYY',

                                  hintStyle: GoogleFonts.poppins(
                                    fontStyle:
                                        FontStyle.italic, // <-- makes it italic
                                    color: Colors
                                        .grey[500], // optional: change hint color
                                    fontSize: 14, // optional: adjust size
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 15,
                                    vertical: 1,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xffefefef),
                                      width: 2,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF629E5C),
                                      width: 2,
                                    ),
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,

                                  suffixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.calendar_today,
                                      color: Color.fromARGB(255, 143, 179, 140),
                                    ),
                                    onPressed: () async {
                                      DateTime?
                                      pickedDate = await showRoundedDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                        borderRadius: 16,
                                        height:
                                            301, // 👈 makes the picker shorter
                                        theme: ThemeData(
                                          primaryColor: const Color(0xFFFFFFFF),
                                          colorScheme: const ColorScheme.light(
                                            primary: Color(0xFF629E5C),
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black87,
                                          ),
                                          dialogBackgroundColor: Colors.white,
                                        ),
                                        styleDatePicker:
                                            MaterialRoundedDatePickerStyle(
                                              textStyleDayButton:
                                                  const TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                              textStyleMonthYearHeader:
                                                  const TextStyle(
                                                    fontSize: 18,
                                                    fontWeight: FontWeight.w500,
                                                    color: Color(0xFF629E5C),
                                                  ),
                                              textStyleDayHeader:
                                                  const TextStyle(
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  ),
                                              textStyleButtonPositive:
                                                  const TextStyle(
                                                    color: Color(0xFF629E5C),
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                              textStyleButtonNegative:
                                                  const TextStyle(
                                                    color: Color(0xFF9C9C9C),
                                                  ),
                                              decorationDateSelected:
                                                  const BoxDecoration(
                                                    color: Color(0xFF629E5C),
                                                    shape: BoxShape.circle,
                                                  ),
                                              paddingMonthHeader:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                  ),
                                            ),
                                        styleYearPicker:
                                            MaterialRoundedYearPickerStyle(
                                              textStyleYear: TextStyle(
                                                fontSize: 18,
                                                color: Colors.black87,
                                              ),
                                              textStyleYearSelected: TextStyle(
                                                fontSize: 22,
                                                color: Color(0xFF629E5C),
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                      );

                                      if (pickedDate != null) {
                                        setState(() {
                                          _dobDate = pickedDate;
                                          _age = _calculateAge(pickedDate);
                                        });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        //🔹 Age
                        inputField(
                          controller: TextEditingController(
                            text: _age == null ? '' : "$_age Years Old",
                          ),
                          title: "Age",
                          readOnly: true,
                        ),

                        const SizedBox(height: 5),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 2),

                        //🔹 Gender radio button
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 32.0,
                            top: 10.0,
                            bottom: 10.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Gender',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: const Color.fromARGB(255, 0, 0, 0),
                                ),
                              ),
                              const SizedBox(height: 6),

                              // Use Wrap instead of Row for wrapping and left alignment
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Radio<Gender>(
                                      value: Gender.male,
                                      groupValue: _gender,
                                      onChanged: (Gender? value) {
                                        setState(() {
                                          _gender = value;
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                      activeColor: const Color(0xFF629E5C),
                                    ),
                                    Text(
                                      'Male',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                    const SizedBox(width: 20),
                                    Radio<Gender>(
                                      value: Gender.female,
                                      groupValue: _gender,
                                      onChanged: (Gender? value) {
                                        setState(() {
                                          _gender = value;
                                        });
                                        FocusScope.of(context).unfocus();
                                      },
                                      activeColor: const Color(0xFF629E5C),
                                    ),
                                    Text(
                                      'Female',
                                      style: GoogleFonts.poppins(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 0),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 5),

                        //🔹 Email
                        inputField(
                          controller: _emailController,
                          title: "Email",
                          hint: "Enter your Email Address",
                          validator: (value) {
                            return AccountValidators.isEmailValid(value);
                          },
                          inputFormatters: [InputFormat.noWhitespace],
                        ),

                        const SizedBox(height: 5),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 5),

                        //🔹 Phone Field (PhoneFormField widget)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
                            vertical: 10.0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Title
                              Padding(
                                padding: const EdgeInsets.only(
                                  bottom: 6.0,
                                  left: 2.0,
                                ),
                                child: Text(
                                  "Mobile Phone",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: const Color.fromARGB(255, 5, 5, 5),
                                  ),
                                ),
                              ),
                              // Theme wrapper to change dialog background and remove the tint in the country selector
                              Theme(
                                data: Theme.of(context).copyWith(
                                  // Ensures the general background of the dialog/menu is white
                                  canvasColor: Colors.white,
                                  dialogBackgroundColor: Colors.white,

                                  // Resetting interactive colors to transparent/disabled.
                                  highlightColor: Colors.transparent,
                                  splashColor: Colors.transparent,
                                  splashFactory: NoSplash.splashFactory,
                                  listTileTheme: const ListTileThemeData(
                                    selectedTileColor: Colors
                                        .white, // Background color when selected
                                    selectedColor: Colors
                                        .black, // Color of icon/text when selected
                                  ),
                                  textTheme: Theme.of(context).textTheme.copyWith(
                                    // Redirect Theme.of(context).textTheme.caption to Theme.of(context).textTheme.bodySmall
                                    bodySmall: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ),
                                child: PhoneFormField(
                                  controller:
                                      _phoneController, //defaultCountry: pff.IsoCode.MY,
                                  validator: (phoneNumber) {
                                    // The pff.PhoneNumber object is nullable
                                    final numberLength =
                                        phoneNumber?.nsn.length ?? 0;
                                    // The package handles most validation, we only override the length check here.
                                    // NSN (National Significant Number) is the digits after the country code.
                                    if (numberLength < 9 || numberLength > 11) {
                                      return 'Mobile number must be 9 or 11 digits.';
                                    }

                                    // If the number exists and passes length check, let the package handle remaining format validation.
                                    // Returning null means valid.
                                    return null;
                                  },
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),

                                  decoration: InputDecoration(
                                    hintText: 'Enter your Phone Number',
                                    // Manually add the dropdown icon to provide the visual cue
                                    //prefixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                    //suffixIcon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 15,
                                      vertical: 1,
                                    ),
                                    counterText: "",
                                    // Defines the default 'border' to ensure the outline style is used.
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xffefefef),
                                        width: 2,
                                      ),
                                    ),

                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xffefefef),
                                        width: 2,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: Color(0xFF629E5C),
                                        width: 2,
                                      ),
                                    ),
                                    fillColor: Colors.white,
                                    filled: true,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 5),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 5),

                        //🔹 Password
                        inputField(
                          controller: _passController,
                          title: "Password",
                          hint: "Enter your Password",
                          obscure: _obscurePassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            onPressed: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                          ),
                          validator: (value) {
                            return AccountValidators.isPasswordValid(value);
                          },
                          inputFormatters: [InputFormat.noLeadingWhitespace],
                          onChanged: (_) => setState(() {}),
                        ),

                        // 🔹 Password requirement box
                        _buildPasswordRequirements(_passController.text),

                        //🔹 Confirm Password
                        inputField(
                          controller: _confirmPassController,
                          title: "Confirm Password",
                          hint: "Enter your Password again",
                          obscure: _obscureConfirmPassword,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey.shade500,
                              size: 20,
                            ),
                            onPressed: () => setState(() =>
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword),
                          ),
                          validator: (value) {
                            return AccountValidators.isConfirmPasswordValid(
                              value,
                              _passController.text,
                            );
                          },
                          inputFormatters: [InputFormat.noLeadingWhitespace],
                        ),

                        const SizedBox(height: 5),

                        Divider(
                          color: Colors.grey.shade300,
                          thickness: 0.5,
                          indent: 25,
                          endIndent: 25,
                        ),

                        const SizedBox(height: 5),

                        // ✅ Terms and Conditions Row (auto-wrap, aligned)
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 30.0,
                            vertical: 8.0,
                          ),
                          child: Row(
                            // Aligns the checkbox and the entire text block centrally
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Checkbox
                              SizedBox(
                                height:
                                    24.0, // Ensures the checkbox has a defined size
                                width: 24.0,
                                child: Checkbox(
                                  value: _isTncChecked,
                                  activeColor: const Color(
                                    0xFF4D7C4A,
                                  ), // Use primary green for active state
                                  onChanged: (value) {
                                    setState(
                                      () => _isTncChecked = value ?? false,
                                    );
                                  },
                                ),
                              ),

                              const SizedBox(
                                width: 8,
                              ), // Small space between checkbox and text
                              // Flexible text (Wrapped in Flexible/Expanded for auto-wrap)
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    // Navigator logic to TncPage remains the same
                                    Navigator.of(context).push(
                                      transitionAnimation(
                                        page: TermsConditionsScreen(),
                                      ),
                                    );
                                  },
                                  child: RichText(
                                    // Use RichText for beautiful inline styling
                                    text: TextSpan(
                                      style: GoogleFonts.poppins(
                                        fontSize:
                                            13.5, // Slightly larger for readability
                                        color: Colors
                                            .grey[700], // Darker gray for better visibility
                                        height: 1.3,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "I have read and agree to the ",
                                        ),
                                        TextSpan(
                                          text: "terms and conditions.",
                                          style: GoogleFonts.poppins(
                                            fontSize: 13.5,
                                            color: const Color(
                                              0xFF4D7C4A,
                                            ), // Link color
                                            fontWeight: FontWeight
                                                .w700, // Make link bolder
                                            decoration: TextDecoration
                                                .underline, // Add underline for link visual cue
                                            decorationColor: const Color(
                                              0xFF4D7C4A,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 28),

                        //🔹 Sign Up Button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6FBF73),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 141,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            elevation: 2,
                          ),
                          onPressed: () async {
                            // Button to register user account

                            // Check if all fields are valid and filled
                            // Scroll to first error field if validation fails
                            final isFormValid = _formKey.currentState!.validate();
                            if (!isFormValid ||
                                _nationality == null ||
                                _gender == null ||
                                _dobDate == null ||
                                _age == null) {
                              // Scroll to top so user sees the first error
                              _scrollController.animateTo(
                                0,
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeOut,
                              );
                              // Trigger validation again to show all error messages
                              _formKey.currentState!.validate();
                            }
                            if (isFormValid &&
                                _nationality != null &&
                                _gender != null &&
                                _dobDate != null &&
                                _age != null) {
                              if (!_isTncChecked) {
                                showSnackBar(
                                  context: context,
                                  text:
                                      "To proceed with registration, you must agree to the terms and conditions.",
                                  color: Colors.red[900],
                                );
                                return;
                              }

                              // Show consent dialog and wait for user response
                              final consentGiven = await showConsentDialog(
                                context: context,
                              );

                              if (!context.mounted) return;

                              // User declined consent or dismissed the dialog
                              if (consentGiven == false ||
                                  consentGiven == null) {
                                showSnackBar(
                                  context: context,
                                  text:
                                      "You must agree to the data collection and usage terms to register.",
                                  color: Colors.red[900],
                                );
                                return;
                              }

                              final saveData = User(
                                id: "", // ID will be generated by the backend (Firebase)
                                fullName: _nameController.text.trim(),
                                email: _emailController.text.trim(),
                                icNumber: _nricController.text.trim(),
                                phoneNumber:
                                    _phoneController.value.international,
                                nationality: _nationality!.value,
                                gender: _gender!.value,
                                birthDate: _dobDate!,
                                age: _age!,
                                occupation: null,
                                race: null,
                                religion: null,
                                homeAddress: null,
                                postCode: null,
                                city: null,
                                state: null,
                                country: null,
                                createdAt: DateTime.timestamp(),
                                signupMethod: "Email",
                                unactive: false,
                                updatedAt: DateTime.timestamp(),
                              );

                              final result = await vm.userSignup(
                                saveData,
                                _passController.text.trim(),
                              );

                              if (!context.mounted) return;

                              switch (result) {
                                case Ok():
                                  if (!context.mounted) return;

                                  Navigator.of(context).popUntil((route) {
                                    return route.isFirst;
                                  });
                                case Error():
                                  showSnackBar(
                                    context: context,
                                    text:
                                        vm.message ??
                                        "Unknown error occured. Please try again.",
                                    color: Colors.red[900],
                                  );
                              }
                            }
                          },
                          child: Text(
                            'Register',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── NRIC requirement box (Malaysian) ─────────────────────
  Widget _buildNricRequirements(String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    final isExactly12Digits =
        value.length == 12 && RegExp(r'^\d{12}$').hasMatch(value);

    final requirements = [
      {
        'label': 'Exactly 12 digits',
        'met': value.length == 12,
      },
      {
        'label': 'Numbers only (no letters or spaces)',
        'met': RegExp(r'^\d+$').hasMatch(value),
      },
      {
        'label': 'Valid NRIC format (YYMMDDXXXXXX)',
        'met': isExactly12Digits,
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'NRIC must be:',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            ...requirements.map((req) {
              final bool met = req['met'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      met
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 15,
                      color: met
                          ? const Color(0xFF4CAF50)
                          : Colors.red.shade300,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      req['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: met ? Colors.green[700] : Colors.red[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Passport requirement box (Non-Malaysian) ───────────────
  Widget _buildPassportRequirements(String value) {
    if (value.isEmpty) return const SizedBox.shrink();

    final requirements = [
      {
        'label': '6 to 9 characters',
        'met': value.length >= 6 && value.length <= 9,
      },
      {
        'label': 'Letters and numbers only (alphanumeric)',
        'met': RegExp(r'^[a-zA-Z0-9]+$').hasMatch(value),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Passport number must be:',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            ...requirements.map((req) {
              final bool met = req['met'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      met
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 15,
                      color: met
                          ? const Color(0xFF4CAF50)
                          : Colors.red.shade300,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      req['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: met ? Colors.green[700] : Colors.red[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget inputField({
    required TextEditingController controller,
    required String title,
    String? hint,
    bool obscure = false,
    bool readOnly = false,
    Widget? suffixIcon,
    FocusNode? focusNode,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    void Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0, left: 2.0),
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color.fromARGB(255, 5, 5, 5),
              ),
            ),
          ),
          TextFormField(
            controller: controller,
            obscureText: obscure,
            readOnly: readOnly,
            focusNode: focusNode,
            validator: validator,
            inputFormatters: inputFormatters,
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 14,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xffefefef),
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(
                  color: Color(0xFF629E5C),
                  width: 2,
                ),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.red, width: 2),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.red.shade900, width: 2),
              ),
              fillColor: Colors.white,
              filled: true,
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 Password requirement box
  Widget _buildPasswordRequirements(String password) {
    if (password.isEmpty) return const SizedBox.shrink();

    final requirements = [
      {
        'label': '8–64 characters',
        'met': password.length >= 8 && password.length <= 64,
      },
      {
        'label': 'Uppercase letter (A-Z)',
        'met': password.contains(RegExp(r'[A-Z]')),
      },
      {
        'label': 'Lowercase letter (a-z)',
        'met': password.contains(RegExp(r'[a-z]')),
      },
      {
        'label': 'Number (0-9)',
        'met': password.contains(RegExp(r'[0-9]')),
      },
      {
        'label': 'Special character (!@#\$...)',
        'met': password.contains(RegExp(r'[!@#$%^&*(),.?\":{}|<>]')),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F9F9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: const Color(0xFFE0E0E0), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Password must contain:',
              style: GoogleFonts.poppins(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 6),
            ...requirements.map((req) {
              final bool met = req['met'] as bool;
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  children: [
                    Icon(
                      met
                          ? Icons.check_circle_rounded
                          : Icons.cancel_rounded,
                      size: 15,
                      color: met
                          ? const Color(0xFF4CAF50)
                          : Colors.red.shade300,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      req['label'] as String,
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: met ? Colors.green[700] : Colors.red[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}