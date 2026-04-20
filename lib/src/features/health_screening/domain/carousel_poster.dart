class CarouselPoster {
  //▫️Variables
  final int id;
  final String image;
  final int placement;
  final bool archived;
  final DateTime updatedAt;

  //▫️Constructor
  CarouselPoster({
    required this.id,
    required this.image,
    required this.placement,
    required this.archived,
    required this.updatedAt,
  });

  //▫️Converter functions
  // Convert json data into carousel class when retrieved
  factory CarouselPoster.fromJson(Map<String, dynamic> json) {
    return CarouselPoster(
      id: int.parse(json['poster_id'].toString()),
      image: json['poster_image_path'] as String,
      placement: int.parse(json['poster_placement'].toString()),
      archived: int.parse(json['poster_archived'].toString()) == 1
          ? true
          : false,
      updatedAt: DateTime.parse(json['updated_at']).toUtc(),
    );
  }

  // Convert carousel data into json format for sending
  Map<String, dynamic> toJson() {
    return {
      'id': id.toString(),
      'image': image,
      'placement': placement.toString(),
      'archived': archived == true ? '1' : '0',
    };
  }
}
