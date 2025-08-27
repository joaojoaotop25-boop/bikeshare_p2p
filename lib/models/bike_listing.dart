import './bike_image.dart';
import './category.dart';
import './user_profile.dart';

class BikeListing {
  final String id;
  final String hostId;
  final String title;
  final String? description;
  final String? categoryId;
  final String bikeType;
  final double pricePerHour;
  final double? pricePerDay;
  final double latitude;
  final double longitude;
  final String address;
  final String city;
  final String country;
  final String status;
  final String bikeStatus;
  final bool isAvailable;
  final int minimumRentalHours;
  final int maximumRentalHours;
  final List<String> features;
  final String? rules;
  final DateTime createdAt;
  final DateTime updatedAt;

  // Relationships
  final Category? category;
  final UserProfile? host;
  final List<BikeImage> images;

  BikeListing({
    required this.id,
    required this.hostId,
    required this.title,
    this.description,
    this.categoryId,
    required this.bikeType,
    required this.pricePerHour,
    this.pricePerDay,
    required this.latitude,
    required this.longitude,
    required this.address,
    required this.city,
    required this.country,
    required this.status,
    required this.bikeStatus,
    required this.isAvailable,
    required this.minimumRentalHours,
    required this.maximumRentalHours,
    required this.features,
    this.rules,
    required this.createdAt,
    required this.updatedAt,
    this.category,
    this.host,
    required this.images,
  });

  factory BikeListing.fromJson(Map<String, dynamic> json) {
    return BikeListing(
      id: json['id'] ?? '',
      hostId: json['host_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      categoryId: json['category_id'],
      bikeType: json['bike_type'] ?? '',
      pricePerHour: (json['price_per_hour'] ?? 0).toDouble(),
      pricePerDay: json['price_per_day']?.toDouble(),
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
      status: json['status'] ?? 'pending',
      bikeStatus: json['bike_status'] ?? 'available',
      isAvailable: json['is_available'] ?? true,
      minimumRentalHours: json['minimum_rental_hours'] ?? 1,
      maximumRentalHours: json['maximum_rental_hours'] ?? 24,
      features:
          json['features'] != null ? List<String>.from(json['features']) : [],
      rules: json['rules'],
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
      category: json['categories'] != null
          ? Category.fromJson(json['categories'])
          : null,
      host: json['user_profiles'] != null
          ? UserProfile.fromJson(json['user_profiles'])
          : null,
      images: json['bike_images'] != null
          ? (json['bike_images'] as List)
              .map((image) => BikeImage.fromJson(image))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'host_id': hostId,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'bike_type': bikeType,
      'price_per_hour': pricePerHour,
      'price_per_day': pricePerDay,
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      'city': city,
      'country': country,
      'status': status,
      'bike_status': bikeStatus,
      'is_available': isAvailable,
      'minimum_rental_hours': minimumRentalHours,
      'maximum_rental_hours': maximumRentalHours,
      'features': features,
      'rules': rules,
    };
  }

  String get primaryImageUrl {
    final primaryImage = images.where((img) => img.isPrimary).firstOrNull;
    return primaryImage?.imageUrl ??
        images.firstOrNull?.imageUrl ??
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=400&h=300';
  }

  double get rating {
    return host?.rating ?? 0.0;
  }

  int get reviewCount {
    return host?.totalReviews ?? 0;
  }
}

extension ListExtension<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
