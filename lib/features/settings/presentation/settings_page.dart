import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/theme_mode_provider.dart';
import '../../profile/presentation/profile_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final user = Supabase.instance.client.auth.currentUser;
    final metadata = user?.userMetadata ?? {};

    final firstName = (metadata['first_name'] ?? '') as String;
    final lastName = (metadata['last_name'] ?? '') as String;
    final gender = (metadata['gender'] ?? '') as String;

    final rawDob = metadata['date_of_birth'];
    String? formattedDob;
    if (rawDob is String && rawDob.isNotEmpty) {
      try {
        final parsed = DateTime.parse(rawDob);
        formattedDob =
            '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
      } catch (_) {
        formattedDob = rawDob;
      }
    }

    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [


          // ================================
          // SECTION INFO COMPTE
          // ================================
          if (user != null)
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              elevation: 0.3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informations du compte",
                      style: theme.textTheme.titleMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ces informations sont uniquement consultables.",
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _infoTile(
                      "Nom complet",
                      ('$firstName $lastName').trim().isEmpty
                          ? 'Non renseigné'
                          : '$firstName $lastName',
                      Icons.person_outline,
                    ),
                    _infoTile(
                      "Email",
                      user.email ?? 'Non renseigné',
                      Icons.email_outlined,
                    ),
                    _infoTile(
                      "Sexe",
                      gender.isEmpty
                          ? "Non renseigné"
                          : (gender == 'M'
                              ? 'Homme'
                              : gender == 'F'
                                  ? 'Femme'
                                  : gender),
                      Icons.wc_outlined,
                    ),
                    _infoTile(
                      "Date de naissance",
                      formattedDob ?? "Non renseignée",
                      Icons.cake_outlined,
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 24),

          // ================================
          // SECTION THÈME
          // ================================
          Card(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0.3,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Thème",
                    style: theme.textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.system,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setSystem(),
                    title: const Text("Système"),
                    secondary: const Icon(Icons.auto_mode_rounded),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.light,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setLight(),
                    title: const Text("Clair"),
                    secondary: const Icon(Icons.light_mode),
                  ),
                  RadioListTile<ThemeMode>(
                    value: ThemeMode.dark,
                    groupValue: themeMode,
                    onChanged: (mode) =>
                        ref.read(themeModeProvider.notifier).setDark(),
                    title: const Text("Sombre"),
                    secondary: const Icon(Icons.dark_mode),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // ================================
          // DÉCONNEXION
          // ================================
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: const Text(
              "Se déconnecter",
              style: TextStyle(color: Colors.redAccent),
            ),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (!context.mounted) return;
              
              // Invalider le cache du profil
              ref.invalidate(currentUserProfileProvider);
              
              context.goNamed('welcome');
            },
          ),
        ],
      ),
    );
  }

  Widget _infoTile(String title, String subtitle, IconData icon) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon),
      title: Text(title),
      subtitle: Text(subtitle),
    );
  }
}
