import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opendelivery_core/opendelivery_core.dart';
import 'package:opendelivery_design_system/opendelivery_design_system.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';
import 'package:merchant_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:merchant_app/features/restaurant_setup/bloc/restaurant_session_bloc.dart';
import 'package:merchant_app/features/reviews/pages/merchant_reviews_page.dart';

class MerchantProfilePage extends StatelessWidget {
  const MerchantProfilePage({super.key});
  static const String route = '/merchant-profile';

  @override
  Widget build(BuildContext context) {
    final session = context.watch<RestaurantSessionBloc>().state;
    final restaurantName = session is RestaurantSessionReady ? session.name : 'My Restaurant';
    final restaurantId = session is RestaurantSessionReady ? session.restaurantId : null;

    return Scaffold(
      appBar: const AppAppBar(title: 'Store Settings'),
      body: ListView(
        children: [
          const SizedBox(height: 32),
          const Center(child: CircleAvatar(radius: 40, child: Icon(Icons.store, size: 40))),
          const SizedBox(height: 16),
          Center(child: Text(restaurantName, style: context.textTheme.titleMedium)),
          const Divider(height: 40, indent: 16, endIndent: 16),
          ListTile(leading: const Icon(Icons.edit_outlined), title: const Text('Store Profile'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.schedule_outlined), title: const Text('Operating Hours'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Store Address'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
          ListTile(
            leading: const Icon(Icons.reviews_outlined),
            title: const Text('Customer Reviews'),
            trailing: const Icon(Icons.chevron_right),
            onTap: restaurantId == null ? null : () => context.push(MerchantReviewsPage.route, extra: restaurantId),
          ),
          ListTile(leading: const Icon(Icons.settings), title: const Text('App Settings'), trailing: const Icon(Icons.chevron_right), onTap: () {}),
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
