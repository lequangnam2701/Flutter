class Place {
  final int id;
  final String name;
  final String description;
  final String imageUrl;
  final String location;
  final double rating;
  final bool isPopular;

  Place({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.location,
    required this.rating,
    required this.isPopular,
  });

  factory Place.fromJson(Map<String, dynamic> json) {
    return Place(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      location: json['location'],
      rating: json['rating']?.toDouble() ?? 0.0,
      isPopular: json['isPopular'] ?? false,
    );
  }
}