import 'package:flutter/material.dart';
import 'package:opendelivery_shared_widgets/opendelivery_shared_widgets.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});
  static const String route = '/favorites';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(title: 'Favorites'),
      body: const EmptyStateView(icon: Icons.favorite_border_rounded, title: 'No favorites yet', subtitle: 'Restaurants you like will appear here'),
    );
  }
}
