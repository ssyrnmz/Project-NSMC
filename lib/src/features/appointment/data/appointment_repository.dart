import 'appointment_service.dart';
import '../domain/appointment.dart';
import '../../../utils/data/results.dart';

class AppointmentRepository {
  //▫️Constructor:
  AppointmentRepository({required AppointmentService appointmentService})
    : _appointmentService = appointmentService;

  //▫️Variables:
  final AppointmentService _appointmentService;
  DateTime? _lastSync;
  List<Appointment> _cache = [];

  // Track who the cache belongs to — either a user ID or 'admin'
  // If the logged-in identity changes, cache must be cleared
  String? _cacheOwner;

  //▫️Functions:
  // Get appointments (user access)
  Future<Result<List<Appointment>>> getAppointmentsOfUser(String id) async {
    // Clear cache if switching from a different user or from admin
    if (_cacheOwner != id) {
      clearCache();
      _cacheOwner = id;
    }

    final result = await _appointmentService.getAppointment(id, _lastSync);

    switch (result) {
      case Ok<List<Appointment>>():
        final appointments = result.value;

        if (appointments.isNotEmpty) {
          _updateCache(appointments);
          _lastSync = appointments.first.updatedAt;
        }

        return Result.ok(List.from(_cache));
      case Error<List<Appointment>>():
        return Result.error(result.error);
    }
  }

  // Get appointments (admin access)
  Future<Result<List<Appointment>>> getAllAppointments() async {
    // Clear cache if switching from a user session to admin
    if (_cacheOwner != 'admin') {
      clearCache();
      _cacheOwner = 'admin';
    }

    final result = await _appointmentService.getAppointments(_lastSync);

    switch (result) {
      case Ok<List<Appointment>>():
        final appointments = result.value;

        if (appointments.isNotEmpty) {
          _updateCache(appointments);
          _lastSync = appointments.first.updatedAt;
        }

        return Result.ok(List.from(_cache));
      case Error<List<Appointment>>():
        return Result.error(result.error);
    }
  }

  // Create a new appointment
  Future<Result<Appointment>> addAppointment(Appointment appointment) async {
    final result = await _appointmentService.addAppointment(appointment);
    return result;
  }

  // Update appointment (Status only & reschedule)
  Future<Result<Appointment>> editAppointment(Appointment appointment) async {
    final result = await _appointmentService.editAppointment(appointment);
    return result;
  }

  // Clear cache and sync state — call on logout or session change
  void clearCache() {
    _cache = [];
    _lastSync = null;
    _cacheOwner = null;
  }

  // Helps update cache by adding new data, replace old data with updated details
  void _updateCache(List<Appointment> appointments) {
    if (_cache.isNotEmpty) {
      for (final data in appointments) {
        final index = _cache.indexWhere((apt) => apt.id == data.id);

        if (index != -1) {
          _cache[index] = data; // Update existing record
        } else {
          _cache.add(data); // Add new record
        }
      }
    } else {
      _cache = List.from(appointments); // First load
    }
  }
}
