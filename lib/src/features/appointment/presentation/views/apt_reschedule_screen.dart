import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rounded_date_picker/flutter_rounded_date_picker.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:provider/provider.dart';

import '../viewmodels/apt_modify_viewmodel.dart';
import '../viewmodels/apt_view_viewmodel.dart';
import '../../domain/appointment.dart';
import '../../../authentication/data/account_session.dart';
import '../../../doctor/domain/doctor.dart';
import '../../../../config/constants/global_values.dart';
import '../../../../core/widgets/loading_screen.dart';
import '../../../../utils/data/results.dart';
import '../../../../utils/ui/display_formatters.dart';
import '../../../../utils/ui/show_snackbar.dart';
import '../../../../utils/ui/show_success_dialogue.dart';

class AppointmentEditScreen extends StatefulWidget {
  const AppointmentEditScreen({super.key, required this.appointment});

  final Appointment appointment;

  @override
  State<AppointmentEditScreen> createState() => _AppointmentEditScreenState();
}

class _AppointmentEditScreenState extends State<AppointmentEditScreen> {
  //▫️Variables:
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _dateController;
  late TextEditingController _timeController;

  Doctor? _doctor;
  DateTime? _date;
  String? _selectedTimeSlot;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  //▫️State initialization & disposal:
  @override
  void initState() {
    super.initState();

    final vmInitial = context.read<AppointmentViewModel>();

    _doctor = vmInitial.getDoctor(widget.appointment);
    _date = widget.appointment.date;

    // Pre-select the existing time slot label if it matches
    final existingStart = widget.appointment.startTime;
    _selectedStartTime = existingStart;
    _selectedEndTime = widget.appointment.endTime;

    // Try to match existing time to a slot label
    for (final entry in timeOptions.entries) {
      if (entry.value['start'] == existingStart) {
        _selectedTimeSlot = entry.key;
        break;
      }
    }
    for (final entry in timeSaturdayOptions.entries) {
      if (entry.value['start'] == existingStart) {
        _selectedTimeSlot ??= entry.key;
        break;
      }
    }

    _dateController = TextEditingController(
      text: DisplayFormat().dateSlash(widget.appointment.date),
    );

    _timeController = TextEditingController(
      text: DisplayFormat().timeOnly(widget.appointment.startTime),
    );
  }

  @override
  void dispose() {
    _dateController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  //▫️Main UI:
  @override
  Widget build(BuildContext context) {
    final session = context.watch<AccountSession>();
    final vmModify = context.watch<AppointmentModifyViewModel>();
    final vmData = context.read<AppointmentViewModel>();

    // Get speciality ID from appointment purpose
    final int? specialityId =
        appointmentPurposeOptions[widget.appointment.purpose];

    // Filter doctors by appointment purpose — same rule as booking screen
    final List<Doctor> filteredDoctors = vmData.doctorList(specialityId);

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
              color: Color(0xFF4D7C4A),
            ),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Edit Requested Appointment',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: const Color(0xFF1E1E1E),
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: const Color(0xFFE6E6E6), height: 1),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                // Non-editable fields
                buildStaticBox(
                  ' Purpose of Appointment',
                  widget.appointment.purpose,
                ),
                buildStaticBox(
                  ' Appointment Type',
                  widget.appointment.type,
                ),

                // ✅ FIX 1: Doctor filtered by appointment purpose
                buildDropdownField(
                  ' Selected Doctor',
                  filteredDoctors,
                ),

                // ✅ FIX 2: Date blocks Sundays and public holidays
                buildDateField(' Date', vmData),

                // ✅ FIX 3: Time uses allowed time slots like booking screen
                buildTimeSlotField(' Time'),

                buildStaticBox(
                  ' Visit Type',
                  widget.appointment.visitType,
                ),
                buildStaticBox(
                  ' Inquiry',
                  widget.appointment.inquiry ?? '-',
                ),

                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      if (_date == null) {
                        showSnackBar(
                          context: context,
                          text: 'Please select a date.',
                          color: Colors.red[900],
                        );
                        return;
                      }
                      if (_selectedStartTime == null ||
                          _selectedEndTime == null) {
                        showSnackBar(
                          context: context,
                          text: 'Please select a time slot.',
                          color: Colors.red[900],
                        );
                        return;
                      }

