import 'dart:convert';

import '../domain/speciality.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class SpecialityService {
  // Constructor
  SpecialityService({required ApiClient apiClient}) : _apiClient = apiClient;

  // Variables
  final ApiClient _apiClient;
  final String _path = 'doctor/';

  // Functions:
  // Retrieve all doctor details (GET)
  Future<Result<List<Speciality>>> getSpecialities(DateTime? sync) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_specialities.php?sync=${sync.toIso8601String()}'
          : '${_path}get_specialities.php';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final speciality = parsed
            .map<Speciality>((json) => Speciality.fromJson(json))
            .toList();

        return Result.ok(speciality);
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
}
