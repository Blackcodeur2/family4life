import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'connectivity_provider.dart';
import 'no_internet_screen.dart';

/// Widget qui enveloppe l'application et affiche un écran offline quand nécessaire
class ConnectivityWrapper extends ConsumerWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(isOnlineProvider);

    // Si pas de connexion, afficher l'écran offline
    if (!isOnline) {
      return const NoInternetScreen();
    }

    // Sinon, afficher le contenu normal
    return child;
  }
}
