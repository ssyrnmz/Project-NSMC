import 'dart:convert';

import '../domain/public_holiday.dart';
import '../../../core/api/api_client.dart';
import '../../../utils/data/results.dart';

class PublicHolidayService {
  PublicHolidayService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  final String _path = 'appointment/';

  // Get all holidays — no auth needed (users need this for date pickers)
  Future<Result<List<PublicHoliday>>> getHolidays() async {
    try {
      final response = await _apiClient.get(
        '${_path}get_holidays.php',
        auth: AuthType.none,
      );
      if (response.statusCode == 200) {
        final parsed = (json.decode(response.body) as List)
            .map((e) => e as Map<String, dynamic>)
            .toList();
        final holidays =
            parsed.map<PublicHoliday>((j) => PublicHoliday.fromJson(j)).toList();
        return Result.ok(holidays);
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

  // Add a holiday — admin only
  Future<Result<PublicHoliday>> addHoliday(PublicHoliday holiday) async {
    try {
      final response = await _apiClient.post(
        '${_path}add_holiday.php',
        body: holiday.toJson(),
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        return Result.ok(holiday);
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

  // Delete a holiday — admin only
  Future<Result<bool>> deleteHoliday(int id) async {
    try {
      final response = await _apiClient.post(
        '${_path}delete_holiday.php',
        body: {'id': id.toString()},
        auth: AuthType.required,
      );
      if (response.statusCode == 200) {
        return Result.ok(true);
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