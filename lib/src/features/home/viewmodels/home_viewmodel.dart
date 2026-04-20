import 'package:flutter/material.dart';

import '../../authentication/data/account_session.dart';
import '../../authentication/domain/session.dart';
import '../../appointment/data/appointment_repository.dart';
import '../../appointment/domain/appointment.dart';
import '../../health_screening/data/health_screening_repository.dart';
import '../../health_screening/domain/health_screening.dart';
import '../../appointment/presentation/views/apt_booking_screen.dart'; // Screen list
import '../../appointment/presentation/views/apt_requested_screen.dart';
import '../../appointment/presentation/views/apt_tracking_screen.dart';
import '../../doctor/presentation/views/doctor_view_screen.dart';
import '../../health_screening/presentation/views/hsp_view_screen.dart';
import '../../medical_record/presentation/views/mr_view_screen.dart';
import '../../../utils/data/results.dart';

class HomeViewModel extends ChangeNotifier {
  //▫️Constructor:
  HomeViewModel({
    required AccountSession accountSession,
    required AppointmentRepository appointmentRepository,
    required HealthScreeningRepository healthScreeningRepository,
  }) : _accountSession = accountSession,
       _appointmentRepository = appointmentRepository,
       _healthScreeningRepository = healthScreeningRepository;

  //▫️Variables:
  // Repositories
  final AccountSession _accountSession;
  final AppointmentRepository _appointmentRepository;
  final HealthScreeningRepository _healthScreeningRepository;

  // Main Contents
  late Map<String, dynamic> _searchList = {};
  List<Appointment> _pendingAppointments = [];
  List<HealthScreening> _infoPackages = [];
  final Map<String, bool> _readState = {};   // key=package.name, true=read
  final Set<String> _dismissed = {};         // dismissed package names

  // Utils|Miscs.
  bool _isLoading = false;
  String? _errorMessage;

  //▫️Getters:
  Map<String, dynamic> get searchList => _searchList;
  List<Appointment> get pendingAppointments => _pendingAppointments;
  List<HealthScreening> get infoPackages => _infoPackages;

  /// Packages not yet dismissed
  List<HealthScreening> get visiblePackages =>
      _infoPackages.where((p) => !_dismissed.contains(p.name)).toList();

  /// Count of unread, non-dismissed packages — used by bottom nav badge
  int get unreadCount => _infoPackages
      .where((p) => !_dismissed.contains(p.name) && _readState[p.name] != true)
      .length;

  bool isRead(String name) => _readState[name] == true;

  void markRead(String name) {
    if (_readState[name] != true) {
      _readState[name] = true;
      notifyListeners();
    }
  }

  void dismiss(String name) {
    _dismissed.add(name);
    notifyListeners();
  }

  void dismissAll() {
    for (final p in _infoPackages) {
      _dismissed.add(p.name);
    }
    notifyListeners();
  }
  bool get isLoading => _isLoading;
  String? get message => _errorMessage;

  //▫️Functions:
  // Load contents based on role (Hardcoded & Database data)
  Future<Result> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final session = _accountSession.session;

      if (session == null) {
        _errorMessage =
            "There's an issue where the system cannot load home screen contents. Please try again later.";
        return Result.error(Exception("No active session found."));
      }

      // Load appointments and home screen redirections
      switch (session) {
        case UserSession():
          _searchList = {
            "Appointment Tracking": const AppointmentTrackingViewScreen(),
            "Health Packages": const HealthScreeningViewScreen(),
            "Medical Report": const MedicalRecordViewScreen(),
            "Our Doctor": const DoctorViewScreen(),
            "Requested Appointments": const AppointmentBookingScreen(),
          };
        case AdminSession():
          _searchList = {
            "Health Packages": const HealthScreeningViewScreen(),
            "Our Doctor": const DoctorViewScreen(),
            "Requested Appointments": const AppointmentRequestedScreen(),
          };

          final aptResult = await _appointmentRepository.getAllAppointments();

          switch (aptResult) {
            case Ok<List<Appointment>>():
              _pendingAppointments = aptResult.value
                  .where((a) => (a.status == "Pending"))
                  .toList();
              debugPrint("Get all appointments: ${aptResult.value}");
            case Error<List<Appointment>>():
              _errorMessage =
                  "There's an issue in fetching appointments data. Please try again later.";
              debugPrint("Failed to get all appointments: ${aptResult.error}");
              return Result.error(aptResult.error);
          }
      }

      // Load packages for information screen
      final packageResult = await _healthScreeningRepository
          .getHealthScreenings();

      switch (packageResult) {
        case Ok<List<HealthScreening>>():
          _infoPackages = packageResult.value;
          sortData();
          debugPrint("Get all packages: ${packageResult.value}");
        case Error<List<HealthScreening>>():
          _errorMessage =
              "There's an issue in fetching packages data. Please try again later.";
          debugPrint("Failed to get all packages: ${packageResult.error}");
      }
      return packageResult;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Return time for user greetings
  String getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  // Sort packages by date (Newest to Oldest)
  void sortData() {
    _infoPackages.sort((a, b) => b.id.compareTo(a.id));
  }
}
