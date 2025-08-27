class UserProfile {
  final String id;
  final String email;
  final String fullName;
  final String? phone;
  final String role;
  final String? profileImageUrl;
  final double rating;
  final int totalReviews;
  final bool isHost;
  final bool isVerified;
  final DateTime createdAt;
  final DateTime updatedAt;

  UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    this.phone,
    required this.role,
    this.profileImageUrl,
    required this.rating,
    required this.totalReviews,
    required this.isHost,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
      phone: json['phone'],
      role: json['role'] ?? 'rider',
      profileImageUrl: json['profile_image_url'],
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['total_reviews'] ?? 0,
      isHost: json['is_host'] ?? false,
      isVerified: json['is_verified'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone': phone,
      'role': role,
      'profile_image_url': profileImageUrl,
      'rating': rating,
      'total_reviews': totalReviews,
      'is_host': isHost,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get displayImageUrl {
    return profileImageUrl ??
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150&h=150&fit=crop&crop=face';
  }
}
