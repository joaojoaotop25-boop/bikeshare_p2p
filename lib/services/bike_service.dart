import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/bike_listing.dart';
import '../models/category.dart';

class BikeService {
  final SupabaseClient _client = SupabaseService.instance.client;

  Future<List<BikeListing>> getNearbyBikes({
    double? latitude,
    double? longitude,
    double radiusKm = 10.0,
    int limit = 20,
  }) async {
    try {
      var query = _client
          .from('bike_listings')
          .select('''
            *,
            categories(id, name, icon_url),
            user_profiles!host_id(id, full_name, profile_image_url, rating, total_reviews),
            bike_images(id, image_url, is_primary, display_order)
          ''')
          .eq('status', 'approved')
          .eq('is_available', true)
          .order('created_at');

      if (latitude != null && longitude != null) {
        // For simplicity, we'll order by created_at
        // In production, you'd use PostGIS for proper distance calculations
        query = query.limit(limit);
      } else {
        query = query.limit(limit);
      }

      final response = await query;
      return response
          .map<BikeListing>((json) => BikeListing.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch nearby bikes: $error');
    }
  }

  Future<List<BikeListing>> searchBikes({
    String? query,
    String? categoryId,
    double? minPrice,
    double? maxPrice,
    String? bikeType,
    int limit = 20,
  }) async {
    try {
      var supabaseQuery = _client.from('bike_listings').select('''
            *,
            categories(id, name, icon_url),
            user_profiles!host_id(id, full_name, profile_image_url, rating, total_reviews),
            bike_images(id, image_url, is_primary, display_order)
          ''').eq('status', 'approved').eq('is_available', true);

      if (query != null && query.isNotEmpty) {
        supabaseQuery = supabaseQuery.or(
            'title.ilike.%$query%,description.ilike.%$query%,city.ilike.%$query%');
      }

      if (categoryId != null) {
        supabaseQuery = supabaseQuery.eq('category_id', categoryId);
      }

      if (minPrice != null) {
        supabaseQuery = supabaseQuery.gte('price_per_hour', minPrice);
      }

      if (maxPrice != null) {
        supabaseQuery = supabaseQuery.lte('price_per_hour', maxPrice);
      }

      if (bikeType != null) {
        supabaseQuery = supabaseQuery.eq('bike_type', bikeType);
      }

      final response = await supabaseQuery.order('created_at').limit(limit);
      return response
          .map<BikeListing>((json) => BikeListing.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to search bikes: $error');
    }
  }

  Future<List<Category>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .eq('is_active', true)
          .order('name');

      return response.map<Category>((json) => Category.fromJson(json)).toList();
    } catch (error) {
      throw Exception('Failed to fetch categories: $error');
    }
  }

  Future<BikeListing> getBikeDetails(String bikeId) async {
    try {
      final response = await _client.from('bike_listings').select('''
            *,
            categories(id, name, icon_url, description),
            user_profiles!host_id(id, full_name, profile_image_url, rating, total_reviews, phone, is_verified),
            bike_images(id, image_url, is_primary, display_order)
          ''').eq('id', bikeId).single();

      return BikeListing.fromJson(response);
    } catch (error) {
      throw Exception('Failed to fetch bike details: $error');
    }
  }

  Future<BikeListing> createBikeListing(BikeListing bikeListing) async {
    try {
      final response = await _client
          .from('bike_listings')
          .insert(bikeListing.toJson())
          .select()
          .single();

      return BikeListing.fromJson(response);
    } catch (error) {
      throw Exception('Failed to create bike listing: $error');
    }
  }

  Future<void> updateBikeListing(
      String bikeId, Map<String, dynamic> updates) async {
    try {
      await _client.from('bike_listings').update(updates).eq('id', bikeId);
    } catch (error) {
      throw Exception('Failed to update bike listing: $error');
    }
  }

  Future<String> uploadBikeImage(String bikeId, File imageFile) async {
    try {
      final fileName = '${bikeId}/${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage.from('bike-images').upload(fileName, imageFile);

      final imageUrl =
          _client.storage.from('bike-images').getPublicUrl(fileName);

      return imageUrl;
    } catch (error) {
      throw Exception('Failed to upload bike image: $error');
    }
  }

  Future<void> addBikeImage(String bikeId, String imageUrl,
      {bool isPrimary = false}) async {
    try {
      await _client.from('bike_images').insert({
        'bike_id': bikeId,
        'image_url': imageUrl,
        'is_primary': isPrimary,
      });
    } catch (error) {
      throw Exception('Failed to add bike image: $error');
    }
  }

  Future<List<BikeListing>> getMyListings() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      final response = await _client.from('bike_listings').select('''
            *,
            categories(id, name, icon_url),
            bike_images(id, image_url, is_primary, display_order)
          ''').eq('host_id', user.id).order('created_at');

      return response
          .map<BikeListing>((json) => BikeListing.fromJson(json))
          .toList();
    } catch (error) {
      throw Exception('Failed to fetch my listings: $error');
    }
  }
}
