class RawgGame {
  final int id;
  final String name;
  final String? backgroundImage;
  final String? description;
  final double? rating;

  const RawgGame({
    required this.id,
    required this.name,
    this.backgroundImage,
    this.description,
    this.rating,
  });

  factory RawgGame.fromJson(Map<String, dynamic> json) => RawgGame(
        id: json['id'] as int,
        name: json['name'] as String,
        backgroundImage: json['background_image'] as String?,
        description: json['description_raw'] as String?,
        rating: (json['rating'] as num?)?.toDouble(),
      );
}
