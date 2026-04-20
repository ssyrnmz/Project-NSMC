/// Role constants — kept as strings to match the database column value.
class AdminRole {
  AdminRole._();

  static const String superAdmin = 'SuperAdmin';
  static const String admin = 'Admin';
  static const String receptionist = 'Receptionist';

  static const List<String> all = [superAdmin, admin, receptionist];

  static const Map<String, String> descriptions = {
    superAdmin: 'Full access — including admin management',
    admin: 'Manage appointments, doctors & packages',
    receptionist: 'View & approve appointments only',
  };

  static const Map<String, String> permissions = {
    superAdmin: 'Create/manage admins, all admin features, full data access',
    admin: 'Approve appointments, manage doctors, health screening, prescriptions',
    receptionist: 'View appointment list, approve/reject appointments',
  };

  /// Returns true if this role can create or manage other admins
  static bool canManageAdmins(String? role) => role == superAdmin;
}

class Admin {
  //▫️Variables
  final String id;
  final String name;
  final String email;
  final String? role;
  final bool unactive;
  final DateTime updatedAt;

  //▫️Constructor
  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.unactive,
    required this.updatedAt,
  });

  //▫️Converter functions
  // Convert json data into staff class when retrieved
  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['staff_id'] as String,
      name: json['staff_name'] as String,
      email: json['staff_email'] as String,
      role: json['staff_role'] as String?,
      unactive: int.parse(json['staff_unactive'].toString()) == 1
          ? true
          : false,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert staff data into json format for sending
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'email': email,
      'role': role,
      'unactive': unactive == true ? '1' : '0',
    };
  }
}