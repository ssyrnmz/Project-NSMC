class Speciality {
  //▫️Variables
  final int id;
  final String name;
  //final bool archived
  final DateTime updatedAt;

  //▫️Constructor
  Speciality({required this.id, required this.name, required this.updatedAt});

  //▫️Converter functions
  // Convert json data into speciality class when retrieved
  factory Speciality.fromJson(Map<String, dynamic> json) {
    return Speciality(
      id: int.parse(json['speciality_id'].toString()),
      name: json['speciality_name'] as String,
      /*
      archived: int.parse(json['speciality_archived'].toString()) == 1
          ? true
          : false,
      */
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert speciality data into json format for sending
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.toString(),
      'name': name,
      //'archived': archived == true ? '1' : '0'
    };
  }
}
