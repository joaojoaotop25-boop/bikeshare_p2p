class Category {
  final String id;
  final String name;
  final String? iconUrl;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  Category({
    required this.id,
    required this.name,
    this.iconUrl,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      iconUrl: json['icon_url'],
      description: json['description'],
      isActive: json['is_active'] ?? true,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon_url': iconUrl,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
