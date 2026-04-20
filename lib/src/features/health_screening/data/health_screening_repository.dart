import 'dart:io';

import 'health_screening_service.dart';
import '../domain/health_screening.dart';
import '../../../utils/data/results.dart';

class HealthScreeningRepository {
  //▫️Constructor:
  HealthScreeningRepository({
    required HealthScreeningService healthScreeningService,
  }) : _healthScreeningService = healthScreeningService;

  //▫️Variables:
  final HealthScreeningService _healthScreeningService;
  DateTime? _lastSync;
  List<HealthScreening> _cache = [];

  //▫️Functions:
  // Get health screening packages
  Future<Result<List<HealthScreening>>> getHealthScreenings() async {
    final result = await _healthScreeningService.getHealthScreenings(_lastSync);

    switch (result) {
      case Ok<List<HealthScreening>>():
        final packages = result.value;

        // Only updates when there is new data after last synced
        if (packages.isNotEmpty) {
          _updateCache(packages);
          _lastSync = packages.first.updatedAt;
        }

        return Result.ok(_cache);
      case Error<List<HealthScreening>>():
        return Result.error(result.error);
    }
  }

  // Add a new package and their information
  Future<Result<HealthScreening>> addHealthScreening(
    HealthScreening package,
  ) async {
    final result = await _healthScreeningService.addHealthScreening(package);
    return result;
  }

  // Update a package's information or archive it
  Future<Result<HealthScreening>> editHealthScreening(
    HealthScreening package,
  ) async {
    final result = await _healthScreeningService.editHealthScreening(package);

    // Updates cache when the operation was successful
    if (result is Ok<HealthScreening>) {
      // Package is archived/deleted
      if (package.archived) {
        _cache.removeWhere((pkg) => pkg.id == package.id);
        _lastSync = result.value.updatedAt;
      }
    }

    return result;
  }

  // Save the image file of carousel poster
  Future<Result<String>> uploadImage(File image) async {
    return await _healthScreeningService.saveImageToFile(image);
  }

  //▫️Helpers:
  // Update cache by adding new data, replace old data with updated details
  void _updateCache(List<HealthScreening> packages) {
    if (_cache.isNotEmpty) {
      for (final data in packages) {
        final index = _cache.indexWhere(
          (package) => package.id == data.id,
        ); // Check if there are the same object, returns its index from the cache list

        if (index != -1) {
          _cache[index] = data; // Update existing package
        } else {
          _cache.add(data); // Add new package
        }
      }
    } else {
      _cache = List.from(packages); // No cache/first initialization of app
    }
  }
}