                      final saveData = Appointment(
                        id: widget.appointment.id,
                        purpose: widget.appointment.purpose,
                        type: widget.appointment.type,
                        date: _date!,
                        startTime: _selectedStartTime!,
                        endTime: _selectedEndTime!,
                        visitType: widget.appointment.visitType,
                        inquiry: widget.appointment.inquiry,
                        status: widget.appointment.status,
                        createdAt: widget.appointment.createdAt,
                        doctorId: _doctor?.id,
                        userId: widget.appointment.userId,
                        updatedAt: widget.appointment.updatedAt,
                      );

                      final result =
                          await vmModify.rescheduleAppointment(saveData);

                      switch (result) {
                        case Ok():
                          if (context.mounted) {
                            showSuccessDialog(
                              context: context,
                              title: 'Appointment Rescheduled!',
                              message: (session.role == UserRole.admin)
                                  ? (() {
                                      try { return "You have successfully rescheduled \${vmData.getUser(saveData).fullName}'s appointment."; }
                                      catch (_) { return "Appointment rescheduled successfully."; }
                                    })()
                                  : 'You have successfully rescheduled your appointment. Thank you.',
                              onButtonPressed: () {
                                vmData.load();
                                Navigator.of(context).popUntil((route) {
                                  return route.settings.name ==
                                          '/appointmentListA' ||
                                      route.settings.name ==
                                          '/appointmentListU' ||
                                      route.isFirst;
                                });
                              },
                            );
                          }
                        case Error():
                          if (context.mounted) {
                            showSnackBar(
                              context: context,
                              text:
                                  'Failed to reschedule your appointment. Please try again.',
                              color: Colors.red[900],
                            );
                          }
                      }
                    } else {
                      showSnackBar(
                        context: context,
                        text:
                            'Your submission is unfinished or invalid. Please check and try again.',
                        color: Colors.red[900],
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6FBF73),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    (session.role == UserRole.admin)
                        ? 'Confirm Changes'
                        : 'Reschedule Appointment',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //▫️Helper Widgets:

  // Static read-only display field
  Widget buildStaticBox(String label, String text, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 15),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Text(
              text,
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
              maxLines: maxLines,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIX 1: Doctor dropdown filtered by appointment purpose
  Widget buildDropdownField(String label, List<Doctor> doctorOptions) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<Doctor?>(
                  isExpanded: true,
                  value: _doctor,
                  hint: Text(
                    'Select doctor',
                    style: GoogleFonts.poppins(
                      color: const Color(0xFF9E9E9E),
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  items: [null, ...doctorOptions].map((Doctor? item) {
                    return DropdownMenuItem<Doctor?>(
                      value: item,
                      child: SizedBox(
                        width: constraints.maxWidth - 32,
                        child: Text(
                          item != null
                              ? item.name.toUpperCase()
                              : 'ANY DOCTOR',
                          style: GoogleFonts.poppins(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (Doctor? value) {
                    setState(() => _doctor = value);
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 52,
                    width: constraints.maxWidth,
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFE0E0E0), width: 1),
                      color: Colors.white,
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[700], size: 28),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 400,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
                    height: 48,
                    padding: EdgeInsets.only(left: 16, right: 16),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ✅ FIX 2: Date picker that blocks Sundays and public holidays
  Widget buildDateField(String label, AppointmentViewModel vmData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: _dateController,
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 15, vertical: 14),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFF629E5C)),
              ),
              fillColor: Colors.white,
              filled: true,
              suffixIcon: IconButton(
                icon: const Icon(Icons.calendar_today,
                    color: Color.fromARGB(255, 143, 179, 140)),
                onPressed: () async {
                  final DateTime today = DateTime.now();
                  // Same rule as booking: 2 weeks from today, up to 6 months
                  final DateTime firstDate = DateTime(
                    today.year,
                    today.month,
                    today.day + 14,
                  );
                  final DateTime lastDate = DateTime(
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
                    // Block Sundays and public holidays
                    listDateDisabled: vmData.closedDates(today, lastDate),
                    theme: ThemeData(
                      primaryColor: Colors.white,
                      colorScheme: const ColorScheme.light(
                        primary: Color(0xFF629E5C),
                        onPrimary: Colors.white,
                        onSurface: Colors.black87,
                      ),
                      dialogBackgroundColor: Colors.white,
                    ),
                    styleDatePicker: MaterialRoundedDatePickerStyle(
                      textStyleDayButton: const TextStyle(
                          fontSize: 16, color: Colors.black87),
                      textStyleMonthYearHeader: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF629E5C)),
                      textStyleDayHeader: const TextStyle(
                          color: Colors.grey, fontSize: 12),
                      textStyleButtonPositive: const TextStyle(
                          color: Color(0xFF629E5C),
                          fontWeight: FontWeight.w600),
                      textStyleButtonNegative:
                          const TextStyle(color: Color(0xFF9C9C9C)),
                      decorationDateSelected: const BoxDecoration(
                          color: Color(0xFF629E5C),
                          shape: BoxShape.circle),
                      paddingMonthHeader:
                          const EdgeInsets.symmetric(vertical: 10),
                    ),
                    styleYearPicker: MaterialRoundedYearPickerStyle(
                      textStyleYear: const TextStyle(
                          fontSize: 18, color: Colors.black87),
                      textStyleYearSelected: const TextStyle(
                          fontSize: 22,
                          color: Color(0xFF629E5C),
                          fontWeight: FontWeight.bold),
                    ),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _date = pickedDate;
                      _dateController.text =
                          '${pickedDate.day}/${pickedDate.month}/${pickedDate.year}';
                      // Reset time slot when date changes (Saturday rule)
                      _selectedTimeSlot = null;
                      _selectedStartTime = null;
                      _selectedEndTime = null;
                      _timeController.clear();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ FIX 3: Time slot dropdown matching booking screen rules
  Widget buildTimeSlotField(String label) {
    // Saturday only gets morning slot, weekdays get both slots
    final bool isSaturday =
        _date != null && _date!.weekday == DateTime.saturday;
    final Map<String, Map<String, TimeOfDay>> slots =
        isSaturday ? timeSaturdayOptions : timeOptions;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.poppins(
              color: Colors.black,
              fontSize: 15.5,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          LayoutBuilder(
            builder: (context, constraints) {
              return DropdownButtonHideUnderline(
                child: DropdownButton2<String>(
                  isExpanded: true,
                  value: _selectedTimeSlot,
                  hint: Text(
                    'Select preferred time',
                    style: GoogleFonts.poppins(
                        color: Colors.grey[500], fontSize: 14),
                  ),
                  items: slots.keys.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(
                        item,
                        style: GoogleFonts.poppins(
                            fontSize: 14.5, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? value) {
                    if (value != null) {
                      setState(() {
                        _selectedTimeSlot = value;
                        _selectedStartTime = slots[value]!['start'];
                        _selectedEndTime = slots[value]!['end'];
                        _timeController.text =
                            DisplayFormat().timeOnly(_selectedStartTime!);
                      });
                    }
                  },
                  buttonStyleData: ButtonStyleData(
                    height: 52,
                    width: constraints.maxWidth,
                    padding: const EdgeInsets.only(left: 16, right: 12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                          color: const Color(0xFFE0E0E0), width: 1),
                      color: Colors.white,
                    ),
                  ),
                  iconStyleData: IconStyleData(
                    icon: Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.grey[700], size: 28),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    maxHeight: 300,
                    width: constraints.maxWidth,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
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
              );
            },
          ),
          // Show info note when Saturday is selected
          if (isSaturday)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 14, color: Colors.orange[400]),
                  const SizedBox(width: 6),
                  Text(
                    'Saturday: Morning slot only (8.30 am – 1.00 pm)',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}