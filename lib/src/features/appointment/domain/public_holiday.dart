class PublicHoliday {
  final int id;
  final String name;
  final DateTime date;
  final DateTime updatedAt;

  PublicHoliday({
    required this.id,
    required this.name,
    required this.date,
    required this.updatedAt,
  });

  factory PublicHoliday.fromJson(Map<String, dynamic> json) {
    return PublicHoliday(
      id: int.parse(json['holiday_id'].toString()),
      name: json['holiday_name'] as String,
      date: DateTime.parse(json['holiday_date']),
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id.toString(),
        'name': name,
        'date': date.toIso8601String(),
      };
}