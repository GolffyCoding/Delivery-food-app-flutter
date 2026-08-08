import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_bloc.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_event.dart';
import 'package:customer_app/features/theme/presentation/bloc/theme_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  static const String route = '/settings';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Settings', showBackButton: true),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ListView(
            children: [
              SwitchListTile(
                title: const Text('Dark Mode'),
                secondary: const Icon(Icons.dark_mode_outlined),
                value: state.themeMode == AppThemeMode.dark,
                onChanged: (_) => context.read<ThemeBloc>().add(const ThemeToggle()),
              ),
              ListTile(
                title: const Text('Theme'),
                subtitle: Text(state.themeMode.label),
                leading: const Icon(Icons.palette_outlined),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () => context.read<ThemeBloc>().add(const ThemeToggle()),
              ),
              ListTile(
                title: const Text('Notifications'),
                leading: const Icon(Icons.notifications_outlined),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
              ListTile(
                title: const Text('Language'),
                subtitle: const Text('English'),
                leading: const Icon(Icons.language),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {},
              ),
            ],
          );
        },
      ),
    );
  }
}
