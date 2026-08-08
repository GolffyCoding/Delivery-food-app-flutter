import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:customer_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:customer_app/features/profile/presentation/pages/address_page.dart';
import 'package:customer_app/features/profile/presentation/pages/favorites_page.dart';
import 'package:customer_app/features/profile/presentation/pages/settings_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});
  static const String route = '/profile';

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticated ? authState.user.fullName : 'Guest';
    final email = authState is AuthAuthenticated ? authState.user.email : '';

    return Scaffold(
      appBar: const AppAppBar(title: 'Profile'),
      body: SingleChildScrollView(
        padding: AppSpacing.screenPadding,
        child: Column(
          children: [
            const CircleAvatar(radius: 40, child: Icon(Icons.person, size: 40)),
            const SizedBox(height: AppSpacing.lg),
            Text(name, style: context.textTheme.headlineSmall),
            const SizedBox(height: AppSpacing.xs),
            Text(email, style: context.textTheme.bodyMedium?.copyWith(color: context.colorScheme.outline)),
            const SizedBox(height: 32),
            _ProfileTile(icon: Icons.location_on_outlined, title: 'My Addresses', onTap: () => context.push(AddressPage.route)),
            _ProfileTile(icon: Icons.payment_outlined, title: 'Payment Methods', onTap: () {}),
            _ProfileTile(icon: Icons.favorite_outline_rounded, title: 'Favorites', onTap: () => context.push(FavoritesPage.route)),
            _ProfileTile(icon: Icons.settings_outlined, title: 'Settings', onTap: () => context.push(SettingsPage.route)),
            _ProfileTile(icon: Icons.help_outline_rounded, title: 'Help & Support', onTap: () {}),
            const Divider(height: 32),
            _ProfileTile(
              icon: Icons.logout,
              title: 'Log Out',
              titleColor: AppColors.error,
              onTap: () {
                context
                    .showConfirmDialog(title: 'Log Out', message: 'Are you sure you want to log out?', confirmText: 'Log Out', isDestructive: true)
                    .then((confirmed) {
                  if (confirmed == true && context.mounted) {
                    context.read<AuthBloc>().add(const AuthLogout());
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _ProfileTile({required this.icon, required this.title, this.titleColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? context.colorScheme.onSurfaceVariant),
      title: Text(title, style: TextStyle(color: titleColor)),
      trailing: const Icon(Icons.chevron_right_rounded),
      shape: RoundedRectangleBorder(borderRadius: AppRadius.mdBorder),
      onTap: onTap,
    );
  }
}
