import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:driver_app/features/auth/presentation/bloc/auth_bloc.dart';

class DriverProfilePage extends StatelessWidget {
  const DriverProfilePage({super.key});
  static const String route = '/driver-profile';

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final name = authState is AuthAuthenticated ? authState.user.fullName : 'Driver';

    return Scaffold(
      appBar: const AppAppBar(title: 'Profile'),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          const Center(child: CircleAvatar(radius: 40, child: Icon(Icons.drive_eta, size: 40))),
          const SizedBox(height: 16),
          Center(child: Text(name, style: context.textTheme.titleMedium)),
          const Divider(height: 40, indent: 16, endIndent: 16),
          ListTile(leading: const Icon(Icons.history), title: const Text('Trip History'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.star_outline), title: const Text('Ratings & Reviews'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.settings), title: const Text('Settings'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('Logout', style: TextStyle(color: AppColors.error)),
            onTap: () => context.read<AuthBloc>().add(const AuthLogout()),
          ),
        ],
      ),
    );
  }
}
