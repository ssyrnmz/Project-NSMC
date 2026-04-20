import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

import 'widgets/apt_booking_warning_box.dart';
import '../viewmodels/apt_modify_viewmodel.dart';
import '../viewmodels/apt_view_viewmodel.dart';
import '../../domain/appointment.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/domain/session.dart';
import '../../../doctor/domain/doctor.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_success_dialogue.dart';
import '../../../../utils/ui/display_formatters.dart';

class AppointmentBookingScreen extends StatefulWidget {
  const AppointmentBookingScreen({super.key});

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>(); // Form key

  // Form inputs:
  late TextEditingController _dateController;
  late TextEditingController _inquiryController;

  // Input form values:
  AppointmentType? _appointmentType;
  AppointmentVisitType? _visitType;
  int? selectedDoctorValue;

  String? _selectedPOAValue;
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  // Logic form values: (Used only for determining the final value for forms)
  int? _speciality;
  String? _selectedTimeSlot;

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController();
    _inquiryController = TextEditingController();

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

  @override
  void dispose() {
    _dateController.dispose();
    _inquiryController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  // Can change to use form widget instead later
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vmModify = context.watch<AppointmentModifyViewModel>();
    final vmData = context.read<AppointmentViewModel>();

    return LoadingOverlay(
      isLoading: vmModify.isLoading,
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
            'Request Appointment',
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
          child: SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 5),
                    const AppointmentBookingWarningBox(),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            thickness: 0.7,
                            color: Color(0xFF9F9D9D),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: Text(
                            'Fill in the details.',
                            style: GoogleFonts.poppins(color: Colors.grey[700]),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            thickness: 0.7,
                            color: Color(0xFF9F9D9D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 25),

                    //🔹Purpose of Appointment
                    Text(
                      'Purpose of Appointment',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000000),
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Purpose of Appointment Dropdown - USING DROPDOWN_BUTTON2
                    // You need to ensure 'context' is available, which it is in the builder method.
                    // We wrap the entire widget in LayoutBuilder to get the width (constraints.maxWidth).
                    // Purpose of Appointment Dropdown - WITH WRAPPING TEXT
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton2<String>(
                            isExpanded: true,
                            value: _selectedPOAValue,
                            hint: Text(
                              'Select purpose',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            items: appointmentPurposeOptions.entries.map((
                              entry,
                            ) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Container(
                                  width:
                                      constraints.maxWidth -
                                      32, // Account for padding
                                  child: Text(
                                    entry.key.toUpperCase(),
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
                            onChanged: (String? key) {
                              if (key != null) {
                                setState(() {
                                  _selectedPOAValue = key;
                                  _speciality = appointmentPurposeOptions[key];
                                  selectedDoctorValue =
                                      null; // Reset doctor selection when POA changes
                                });
                              }
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 52,
                              width: constraints.maxWidth,
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
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
                                thumbVisibility:
                                    MaterialStateProperty.all<bool>(true),
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

                    const SizedBox(height: 15),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                    ),

                    const SizedBox(height: 15),

                    //🔹Appointment type
                    Text(
                      'Appointment Type',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 0.0,
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<AppointmentType>(
                                value: AppointmentType.newly,
                                groupValue: _appointmentType,
                                onChanged: (AppointmentType? value) {
                                  setState(() {
                                    _appointmentType = value;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                activeColor: const Color(0xFF629E5C),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                ),
                              ),
                              Text(
                                'New Appointment',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<AppointmentType>(
                                value: AppointmentType.rescheduled,
                                groupValue: _appointmentType,
                                onChanged: (AppointmentType? value) {
                                  setState(() {
                                    _appointmentType = value;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                activeColor: const Color(0xFF629E5C),
                              ),
                              Text(
                                'Reschedule',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                    ),

                    const SizedBox(height: 10),

                    //🔹Doctor for appointment
                    Text(
                      'Select Doctor',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF000000),
                      ),
                    ),

                    const SizedBox(height: 10),

                    // Doctor Dropdown - USING DROPDOWN_BUTTON2
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return DropdownButtonHideUnderline(
                          child: DropdownButton2<int?>(
                            isExpanded: true,
                            value: selectedDoctorValue,
                            hint: Text(
                              'Select doctor',
                              style: GoogleFonts.poppins(
                                color: Colors.grey[500],
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            items: [
                              // Empty value
                              DropdownMenuItem<int?>(
                                value: null,
                                child: Container(
                                  width: constraints.maxWidth - 32,
                                  child: Text(
                                    "ANY DOCTOR",
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      color: Colors.black87,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true, // ✅ ADD THIS TOO
                                  ),
                                ),
                              ),

                              ...vmData.doctorList(_speciality).map((
                                Doctor doctor,
                              ) {
                                return DropdownMenuItem<int?>(
                                  value: doctor.id,
                                  child: Container(
                                    // ✅ ADD THIS CONTAINER
                                    width:
                                        constraints.maxWidth -
                                        32, // ✅ SAME AS POA DROPDOWN
                                    child: Text(
                                      doctor.name.toUpperCase(),
                                      style: GoogleFonts.poppins(
                                        fontSize: 14.5,
                                        color: Colors.black87,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: true, // ✅ ADD THIS TOO
                                    ),
                                  ),
                                );
                              }),
                            ],

                            onChanged: (int? value) {
                              setState(() {
                                selectedDoctorValue = value;
                              });
                            },
                            buttonStyleData: ButtonStyleData(
                              height: 52,
                              width: constraints.maxWidth,
                              padding: const EdgeInsets.only(
                                left: 16,
                                right: 12,
                              ),
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
                              maxHeight: 400,
                              width: constraints.maxWidth,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: const Color.fromARGB(255, 255, 255, 255),
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
                                thumbVisibility:
                                    MaterialStateProperty.all<bool>(true),
                              ),
                            ),
                            menuItemStyleData: const MenuItemStyleData(
                              height: 48,
                              padding: EdgeInsets.only(left: 16, right: 16),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 15),

                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                    ),

                    const SizedBox(height: 15),

                    //🔹Appointment date
                    Text(
                      'Preferred Date',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 10),

                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: InputDecoration(
                        hintText: 'DD/MM/YYYY',
                        hintStyle: GoogleFonts.poppins(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey[500],
                          fontSize: 13.5,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 1,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE0E0E0),
                            width: 1.5,
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
                            DateTime today = DateTime.now();

                            // Set the first available date to 2 weeks from today and last available date to 6 months from today
                            DateTime firstDate = DateTime(
                              today.year,
                              today.month,
                              today.day + 14,
                            );
                            DateTime lastDate = DateTime(
                              today.year,
                              today.month + 6,
                              today.day,
                            );

                            DateTime? pickedDate = await showRoundedDatePicker(
                              context: context,
                              initialDate: firstDate,
                              firstDate: firstDate,
                              lastDate: lastDate,
                              borderRadius: 16,
                              height: 290,
                              listDateDisabled: vmData.closedDates(
                                today,
                                lastDate,
                              ),
                              theme: ThemeData(
                                primaryColor: const Color.fromARGB(
                                  255,
                                  255,
                                  255,
                                  255,
                                ),
                                colorScheme: const ColorScheme.light(
                                  primary: Color(0xFF629E5C),
                                  onPrimary: Colors.white,
                                  onSurface: Colors.black87,
                                ),
                                dialogBackgroundColor: Colors.white,
                              ),
                              styleDatePicker: MaterialRoundedDatePickerStyle(
                                textStyleDayButton: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                textStyleMonthYearHeader: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF629E5C),
                                ),
                                textStyleDayHeader: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                textStyleButtonPositive: const TextStyle(
                                  color: Color(0xFF629E5C),
                                  fontWeight: FontWeight.w600,
                                ),
                                textStyleButtonNegative: const TextStyle(
                                  color: Color(0xFF9C9C9C),
                                ),
                                decorationDateSelected: const BoxDecoration(
                                  color: Color(0xFF629E5C),
                                  shape: BoxShape.circle,
                                ),
                                paddingMonthHeader: const EdgeInsets.symmetric(
                                  vertical: 10,
                                ),
                              ),
                              styleYearPicker: MaterialRoundedYearPickerStyle(
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
                                _selectedDate = pickedDate;
                                _dateController.text =
                                    "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                                _selectedTimeSlot =
                                    null; // Reset time slot when date changes
                              });
                            }
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    //🔹Appointment time
                    Text(
                      'Preferred Time',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Time Dropdown - USING DROPDOWN_BUTTON2
                    DropdownButtonHideUnderline(
                      child: DropdownButton2<String>(
                        value: _selectedTimeSlot,
                        hint: Text(
                          'Select preferred time',
                          style: GoogleFonts.poppins(
                            color: Colors.grey[500],
                            fontSize: 14,
                          ),
                        ),
                        items:
                            // Saturday only has 1 time slot (8.30 am - 1.00 pm)
                            (_selectedDate != null &&
                                _selectedDate!.weekday == 6)
                            ? timeSaturdayOptions.keys.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList()
                            : timeOptions.keys.map((String item) {
                                return DropdownMenuItem<String>(
                                  value: item,
                                  child: Text(
                                    item,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14.5,
                                      color: Colors.black87,
                                    ),
                                  ),
                                );
                              }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedTimeSlot = value;
                            if (value != null) {
                              _selectedStartTime = timeOptions[value]!['start'];
                              _selectedEndTime = timeOptions[value]!['end'];
                            }
                          });
                        },
                        buttonStyleData: ButtonStyleData(
                          height: 52,
                          width: double.infinity,
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
                          width:
                              MediaQuery.of(context).size.width -
                              60, // Fixed width
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
                        ),
                        menuItemStyleData: const MenuItemStyleData(
                          height: 48,
                          padding: EdgeInsets.only(left: 16, right: 16),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      'Visit Type',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 0.0,
                        top: 5.0,
                        bottom: 5.0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<AppointmentVisitType>(
                                value: AppointmentVisitType.newly,
                                groupValue: _visitType,
                                onChanged: (AppointmentVisitType? value) {
                                  setState(() {
                                    _visitType = value;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                activeColor: const Color(0xFF629E5C),
                              ),
                              Text(
                                'New Visit',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Radio<AppointmentVisitType>(
                                value: AppointmentVisitType.followUp,
                                groupValue: _visitType,
                                onChanged: (AppointmentVisitType? value) {
                                  setState(() {
                                    _visitType = value;
                                  });
                                  FocusScope.of(context).unfocus();
                                },
                                activeColor: const Color(0xFF629E5C),
                                visualDensity: const VisualDensity(
                                  vertical: -4,
                                ),
                              ),
                              Text(
                                'Follow Up On Last Visit',
                                style: GoogleFonts.poppins(fontSize: 14),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8),
                      child: Divider(thickness: 0.7, color: Color(0xFFD1D1D1)),
                    ),

                    const SizedBox(height: 15),

                    //🔹Appointment inquiry
                    Text(
                      'Current Health Condition / Inquiry / Others \n(If any)',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: const Color.fromARGB(255, 0, 0, 0),
                      ),
                    ),

                    const SizedBox(height: 15),

                    TextField(
                      controller: _inquiryController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText:
                            'Describe your condition/inquiry here \n(Not Required)',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[500],
                          fontSize: 14,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: const Color(0xFFE0E0E0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: Color(0xFF629E5C),
                          ),
                        ),
                      ),
                      style: GoogleFonts.poppins(fontSize: 14),
                    ),

                    const SizedBox(height: 28),

                    Center(
                      child: ElevatedButton(
                        onPressed: () async {
                          // Button's function to request for an appointment
                          final userSession = session.session!;

                          // Check if user is the one requesting
                          if (userSession is UserSession) {
                            // Check if all required fields are filled
                            if (_selectedPOAValue != null &&
                                _appointmentType != null &&
                                _selectedDate != null &&
                                _selectedStartTime != null &&
                                _selectedEndTime != null &&
                                _visitType != null) {
                              final saveData = Appointment(
                                id: 0,
                                purpose: _selectedPOAValue!,
                                type: _appointmentType!.value,
                                date: _selectedDate!,
                                startTime: _selectedStartTime!,
                                endTime: _selectedEndTime!,
                                visitType: _visitType!.value,
                                inquiry: _inquiryController.text.isNotEmpty
                                    ? _inquiryController.text.trim()
                                    : null,
                                status: "Pending",
                                createdAt: DateTime.timestamp(),
                                doctorId: selectedDoctorValue,
                                userId: userSession.userAccount.id,
                                updatedAt: DateTime.timestamp(),
                              );

                              final result = await vmModify.requestAppointment(
                                saveData,
                              );

                              if (!context.mounted) return;

                              switch (result) {
                                case Ok():
                                  showSuccessDialog(
                                    context: context,
                                    title: "Appointment Requested!",
                                    message:
                                        "The appointment on ${DisplayFormat().date(saveData.date)} has been requested for booking succesfully. Please wait for the clinic to review and confirm your appointment request. Thank you!",
                                    onButtonPressed: () {
                                      Navigator.of(context).popUntil((route) {
                                        return route.isFirst;
                                      });
                                    },
                                  );

                                case Error():
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
                          } else {
                            showSnackBar(
                              context: context,
                              text:
                                  "Only authenticated users can request for appointments. Please log in or register an account if you haven't done so.",
                              color: Colors.red[900],
                            );

                            Navigator.of(context).popUntil((route) {
                              return route.isFirst;
                            });
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6FBF73),
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 0,
                        ),

                        // 👇 THIS is where your code goes
                        child: Text(
                          'Request Appointment',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
