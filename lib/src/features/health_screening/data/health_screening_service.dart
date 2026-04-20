import 'dart:io';
import 'dart:convert';

import '../domain/health_screening.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class HealthScreeningService {
  // Constructor
  HealthScreeningService({required ApiClient apiClient})
    : _apiClient = apiClient;

  // Variables
  final ApiClient _apiClient;
  final String _path = 'health_screening/';

  // Functions:
  // Retrieve all health screening packages (GET)
  Future<Result<List<HealthScreening>>> getHealthScreenings(
    DateTime? sync,
  ) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_health_screenings.php?sync=${sync.toIso8601String()}'
          : '${_path}get_health_screenings.php';

      final response = await _apiClient.get(fullPath, auth: AuthType.none);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final package = parsed
            .map<HealthScreening>((json) => HealthScreening.fromJson(json))
            .toList();
        return Result.ok(package);
      } else {
        return Result.error(
          Exception(
            'Invalid Response: ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Store a new health screening package (POST)
  Future<Result<HealthScreening>> addHealthScreening(
    HealthScreening package,
  ) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_health_screening.php',
        body: package.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(package);
      } else {
        return Result.error(
          Exception(
            'Invalid Response: ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Replace a health screening package with updated details (POST)
  Future<Result<HealthScreening>> editHealthScreening(
    HealthScreening package,
  ) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_health_screening.php',
        body: package.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(package);
      } else {
        return Result.error(
          Exception(
            'Invalid Response ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }

  // Save image into the server first and receive path (POST)
  Future<Result<String>> saveImageToFile(File image) async {
    try {
      final response = await _apiClient.postFile(
        '${_path}save_image_health_screening.php',
        item: image,
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        final filePath = json.decode(response.body);
        return Result.ok('${_apiClient.baseUrl}$filePath');
      } else {
        return Result.error(
          Exception(
            'Invalid Response ${response.body} (${response.statusCode})',
          ),
        );
      }
    } on Exception catch (error) {
      return Result.error(error);
    }
  }
}
