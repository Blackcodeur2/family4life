import 'package:confetti/confetti.dart';
import 'package:family4life/features/auth/domain/models/user_profile.dart';
import 'package:family4life/features/contributions/data/repositories/contribution_repository.dart';
import 'package:family4life/features/contributions/domain/models/contribution.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../auth/data/repositories/profile_repository.dart';
import '../../profile/presentation/profile_page.dart';
import 'providers/birthday_provider.dart';

class BirthdayListPage extends ConsumerStatefulWidget {
  const BirthdayListPage({super.key});

  @override
  ConsumerState<BirthdayListPage> createState() => _BirthdayListPageState();
}

class _BirthdayListPageState extends ConsumerState<BirthdayListPage> {
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 30),
    );
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _checkBirthdays(List<BirthdayUser> users) {
    final todayBirthdays = users.where((u) => u.daysRemaining == 0).toList();
    if (todayBirthdays.isNotEmpty) {
      _confettiController.play();
    }
  }

  Future<void> _contribute(UserProfile beneficiary) async {
    final currentUser = await ref.read(currentUserProfileProvider.future);
    if (currentUser == null) return;

    // Simuler le paiement et l'ajout de contribution
    try {
      final contribution = Contribution(
        id: const Uuid().v4(),
        userId: currentUser.id,
        beneficiaryId: beneficiary.id,
        amount: 5000, // Montant par défaut ou à choisir
        createdAt: DateTime.now(),
      );

      await ref
          .read(contributionRepositoryProvider)
          .addContribution(contribution);

      // Ajouter 20 points
      final newPoints = currentUser.pointsBalance + 20;
      await ref
          .read(profileRepositoryProvider)
          .updatePoints(currentUser.id, newPoints);

      // Rafraîchir le profil pour voir les nouveaux points
      ref.invalidate(currentUserProfileProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Contribution réussie ! +20 points')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erreur: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final birthdayListAsync = ref.watch(birthdayListProvider);

    // Vérifier les anniversaires quand les données changent
    ref.listen(birthdayListProvider, (previous, next) {
      next.whenData(_checkBirthdays);
    });

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Summary Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary,
                              theme.colorScheme.tertiary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: theme.colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Ce mois',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: theme.colorScheme.onPrimary
                                        .withOpacity(0.9),
                                  ),
                                ),
                                Icon(
                                  Icons.calendar_month,
                                  color: theme.colorScheme.onPrimary,
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            birthdayListAsync.when(
                              data: (users) {
                                final count = users
                                    .where((u) => u.daysRemaining < 30)
                                    .length;
                                return Text(
                                  '$count Anniversaires',
                                  style: theme.textTheme.headlineMedium
                                      ?.copyWith(
                                        color: theme.colorScheme.onPrimary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                );
                              },
                              loading: () => const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              ),
                              error: (_, __) => const Text(
                                '...',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Préparez vos contributions !',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onPrimary.withOpacity(
                                  0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Section Anniversaires du jour
                      birthdayListAsync.when(
                        data: (users) {
                          final todayBirthdays = users
                              .where((u) => u.daysRemaining == 0)
                              .toList();
                          if (todayBirthdays.isEmpty)
                            return const SizedBox.shrink();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 24),
                              Text(
                                "🎉 C'est leur anniversaire !",
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                height: 180,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount: todayBirthdays.length,
                                  itemBuilder: (context, index) {
                                    final user = todayBirthdays[index].user;
                                    return Container(
                                      width: 140,
                                      margin: const EdgeInsets.only(right: 16),
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme
                                            .primaryContainer
                                            .withOpacity(0.3),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(
                                          color: theme.colorScheme.primary,
                                          width: 2,
                                        ),
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          CircleAvatar(
                                            radius: 30,
                                            backgroundImage:
                                                user.avatarUrl != null
                                                ? NetworkImage(user.avatarUrl!)
                                                : null,
                                            child: user.avatarUrl == null
                                                ? Text(
                                                    user.firstName?[0]
                                                            .toUpperCase() ??
                                                        '?',
                                                  )
                                                : null,
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            user.firstName ?? 'Inconnu',
                                            style: theme.textTheme.titleSmall
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 8),
                                          ElevatedButton(
                                            onPressed: () => _contribute(user),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  theme.colorScheme.primary,
                                              foregroundColor:
                                                  theme.colorScheme.onPrimary,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                  ),
                                              minimumSize: const Size(0, 32),
                                            ),
                                            child: const Text(
                                              'Contribuer',
                                              style: TextStyle(fontSize: 12),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      ),

                      const SizedBox(height: 24),
                      // Filters
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            FilterChip(
                              label: const Text('Tous'),
                              selected: true,
                              onSelected: (bool value) {},
                              backgroundColor: theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.5),
                              selectedColor: theme.colorScheme.primaryContainer,
                              labelStyle: TextStyle(
                                color: theme.colorScheme.onPrimaryContainer,
                                fontWeight: FontWeight.bold,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Ce mois'),
                              selected: false,
                              onSelected: (bool value) {},
                              backgroundColor: theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide.none,
                            ),
                            const SizedBox(width: 8),
                            FilterChip(
                              label: const Text('Prochainement'),
                              selected: false,
                              onSelected: (bool value) {},
                              backgroundColor: theme
                                  .colorScheme
                                  .surfaceContainerHighest
                                  .withOpacity(0.5),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              side: BorderSide.none,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              birthdayListAsync.when(
                data: (users) {
                  if (users.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: Text("Aucun anniversaire trouvé.")),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final item = users[index];
                        final user = item.user;
                        final days = item.daysRemaining;

                        // Format date: "12 Octobre"
                        final dateStr = user.birthDate != null
                            ? DateFormat(
                                'd MMMM',
                                'fr_FR',
                              ).format(user.birthDate!)
                            : 'Inconnue';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          color: theme.colorScheme.surface,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                            side: BorderSide(
                              color: theme.colorScheme.outlineVariant
                                  .withOpacity(0.5),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  child:
                                      user.avatarUrl != null &&
                                          user.avatarUrl!.isNotEmpty
                                      ? ClipOval(
                                          child: Image.network(
                                            user.avatarUrl!,
                                            width: 56,
                                            height: 56,
                                            fit: BoxFit.cover,
                                            loadingBuilder: (context, child, loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  value:
                                                      loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                                .cumulativeBytesLoaded /
                                                            loadingProgress
                                                                .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                                  // Afficher les initiales si l'image ne charge pas
                                                  return Center(
                                                    child: Text(
                                                      (user.firstName
                                                                  ?.substring(
                                                                    0,
                                                                    1,
                                                                  ) ??
                                                              user.email
                                                                  ?.substring(
                                                                    0,
                                                                    1,
                                                                  ) ??
                                                              '?')
                                                          .toUpperCase(),
                                                      style: TextStyle(
                                                        color: theme
                                                            .colorScheme
                                                            .onPrimaryContainer,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 20,
                                                      ),
                                                    ),
                                                  );
                                                },
                                          ),
                                        )
                                      : Text(
                                          (user.firstName?.substring(0, 1) ??
                                                  user.email?.substring(0, 1) ??
                                                  '?')
                                              .toUpperCase(),
                                          style: TextStyle(
                                            color: theme
                                                .colorScheme
                                                .onPrimaryContainer,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20,
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.fullName ??
                                            user.email ??
                                            'Utilisateur',
                                        style: theme.textTheme.titleMedium
                                            ?.copyWith(
                                              fontWeight: FontWeight.bold,
                                            ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.cake_outlined,
                                            size: 14,
                                            color: theme.colorScheme.primary,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            dateStr,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: theme
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (days !=
                                        -1) // Afficher le badge seulement si date existe
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: days == 0
                                              ? theme.colorScheme.errorContainer
                                              : theme
                                                    .colorScheme
                                                    .primaryContainer,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          days == 0
                                              ? "Aujourd'hui !"
                                              : "J-$days",
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: days == 0
                                                    ? theme
                                                          .colorScheme
                                                          .onErrorContainer
                                                    : theme
                                                          .colorScheme
                                                          .onPrimaryContainer,
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                      )
                                    else // Afficher un message pour les dates non renseignées
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 10,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: theme
                                              .colorScheme
                                              .surfaceContainerHighest,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Text(
                                          "Date non renseignée",
                                          style: theme.textTheme.labelSmall
                                              ?.copyWith(
                                                color: theme
                                                    .colorScheme
                                                    .onSurfaceVariant,
                                                fontStyle: FontStyle.italic,
                                              ),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }, childCount: users.length),
                    ),
                  );
                },
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Erreur: $err')),
                ),
              ),
              const SliverPadding(padding: EdgeInsets.only(bottom: 80)),
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
    );
  }
}
