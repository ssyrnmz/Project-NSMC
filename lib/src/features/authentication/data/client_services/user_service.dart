import 'dart:convert';

import '../../domain/user.dart';
import '../../../../core/api/api_client.dart';
import '../../../../utils/data/results.dart';

class UserAccountService {
  UserAccountService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final String _path = 'account/user/';

  // Functions:
  // Retrieve a user details (GET)
  Future<Result<User>> getUser(String id, DateTime? sync) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_user.php?id=$id&sync=${sync.toIso8601String()}'
          : '${_path}get_user.php?id=$id';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        if (response.body.trim().isNotEmpty && response.body.trim() != "null") {
          final patient = User.fromJson(json.decode(response.body));
          return Result.ok(patient);
        } else {
          return Result.error(Exception("User not found."));
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

  // Retrieve all user details (GET)
  Future<Result<List<User>>> getUsers(DateTime? sync) async {
    try {
      final fullPath = (sync != null)
          ? '${_path}get_users.php?sync=${sync.toIso8601String()}'
          : '${_path}get_users.php';

      final response = await _apiClient.get(fullPath, auth: AuthType.required);
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();

        final patient = parsed
            .map<User>((json) => User.fromJson(json))
            .toList();

        return Result.ok(patient);
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

  // Store user's information in database (POST)
  Future<Result<User>> addUserDetails(User patient) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_user.php',
        body: patient.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(patient);
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

  // Update user's details if necessary
  Future<Result<User>> updateUserDetails(User patient) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_user.php',
        body: patient.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        print(response.body);
        return Result.ok(patient);
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
