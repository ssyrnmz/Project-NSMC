import 'dart:convert';

import '../domain/doctor.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class DoctorService {
  //▫️Constructor
  DoctorService({required ApiClient apiClient}) : _apiClient = apiClient;

  //▫️Variables
  final ApiClient _apiClient;
  final String _path = 'doctor/';

  //▫️Functions:
  // Retrieve all doctor details (GET)
  Future<Result<List<Doctor>>> getDoctors(DateTime? sync) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_doctors.php?sync=${sync.toIso8601String()}'
          : '${_path}get_doctors.php';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final doc = parsed
            .map<Doctor>((json) => Doctor.fromJson(json))
            .toList();

        return Result.ok(doc);
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

  // Store a new doctor and their details (POST)
  Future<Result<Doctor>> addDoctor(Doctor doc) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_doctor.php',
        body: doc.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(doc);
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

  // Replace a doctors's details with updated details (POST)
  Future<Result<Doctor>> editDoctor(Doctor doc) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_doctor.php',
        body: doc.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(doc);
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
