import 'doctor_service.dart';
import '../domain/doctor.dart';
import '../../../utils/data/results.dart';

class DoctorRepository {
  //▫️Constructor:
  DoctorRepository({required DoctorService doctorService})
    : _doctorService = doctorService;

  //▫️Variables:
  final DoctorService _doctorService;
  DateTime? _lastSync;
  List<Doctor> _cache = [];

  //▫️Functions:
  // Get doctors
  Future<Result<List<Doctor>>> getDoctors() async {
    final result = await _doctorService.getDoctors(_lastSync);

    switch (result) {
      case Ok<List<Doctor>>():
        final doctors = result.value;

        // Only updates when there is new data after last synced
        if (doctors.isNotEmpty) {
          _updateCache(doctors);
          _lastSync = doctors.first.updatedAt;
        }

        return Result.ok(_cache);
      case Error<List<Doctor>>():
        return Result.error(result.error);
    }
  }

  // Add a new doctor and their information
  Future<Result<Doctor>> addDoctor(Doctor doctor) async {
    final result = await _doctorService.addDoctor(doctor);
    return result;
  }

  // Update a doctor's information or archive it
  Future<Result<Doctor>> editDoctor(Doctor doctor) async {
    final result = await _doctorService.editDoctor(doctor);

    // Updates cache when the operation was successful
    if (result is Ok<Doctor>) {
      // Doctor is archived/deleted
      if (doctor.archived) {
        _cache.removeWhere((doc) => doc.id == doctor.id);
        _lastSync = result.value.updatedAt;
      }
    }

    return result;
  }

  //▫️Helpers:
  // Update cache by adding new data, replace old data with updated details
  void _updateCache(List<Doctor> doctors) {
    if (_cache.isNotEmpty) {
      for (final data in doctors) {
        final index = _cache.indexWhere(
          (doc) => doc.id == data.id,
        ); // Check if there are the same object, returns its index from the cache list

        if (index != -1) {
          _cache[index] = data; // Update existing record
        } else {
          _cache.add(data); // Add new record
        }
      }
    } else {
      _cache = List.from(doctors); // No cache/first initialization of app
    }
  }
}
