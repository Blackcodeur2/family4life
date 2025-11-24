import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../auth/domain/models/user_profile.dart';

// Provider pour récupérer le profil de l'utilisateur connecté
final currentUserProfileProvider = FutureProvider<UserProfile?>((ref) async {
  final supabase = Supabase.instance.client;
  final user = supabase.auth.currentUser;
  
  if (user == null) return null;
  
  final response = await supabase
      .from('profiles')
      .select()
      .eq('id', user.id)
      .single();
  
  return UserProfile.fromJson(response as Map<String, dynamic>);
});

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final _imagePicker = ImagePicker();
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );
      
      if (image == null) return;

      // Vérifier le type de fichier via mimeType
      final String? mimeType = image.mimeType;
      final List<String> allowedMimeTypes = ['image/png', 'image/jpg', 'image/jpeg'];
      
      if (mimeType == null || !allowedMimeTypes.contains(mimeType.toLowerCase())) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Format non autorisé. Veuillez sélectionner une image PNG, JPG ou JPEG.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      
      // Vérifier la taille du fichier (5MB = 5 * 1024 * 1024 bytes)
      final Uint8List bytes = await image.readAsBytes();
      final int fileSizeInBytes = bytes.length;
      final double fileSizeInMB = fileSizeInBytes / (1024 * 1024);
      
      if (fileSizeInMB > 5) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image trop volumineuse (${fileSizeInMB.toStringAsFixed(1)} MB). La taille maximale est de 5 MB.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() => _isUploading = true);

      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      final fileExt = image.path.split('.').last;
      final filePath = '$userId/avatar.$fileExt';
      
      // Upload l'image
      await supabase.storage.from('avatars').uploadBinary(
        filePath,
        bytes,
        fileOptions: const FileOptions(
          upsert: true,
          contentType: 'image/jpeg',
        ),
      );
      
      final avatarUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      
      // Mettre à jour le profil
      await supabase.from('profiles').update({
        'avatar_url': avatarUrl,
      }).eq('id', userId);

      if (!mounted) return;
      
      // Rafraîchir le provider
      ref.invalidate(currentUserProfileProvider);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Photo de profil mise à jour !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  Future<void> _logout() async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signOut();
    if (!mounted) return;
    
    // Invalider le cache du profil
    ref.invalidate(currentUserProfileProvider);
    
    context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(currentUserProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon Profil'),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
          ),
        ],
      ),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: Text('Profil introuvable'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Avatar
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: theme.colorScheme.primaryContainer,
                      backgroundImage: profile.avatarUrl != null
                          ? NetworkImage(profile.avatarUrl!)
                          : null,
                      child: profile.avatarUrl == null
                          ? Icon(
                              Icons.person,
                              size: 60,
                              color: theme.colorScheme.onPrimaryContainer,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Material(
                        color: theme.colorScheme.primary,
                        shape: const CircleBorder(),
                        child: InkWell(
                          onTap: _isUploading ? null : _pickAndUploadImage,
                          customBorder: const CircleBorder(),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: _isUploading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  )
                                : Icon(
                                    Icons.camera_alt,
                                    size: 20,
                                    color: theme.colorScheme.onPrimary,
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Nom complet
                Text(
                  profile.fullName ?? profile.email ?? 'Utilisateur',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),

                // Informations
                _buildInfoCard(
                  theme: theme,
                  children: [
                    _buildInfoRow(
                      theme: theme,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: profile.email ?? 'Non renseigné',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      theme: theme,
                      icon: Icons.phone_outlined,
                      label: 'Téléphone',
                      value: profile.phoneNumber ?? 'Non renseigné',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      theme: theme,
                      icon: Icons.cake_outlined,
                      label: 'Date de naissance',
                      value: profile.birthDate != null
                          ? DateFormat('dd/MM/yyyy').format(profile.birthDate!)
                          : 'Non renseignée',
                    ),
                    const Divider(),
                    _buildInfoRow(
                      theme: theme,
                      icon: Icons.wc_outlined,
                      label: 'Sexe',
                      value: profile.gender == 'M'
                          ? 'Homme'
                          : profile.gender == 'F'
                              ? 'Femme'
                              : 'Non renseigné',
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Points
                _buildInfoCard(
                  theme: theme,
                  children: [
                    _buildInfoRow(
                      theme: theme,
                      icon: Icons.stars_outlined,
                      label: 'Points',
                      value: '${profile.pointsBalance ?? 0}',
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(
          child: Text('Erreur: $err'),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required ThemeData theme,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withOpacity(0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required ThemeData theme,
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 24,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
