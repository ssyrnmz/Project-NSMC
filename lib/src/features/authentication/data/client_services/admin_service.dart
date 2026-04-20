import 'dart:convert';

import '../../domain/admin.dart';
import '../../../../core/api/api_client.dart';
import '../../../../utils/data/results.dart';

class AdminAccountService {
  AdminAccountService({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final String _path = 'account/admin/';

  //▫️Functions:
  // Retrieve a user details (GET)
  Future<Result<Admin>> getAdmin(String id) async {
    try {
      final response = await _apiClient.get(
        '${_path}get_staff.php?id=$id',
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        if (response.body.trim().isNotEmpty && response.body.trim() != "null") {
          final staff = Admin.fromJson(json.decode(response.body));
          return Result.ok(staff);
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

  // Get all admins — SuperAdmin access only (GET)
  Future<Result<List<Admin>>> getAdmins() async {
    try {
      final response = await _apiClient.get(
        '${_path}get_all_staff.php',
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        final admins = parsed.map<Admin>((j) => Admin.fromJson(j)).toList();
        return Result.ok(admins);
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

  // Store admin's information in database — SuperAdmin access only (POST)
  Future<Result<Admin>> addAdmin(Admin administrator) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_staff.php',
        body: administrator.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(administrator);
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

  // Update an admin's role or active status — SuperAdmin access only (POST)
  Future<Result<Admin>> updateAdmin(Admin administrator) async {
    try {
      final response = await _apiClient.post(
        '${_path}update_staff.php',
        body: administrator.toJson(),
        auth: AuthType.required,
      );

      if (response.statusCode == 200) {
        return Result.ok(administrator);
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