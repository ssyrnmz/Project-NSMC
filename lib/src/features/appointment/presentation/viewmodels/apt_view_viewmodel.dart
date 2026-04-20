import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:intl/intl.dart';

import '../../data/appointment_repository.dart';
import '../../data/public_holiday_repository.dart';
import '../../domain/appointment.dart';
import '../../domain/public_holiday.dart';
import '../../../authentication/data/account_session.dart';
import '../../../authentication/data/repositories/user_repository.dart';
import '../../../authentication/domain/user.dart';
import '../../../authentication/domain/session.dart';
import '../../../doctor/data/doctor_repository.dart';
import '../../../doctor/domain/doctor.dart';
import '../../../../utils/data/results.dart';

class AppointmentViewModel extends ChangeNotifier {
  //▫️Constructor:
  AppointmentViewModel({
    required AppointmentRepository appointmentRepository,
    required DoctorRepository doctorRepository,
    required UserRepository userRepository,
    required AccountSession accountSession,
    required PublicHolidayRepository holidayRepository,
  }) : _appointmentRepository = appointmentRepository,
       _doctorRepository = doctorRepository,
       _userRepository = userRepository,
       _accountSession = accountSession,
       _holidayRepository = holidayRepository;

  //▫️Variables:
  final AppointmentRepository _appointmentRepository;
  final DoctorRepository _doctorRepository;
  final UserRepository _userRepository;
  final AccountSession _accountSession;
  final PublicHolidayRepository _holidayRepository;

  // Repository data
  List<Appointment> _appointment = [];
  List<Doctor> _doctors = [];
  List<User> _users = [];
  List<PublicHoliday> _holidays = [];
  Map<int, Appointment> _appointmentMap = {};

  // Sorted Appointment Lists
  List<Appointment> _pendingAppointments = [];
  List<Appointment> _approvedAppointments = [];
  List<Appointment> _confirmedAppointments = [];

  // Special Sorted Appointment Lists
  List<Appointment> _upcomingAppointments = [];
  Map<String, List<Appointment>> _historyAppointments = {};

  // Utils|Miscs.
  bool _isLoading = false;
  bool _sortNewest = true;
  String? _errorMessage;

  //▫️Getters:
  List<Appointment> get pending => _pendingAppointments;
  List<Appointment> get approved => _approvedAppointments;
  List<Appointment> get confirmed => _confirmedAppointments;
  List<Appointment> get upcoming => _upcomingAppointments;
  List<Doctor> get doctors => _doctors;
  List<PublicHoliday> get holidays => _holidays;
  bool get isLoading => _isLoading;
  bool get currentSort => _sortNewest;
  String? get message => _errorMessage;

  // Get the doctor based on appointment doctor's ID
  Doctor? getDoctor(Appointment appointment) {
    return _doctors.firstWhereOrNull((d) => d.id == appointment.doctorId);
  }

  // Get the user based on appointment user's ID
  User getUser(Appointment appointment) {
    return _users.firstWhere((u) => u.id == appointment.userId);
  }

  // Get the appointment based on its ID
  Appointment? getAppointment(int id) {
    return _appointmentMap[id];
  }

  // Get the history appointments based on user's ID
  List<Appointment> getHistoryAppointments(String id) {
    return _historyAppointments[id] ?? [];
  }

  // Return doctor list based on appointment purpose for appointment booking
  List<Doctor> doctorList(int? speciality) {
    if (speciality != null) {
      return (speciality > 0 && speciality < 27)
          ? _doctors.where((d) => d.specialityId == speciality).toList()
          : _doctors;
    } else {
      return [];
    }
  }

  // Load public holidays from database into _holidays cache
  Future<void> loadHolidays() async {
    final result = await _holidayRepository.getHolidays();
    if (result is Ok<List<PublicHoliday>>) {
      _holidays = result.value;
      notifyListeners();
    }
    // Silently fall back — date picker will still block Sundays
  }

  // Build the list of disabled dates for the date picker.
  // Combines DB holidays + all Sundays in the range.
  List<DateTime> closedDates(DateTime start, DateTime end) {
    final disabledDates = _holidays
        .map((h) => DateTime(h.date.year, h.date.month, h.date.day))
        .toList();

    DateTime current = start;
    while (current.isBefore(end.add(const Duration(days: 1)))) {
      if (current.weekday == DateTime.sunday) {
        disabledDates.add(
          DateTime(current.year, current.month, current.day),
        );
      }
      current = current.add(const Duration(days: 1));
    }

    return disabledDates;
  }

