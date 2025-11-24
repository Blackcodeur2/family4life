import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:family4life/core/widgets/primary_app_bar.dart';
import 'package:go_router/go_router.dart';

import '../../birthdays/presentation/birthday_list_page.dart';
import '../../contributions/presentation/contribution_page.dart';
import '../../points/presentation/points_page.dart';
import '../../settings/presentation/settings_page.dart';

import '../../profile/presentation/profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  int _currentIndex = 0;

  static const _titles = [
    'Anniversaires',
    'Contribuer',
    'Mes points',
    'Paramètres',
  ];

  static const _navItems = [
    BottomNavigationBarItem(
      icon: Icon(Icons.cake_outlined),
      label: 'Anniv',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.volunteer_activism),
      label: 'Contrib',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.star_outline),
      label: 'Points',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.settings_outlined),
      label: 'Paramètres',
    ),
  ];

  final _pages = const [
    BirthdayListPage(),
    ContributionPage(),
    PointsPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Sécurise l'index pour éviter les erreurs quand la structure change (hot reload, etc.)
    final safeIndex = _currentIndex.clamp(0, _pages.length - 1).toInt();

    return Scaffold(
      appBar: PrimaryAppBar(
        title: _titles[safeIndex],
        actions: [
          IconButton(
            onPressed: () {
              context.push('/notifications');
            },
            icon: const Icon(Icons.notifications_outlined),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16, left: 8),
            child: GestureDetector(
              onTap: () {
                context.push('/profile');
              },
              child: Consumer(
                builder: (context, ref, child) {
                  final profileAsync = ref.watch(currentUserProfileProvider);
                  return profileAsync.when(
                    data: (profile) {
                      return CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                        backgroundImage: profile?.avatarUrl != null
                            ? NetworkImage(profile!.avatarUrl!)
                            : null,
                        child: profile?.avatarUrl == null
                            ? Text(
                                (profile?.firstName?.substring(0, 1) ??
                                        profile?.email?.substring(0, 1) ??
                                        'U')
                                    .toUpperCase(),
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              )
                            : null,
                      );
                    },
                    loading: () => CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: const SizedBox(
                        width: 12,
                        height: 12,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                    error: (_, __) => CircleAvatar(
                      radius: 16,
                      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        'U',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: safeIndex,
        children: _pages,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(24),
            ),
            child: BottomNavigationBar(
              currentIndex: safeIndex,
              type: BottomNavigationBarType.fixed,
              items: _navItems,
              elevation: 0,
              backgroundColor: Colors.transparent,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
