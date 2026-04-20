import '../client_services/user_service.dart';
import '../../domain/user.dart';
import '../../../../utils/data/results.dart';

class UserRepository {
  //▫️Constructor:
  UserRepository({required UserAccountService userService})
    : _userService = userService;

  //▫️Variables:
  final UserAccountService _userService;
  DateTime? _lastSync;
  List<User> _cache = [];

  //▫️Functions (admin access only):
  // Get users
  Future<Result<List<User>>> getUsers() async {
    final result = await _userService.getUsers(_lastSync);

    switch (result) {
      case Ok<List<User>>():
        final users = result.value;

        // Only updates when there is new data after last synced
        if (users.isNotEmpty) {
          _updateCache(users);
          _lastSync = users.first.updatedAt;
        }

        return Result.ok(_cache);
      case Error<List<User>>():
        return Result.error(result.error);
    }
  }

  //▫️Helpers:
  // Update cache by adding new data, replace old data with updated details
  void _updateCache(List<User> users) {
    if (_cache.isNotEmpty) {
      for (final data in users) {
        final index = _cache.indexWhere(
          (user) => user.id == data.id,
        ); // Check if there are the same object, returns its index from the cache list

        if (index != -1) {
          _cache[index] = data; // Update existing record
        } else {
          _cache.add(data); // Add new record
        }
      }
    } else {
      _cache = List.from(users); // No cache/first initialization of app
    }
  }
}
