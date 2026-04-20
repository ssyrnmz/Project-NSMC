class MedicalRecord {
  //▫️Variables
  final int id;
  final String name;
  final DateTime date;
  final String file;
  final String userId;
  final bool archived;
  final bool verified;  // true = ITD approved
  final bool rejected;  // true = ITD rejected
  final DateTime updatedAt;

  //▫️Constructor
  MedicalRecord({
    required this.id,
    required this.name,
    required this.date,
    required this.file,
    required this.userId,
    required this.archived,
    required this.updatedAt,
    this.verified = false,
    this.rejected = false,
  });

  //▫️Converter Functions
  factory MedicalRecord.fromJson(Map<String, dynamic> json) {
    return MedicalRecord(
      id: int.parse(json['record_id'].toString()),
      name: json['record_name'] as String,
      date: DateTime.parse(json['record_date']),
      file: json['record_file'] as String,
      userId: json['user_id'] as String,
      archived: int.parse(json['record_archived'].toString()) == 1,
      verified: int.parse(
            (json['record_verified'] ?? '0').toString(),
          ) == 1,
      rejected: int.parse(
            (json['record_rejected'] ?? '0').toString(),
          ) == 1,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.toString(),
      'name': name,
      'date': date.toIso8601String(),
      'file': file,
      'userId': userId,
      'archived': archived == true ? '1' : '0',
    };
  }
}