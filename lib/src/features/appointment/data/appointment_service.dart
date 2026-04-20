import 'dart:convert';

import '../domain/appointment.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class AppointmentService {
  //▫️Constructor
  AppointmentService({required ApiClient apiClient}) : _apiClient = apiClient;

  //▫️Variables
  final ApiClient _apiClient;
  final String _path = 'appointment/';

  //▫️Functions:
  // Retrieve all appointments of a user (GET)
  Future<Result<List<Appointment>>> getAppointment(
    String id,
    DateTime? sync,
  ) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_appointments.php?id=$id&sync=${sync.toIso8601String()}'
          : '${_path}get_appointments.php?id=$id';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final record = parsed
            .map<Appointment>((json) => Appointment.fromJson(json))
            .toList();

        return Result.ok(record);
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

  // Retrieve all appointments of all users (GET)
  Future<Result<List<Appointment>>> getAppointments(DateTime? sync) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_all_appointments.php?sync=${sync.toIso8601String()}'
          : '${_path}get_all_appointments.php';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final record = parsed
            .map<Appointment>((json) => Appointment.fromJson(json))
            .toList();

        return Result.ok(record);
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

  // Store a new appointment for a patient (POST)
  Future<Result<Appointment>> addAppointment(Appointment appointment) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_appointment.php',
        body: appointment.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(appointment);
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

  // Replace a patient's appointment with updated details (POST)
  Future<Result<Appointment>> editAppointment(Appointment appointment) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_appointment.php',
        body: appointment.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(appointment);
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
