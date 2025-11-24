import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'providers/birthday_provider.dart';

class BirthdayListPage extends ConsumerWidget {
  const BirthdayListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final birthdayListAsync = ref.watch(birthdayListProvider);

    return Scaffold(
      body: CustomScrollView(
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
                        colors: [theme.colorScheme.primary, theme.colorScheme.tertiary],
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
                                color: theme.colorScheme.onPrimary.withOpacity(0.9),
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
                            final count = users.where((u) => u.daysRemaining < 30).length;
                            return Text(
                              '$count Anniversaires',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          },
                          loading: () => const SizedBox(
                            height: 20, 
                            width: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                          ),
                          error: (_, __) => Text('...', style: TextStyle(color: Colors.white)),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Préparez vos contributions !',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onPrimary.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
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
                          backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          selectedColor: theme.colorScheme.primaryContainer,
                          labelStyle: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.bold,
                          ),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Ce mois'),
                          selected: false,
                          onSelected: (bool value) {},
                          backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          side: BorderSide.none,
                        ),
                        const SizedBox(width: 8),
                        FilterChip(
                          label: const Text('Prochainement'),
                          selected: false,
                          onSelected: (bool value) {},
                          backgroundColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = users[index];
                      final user = item.user;
                      final days = item.daysRemaining;
                      
                      // Format date: "12 Octobre"
                      final dateStr = user.birthDate != null 
                          ? DateFormat('d MMMM', 'fr_FR').format(user.birthDate!) 
                          : 'Inconnue';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        color: theme.colorScheme.surface,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(
                            color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 28,
                                backgroundColor: theme.colorScheme.primaryContainer,
                                child: user.avatarUrl != null && user.avatarUrl!.isNotEmpty
                                    ? ClipOval(
                                        child: Image.network(
                                          user.avatarUrl!,
                                          width: 56,
                                          height: 56,
                                          fit: BoxFit.cover,
                                          loadingBuilder: (context, child, loadingProgress) {
                                            if (loadingProgress == null) return child;
                                            return Center(
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                value: loadingProgress.expectedTotalBytes != null
                                                    ? loadingProgress.cumulativeBytesLoaded /
                                                        loadingProgress.expectedTotalBytes!
                                                    : null,
                                              ),
                                            );
                                          },
                                          errorBuilder: (context, error, stackTrace) {
                                            // Afficher les initiales si l'image ne charge pas
                                            return Center(
                                              child: Text(
                                                (user.firstName?.substring(0, 1) ?? 
                                                    user.email?.substring(0, 1) ?? '?').toUpperCase(),
                                                style: TextStyle(
                                                  color: theme.colorScheme.onPrimaryContainer,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      )
                                    : Text(
                                        (user.firstName?.substring(0, 1) ?? 
                                            user.email?.substring(0, 1) ?? '?').toUpperCase(),
                                        style: TextStyle(
                                          color: theme.colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user.fullName ?? user.email ?? 'Utilisateur',
                                      style: theme.textTheme.titleMedium?.copyWith(
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
                                          style: theme.textTheme.bodyMedium?.copyWith(
                                            color: theme.colorScheme.onSurfaceVariant,
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
                                  if (days != -1) // Afficher le badge seulement si date existe
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: days == 0 
                                            ? theme.colorScheme.errorContainer 
                                            : theme.colorScheme.primaryContainer,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        days == 0 ? "Aujourd'hui !" : "J-$days",
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: days == 0 
                                              ? theme.colorScheme.onErrorContainer 
                                              : theme.colorScheme.onPrimaryContainer,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else // Afficher un message pour les dates non renseignées
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        "Date non renseignée",
                                        style: theme.textTheme.labelSmall?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
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
                    },
                    childCount: users.length,
                  ),
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
    );
  }
}
