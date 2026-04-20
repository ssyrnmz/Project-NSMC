class Doctor {
  //▫️Variables
  final int id;
  final String name;
  final String status;
  final String qualifications;
  final String specialization;
  final String? image;
  final int specialityId;
  final bool archived;
  final DateTime updatedAt;

  //▫️Constructor
  Doctor({
    required this.id,
    required this.name,
    required this.status,
    required this.qualifications,
    required this.specialization,
    required this.image,
    required this.specialityId,
    required this.archived,
    required this.updatedAt,
  });

  //▫️Converter functions
  // Convert json data into doctor class when retrieved
  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: int.parse(json['doctor_id'].toString()),
      name: json['doctor_name'] as String,
      status: json['doctor_status'] as String,
      qualifications: json['doctor_qualifications'] as String,
      specialization: json['doctor_specialization'] as String,
      image: json['doctor_image'] as String?,
      specialityId: int.parse(json['speciality_id'].toString()),
      archived: int.parse(json['doctor_archived'].toString()) == 1
          ? true
          : false,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert doctor data into json format for sending
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.toString(),
      'name': name,
      'status': status,
      'qualifications': qualifications,
      'specialization': specialization,
      'image': image,
      'specialityId': specialityId.toString(),
      'archived': archived == true ? '1' : '0',
    };
  }
}
