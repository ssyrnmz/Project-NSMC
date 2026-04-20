class EmergencyContact {
  //▫️Variables
  final int id;
  final String name;
  final String relationship;
  final String? email;
  final String? phoneNumber;
  final String? homeAddress;
  final String userId;
  final DateTime updatedAt;

  //▫️Constructor
  EmergencyContact({
    required this.id,
    required this.name,
    required this.relationship,
    required this.email,
    required this.phoneNumber,
    required this.homeAddress,
    required this.userId,
    required this.updatedAt,
  });

  //▫️Converter Functions
  // Convert json data into emergency contact class when retrieved
  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: int.parse(json['ec_no'].toString()),
      name: json['ec_name'] as String,
      relationship: json['ec_relationship'] as String,
      email: json['ec_email'] as String?,
      phoneNumber: json['ec_phone_number'] as String?,
      homeAddress: json['record_file'] as String?,
      userId: json['user_id'] as String,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert emergency contact data into json format for sending
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.toString(),
      'name': name,
      'relationship': relationship,
      'email': email,
      'phoneNumber': phoneNumber,
      'homeAddress': homeAddress,
      'userId': userId,
    };
  }
}
