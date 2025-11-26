import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/user_profile.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(Supabase.instance.client);
});

class ProfileRepository {
  final SupabaseClient _supabase;

  ProfileRepository(this._supabase);

  Future<List<UserProfile>> getAllProfiles() async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .order('full_name', ascending: true);

      return (response as List)
          .map((e) => UserProfile.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // En cas d'erreur (ex: table vide ou pas de connexion), on relance ou on retourne une liste vide
      throw Exception('Erreur lors de la récupération des profils: $e');
    }
  }

  Future<void> updatePoints(String userId, int newPoints) async {
    try {
      await _supabase
          .from('profiles')
          .update({'points_balance': newPoints})
          .eq('id', userId);
    } catch (e) {
      throw Exception('Erreur lors de la mise à jour des points: $e');
    }
  }
}
