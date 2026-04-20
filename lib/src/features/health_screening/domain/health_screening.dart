import 'dart:convert';

class HealthScreening {
  //▫️Variables
  final int id;
  final String name;
  final double price;
  final String description;
  final List<String> included;
  final String image;
  final String? category; // e.g. "General", "Special Programme", "Specialized"
  final bool archived;
  final DateTime updatedAt;

  //▫️Constructor
  HealthScreening({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.included,
    required this.image,
    this.category,
    required this.archived,
    required this.updatedAt,
  });

  //▫️Converter functions
  // Convert json data into health screening class when retrieved
  factory HealthScreening.fromJson(Map<String, dynamic> json) {
    return HealthScreening(
      id: int.parse(json['package_id'].toString()),
      name: json['package_name'] as String,
      price: double.parse(json['package_price'].toString()) / 100,
      description: json['package_description'] as String,
      included: (json['package_included'] != null)
          ? List<String>.from(jsonDecode(json['package_included']))
          : [],
      image: json['package_image'] as String,
      category: json['package_category'] as String?,
      archived: int.parse(json['package_archived'].toString()) == 1
          ? true
          : false,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert health screening data into json format for sending
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price.toString(),
      'description': description,
      'included': jsonEncode(included),
      'image': image,
      'category': category,
      'archived': archived == true ? '1' : '0',
    };
  }
}