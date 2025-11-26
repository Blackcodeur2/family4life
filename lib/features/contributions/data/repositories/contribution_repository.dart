import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/contribution.dart';

final contributionRepositoryProvider = Provider<ContributionRepository>((ref) {
  return ContributionRepository(Supabase.instance.client);
});

class ContributionRepository {
  final SupabaseClient _supabase;

  ContributionRepository(this._supabase);

  Future<void> addContribution(Contribution contribution) async {
    try {
      await _supabase.from('contributions').insert(contribution.toJson());
    } catch (e) {
      throw Exception('Erreur lors de l\'ajout de la contribution: $e');
    }
  }

  Future<List<Contribution>> getContributionsForUser(String userId) async {
    try {
      final response = await _supabase
          .from('contributions')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);

      return (response as List)
          .map((e) => Contribution.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw Exception('Erreur lors de la récupération des contributions: $e');
    }
  }
}
