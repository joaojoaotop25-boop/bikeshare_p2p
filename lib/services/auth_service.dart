import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../models/user_profile.dart';

class AuthService {
  final SupabaseClient _client = SupabaseService.instance.client;

  User? get currentUser => _client.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    String? phone,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone': phone,
          'role': 'rider',
        },
      );
      return response;
    } catch (error) {
      throw Exception('Sign-up failed: $error');
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      throw Exception('Sign-in failed: $error');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (error) {
      throw Exception('Sign-out failed: $error');
    }
  }

  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final user = currentUser;
      if (user == null) return null;

      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', user.id)
          .single();

      return UserProfile.fromJson(response);
    } catch (error) {
      throw Exception('Failed to get user profile: $error');
    }
  }

  Future<void> updateUserProfile(Map<String, dynamic> updates) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      await _client.from('user_profiles').update(updates).eq('id', user.id);
    } catch (error) {
      throw Exception('Failed to update user profile: $error');
    }
  }

  Future<String> uploadProfileImage(File imageFile) async {
    try {
      final user = currentUser;
      if (user == null) throw Exception('User not authenticated');

      final fileName =
          '${user.id}/profile_${DateTime.now().millisecondsSinceEpoch}.jpg';

      await _client.storage.from('profile-images').upload(fileName, imageFile);

      final imageUrl =
          _client.storage.from('profile-images').getPublicUrl(fileName);

      return imageUrl;
    } catch (error) {
      throw Exception('Failed to upload profile image: $error');
    }
  }

  Future<void> enableHostMode() async {
    try {
      await updateUserProfile({
        'is_host': true,
        'role': 'host',
      });
    } catch (error) {
      throw Exception('Failed to enable host mode: $error');
    }
  }
}
