import 'dart:convert';

import '../domain/emergency_contact.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class EmergencyContactService {
  //▫️Constructor
  EmergencyContactService({required ApiClient apiClient})
    : _apiClient = apiClient;

  //▫️Variables
  final ApiClient _apiClient;
  final String _path = 'account/user/';

  //▫️Functions:
  // Retrieve emergency contact of a user (GET)
  Future<Result<EmergencyContact?>> getEmergencyContact(
    String id,
    DateTime? sync,
  ) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_emergency_contact.php?id=$id&sync=${sync.toIso8601String()}'
          : '${_path}get_emergency_contact.php?id=$id';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        if (response.body.trim().isNotEmpty && response.body.trim() != "null") {
          final contact = EmergencyContact.fromJson(json.decode(response.body));
          return Result.ok(contact);
        } else {
          return Result.ok(null);
        }
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

  // Store a new emergency contact of a user (POST)
  Future<Result<EmergencyContact>> addEmergencyContact(
    EmergencyContact contact,
  ) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_emergency_contact.php',
        body: contact.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        print(response.body);
        return Result.ok(contact);
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

  // Replace a user's emergency contact with updated details (POST)
  Future<Result<EmergencyContact>> editEmergencyContact(
    EmergencyContact contact,
  ) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_emergency_contact.php',
        body: contact.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(contact);
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
