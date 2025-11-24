import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';

// TODO: remplace ces constantes par tes vraies valeurs Supabase
const String supabaseUrl = 'https://uhhhfqpceamkufuzpdwj.supabase.co';
const String supabaseAnonKey = 'sb_publishable_hsR88cgeBUpBv76NkcE9KQ_xeSYeGVR';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  await initializeDateFormatting('fr_FR', null);

  runApp(const ProviderScope(child: Family4LifeApp()));
}

class Family4LifeApp extends ConsumerWidget {
  const Family4LifeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router
      // Material 3 + light/dark
      (
      title: 'Family4Life',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routerConfig: router,
    );
  }
}
