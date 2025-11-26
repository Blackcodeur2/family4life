import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider qui surveille l'état de la connexion Internet
final connectivityStreamProvider = StreamProvider<List<ConnectivityResult>>((
  ref,
) {
  return Connectivity().onConnectivityChanged;
});

/// Provider qui indique si l'utilisateur est en ligne
final isOnlineProvider = Provider<bool>((ref) {
  final connectivityAsync = ref.watch(connectivityStreamProvider);

  return connectivityAsync.when(
    data: (results) {
      // Pas de connexion si la liste est vide ou contient uniquement "none"
      if (results.isEmpty) return false;
      if (results.length == 1 && results.first == ConnectivityResult.none) {
        return false;
      }
      return true;
    },
    loading: () => true, // Considérer comme en ligne pendant le chargement
    error: (_, __) => true, // Considérer comme en ligne en cas d'erreur
  );
});
