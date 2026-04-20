import 'admin.dart';
import 'user.dart';

sealed class SessionData {}

class UserSession extends SessionData {
  final User userAccount;
  UserSession(this.userAccount);
}

class AdminSession extends SessionData {
  final Admin adminAccount;
  AdminSession(this.adminAccount);
}
