class BikeImage {
  final String id;
  final String bikeId;
  final String imageUrl;
  final bool isPrimary;
  final int displayOrder;
  final DateTime createdAt;

  BikeImage({
    required this.id,
    required this.bikeId,
    required this.imageUrl,
    required this.isPrimary,
    required this.displayOrder,
    required this.createdAt,
  });

  factory BikeImage.fromJson(Map<String, dynamic> json) {
    return BikeImage(
      id: json['id'] ?? '',
      bikeId: json['bike_id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isPrimary: json['is_primary'] ?? false,
      displayOrder: json['display_order'] ?? 0,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bike_id': bikeId,
      'image_url': imageUrl,
      'is_primary': isPrimary,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
