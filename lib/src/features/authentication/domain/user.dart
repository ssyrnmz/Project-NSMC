class User {
  //▫️Variables
  final String id;
  final String fullName;
  final String email;
  final String icNumber;
  final String phoneNumber;
  final String nationality;
  final String gender;
  final DateTime birthDate;
  final int age;
  final String? occupation;
  final String? race;
  final String? religion;
  final String? homeAddress;
  final String? postCode;
  final String? city;
  final String? state;
  final String? country;
  final DateTime createdAt;
  final String signupMethod;
  final bool unactive;
  final DateTime updatedAt;

  //▫️Constructor
  User({
    required this.id,
    required this.fullName,
    required this.email,
    required this.icNumber,
    required this.phoneNumber,
    required this.nationality,
    required this.gender,
    required this.birthDate,
    required this.age,
    required this.occupation,
    required this.race,
    required this.religion,
    required this.homeAddress,
    required this.postCode,
    required this.city,
    required this.state,
    required this.country,
    required this.createdAt,
    required this.signupMethod,
    required this.unactive,
    required this.updatedAt,
  });

  //▫️Converter functions
  // Convert json data into user class when retrieved
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'] as String,
      fullName: json['user_fullname'] as String,
      email: json['user_email'] as String,
      icNumber: json['user_ic_number'] as String,
      phoneNumber: json['user_phone_number'] as String,
      nationality: json['user_nationality'] as String,
      gender: json['user_gender'] as String,
      birthDate: DateTime.parse(json['user_birth_date']),
      age: int.parse(json['user_age'].toString()),
      occupation: json['user_occupation'] as String?,
      race: json['user_race'] as String?,
      religion: json['user_religion'] as String?,
      homeAddress: json['user_home_address'] as String?,
      postCode: json['user_postal_code'] as String?,
      city: json['user_city'] as String?,
      state: json['user_state'] as String?,
      country: json['user_country'] as String?,
      createdAt: DateTime.parse(json['user_created_at']),
      signupMethod: json['user_signup_method'] as String,
      unactive: int.parse(json['user_unactive'].toString()) == 1 ? true : false,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert user data into json format for sending
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id.toString(),
      'fullName': fullName,
      'email': email,
      'icNumber': icNumber,
      'phoneNumber': phoneNumber,
      'nationality': nationality,
      'gender': gender,
      'birthDate': birthDate.toIso8601String(),
      'age': age,
      'race': race,
      'religion': religion,
      'occupation': occupation,
      'homeAddress': homeAddress,
      'postCode': postCode,
      'city': city,
      'state': state,
      'country': country,
      'createdAt': createdAt.toIso8601String(),
      'signupMethod': signupMethod,
      'unactive': unactive == true ? '1' : '0',
    };
  }
}
