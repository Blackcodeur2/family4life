import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/data/repositories/profile_repository.dart';
import '../../../auth/domain/models/user_profile.dart';

final birthdayListProvider = FutureProvider<List<BirthdayUser>>((ref) async {
  final repository = ref.watch(profileRepositoryProvider);
  final profiles = await repository.getAllProfiles();

  // Mapper TOUS les utilisateurs vers un modèle enrichi avec les jours restants
  final birthdayUsers = profiles.map((user) {
    final daysRemaining = user.birthDate != null 
        ? _calculateDaysRemaining(user.birthDate!) 
        : -1; // -1 indique pas de date de naissance
    return BirthdayUser(user: user, daysRemaining: daysRemaining);
  }).toList();

  // Trier: ceux avec date en premier (par jours restants), puis ceux sans date à la fin
  birthdayUsers.sort((a, b) {
    if (a.daysRemaining == -1 && b.daysRemaining == -1) return 0;
    if (a.daysRemaining == -1) return 1; // a sans date va à la fin
    if (b.daysRemaining == -1) return -1; // b sans date va à la fin
    return a.daysRemaining.compareTo(b.daysRemaining);
  });

  return birthdayUsers;
});

int _calculateDaysRemaining(DateTime birthDate) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  var nextBirthday = DateTime(now.year, birthDate.month, birthDate.day);

  if (nextBirthday.isBefore(today)) {
    nextBirthday = DateTime(now.year + 1, birthDate.month, birthDate.day);
  }

  return nextBirthday.difference(today).inDays;
}

class BirthdayUser {
  final UserProfile user;
  final int daysRemaining;

  BirthdayUser({required this.user, required this.daysRemaining});
}