  //▫️Functions:
  // Load data into lists
  Future<Result> load() async {
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    final session = _accountSession.session;

    if (session == null) {
      _errorMessage =
          "The system cannot found your session. Please try again if you were intending to use the app.";
      return Result.error(Exception(_errorMessage));
    }

    try {
      // Load holidays from DB (non-blocking — failures are swallowed)
      await loadHolidays();

      final docResult = await _doctorRepository.getDoctors();

      switch (docResult) {
        case Ok<List<Doctor>>():
          _doctors = docResult.value;
          debugPrint("Get doctors: ${docResult.value}");
        case Error<List<Doctor>>():
          _errorMessage =
              "There's an issue in fetching appointments data. Try again later.";
          debugPrint("Failed to get doctors: ${docResult.error}");
          return docResult;
      }

      switch (session) {
        case UserSession():
          final aptResult = await _appointmentRepository.getAppointmentsOfUser(
            session.userAccount.id,
          );

          switch (aptResult) {
            case Ok<List<Appointment>>():
              _appointment = aptResult.value;
              _appointmentMap = {for (var a in _appointment) a.id: a};
              _sortData();
              _categorizeAppointments();
              _loadUpcomingAppointments();
              debugPrint("Get appointments: ${aptResult.value}");
            case Error<List<Appointment>>():
              _errorMessage =
                  "There's an issue in fetching your appointment's data. Try again later.";
              debugPrint("Failed to get user's appointment: ${aptResult.error}");
          }

          return aptResult;

        case AdminSession():
          final userResult = await _userRepository.getUsers();

          switch (userResult) {
            case Ok<List<User>>():
              _users = userResult.value;
              debugPrint("Get all users: ${userResult.value}");
            case Error<List<User>>():
              _errorMessage =
                  "There's an issue in fetching all appointments data. Try again later or check for issues surrounding application.";
              debugPrint("Failed to get users: ${userResult.error}");
          }

          final aptResult = await _appointmentRepository.getAllAppointments();

          switch (aptResult) {
            case Ok<List<Appointment>>():
              _appointment = aptResult.value;
              _appointmentMap = {for (var a in _appointment) a.id: a};
              _sortData();
              _categorizeAppointments();
              _loadUserHistoryAppointments();
              debugPrint("Get all appointments: ${aptResult.value}");
            case Error<List<Appointment>>():
              _errorMessage =
                  "There's an issue in fetching all appointments data. Try again later or check for issues surrounding application.";
              debugPrint("Failed to get all appointments: ${aptResult.error}");
          }

          return aptResult;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create the search list
  Map<String, int> createSearchList(List<Appointment> list) {
    return Map.fromEntries(
      list.map((a) => MapEntry(DateFormat('dd MMM yyyy').format(a.date), a.id)),
    );
  }

  // Sort the appointments based on latest/oldest appointment for display
  void sortAppointments() {
    _sortNewest = !_sortNewest;
    _appointment.sort((a, b) {
      return _sortNewest
          ? b.updatedAt.compareTo(a.updatedAt)
          : a.updatedAt.compareTo(b.updatedAt);
    });
    _categorizeAppointments();
    notifyListeners();
  }

  // Helper to sort repository data whenever cached
  void _sortData() {
    _appointment.sort((a, b) => b.date.compareTo(a.date));
    _doctors.sort(
      (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
    );
  }

  // Helper to sort appointments based on their status
  void _categorizeAppointments() {
    _pendingAppointments = _appointment
        .where((a) => (a.status == "Pending"))
        .toList();
    _approvedAppointments = _appointment
        .where((a) => (a.status == "Approved"))
        .toList();
    _confirmedAppointments = _appointment
        .where((a) => (a.status == "Confirmed"))
        .toList();
  }

  // Helper to load history appointments based on user's ID (admin only)
  void _loadUserHistoryAppointments() {
    final Map<String, List<Appointment>> historyApt = {};
    for (var apt in _confirmedAppointments) {
      historyApt.putIfAbsent(apt.userId, () => []).add(apt);
    }
    _historyAppointments = historyApt;
  }

  // Helper to create upcoming appointments (users only)
  void _loadUpcomingAppointments() {
    final currentDateTime = DateTime.now();
    _upcomingAppointments = _confirmedAppointments.where((a) {
      final appointmentDateTime = DateTime(
        a.date.year,
        a.date.month,
        a.date.day,
        a.startTime.hour,
        a.startTime.minute,
      );
      return appointmentDateTime.isAfter(currentDateTime);
    }).toList();
  }
}