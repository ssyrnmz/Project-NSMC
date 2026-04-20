import 'public_holiday_service.dart';
import '../domain/public_holiday.dart';
import '../../../utils/data/results.dart';

class PublicHolidayRepository {
  PublicHolidayRepository({required PublicHolidayService holidayService})
      : _service = holidayService;

  final PublicHolidayService _service;
  List<PublicHoliday> _cache = [];

  // Get all holidays — returns cache on network error so date pickers still work
  Future<Result<List<PublicHoliday>>> getHolidays() async {
    final result = await _service.getHolidays();
    if (result is Ok<List<PublicHoliday>>) {
      _cache = result.value;
      return Result.ok(_cache);
    }
    if (_cache.isNotEmpty) return Result.ok(_cache);
    return result;
  }

  Future<Result<PublicHoliday>> addHoliday(PublicHoliday holiday) =>
      _service.addHoliday(holiday);

  Future<Result<bool>> deleteHoliday(int id) =>
      _service.deleteHoliday(id);
}