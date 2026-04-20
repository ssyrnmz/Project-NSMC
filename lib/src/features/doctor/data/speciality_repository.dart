import 'speciality_service.dart';
import '../domain/speciality.dart';
import '../../../utils/data/results.dart';

class SpecialityRepository {
  //▫️Constructor:
  SpecialityRepository({required SpecialityService specialityService})
    : _specialityService = specialityService;

  //▫️Variables:
  final SpecialityService _specialityService;
  DateTime? _lastSync;
  List<Speciality> _cache = [];

  //▫️Functions:
  // Get specialities
  Future<Result<List<Speciality>>> getSpecialities() async {
    final result = await _specialityService.getSpecialities(_lastSync);

    switch (result) {
      case Ok<List<Speciality>>():
        final specialities = result.value;

        // Only updates when there is new data after last synced
        if (specialities.isNotEmpty) {
          _updateCache(specialities);
          _lastSync = specialities.first.updatedAt;
        }

        return Result.ok(_cache);
      case Error<List<Speciality>>():
        return Result.error(result.error);
    }
  }

  //▫️Helpers:
  // Update cache by adding new data, replace old data with updated details
  void _updateCache(List<Speciality> specialities) {
    if (_cache.isNotEmpty) {
      for (final data in specialities) {
        final index = _cache.indexWhere(
          (spec) => spec.id == data.id,
        ); // Check if there are the same object, returns its index from the cache list

        if (index != -1) {
          _cache[index] = data; // Update existing record
        } else {
          _cache.add(data); // Add new record
        }
      }
    } else {
      _cache = List.from(specialities); // No cache/first initialization of app
    }
  }
}
