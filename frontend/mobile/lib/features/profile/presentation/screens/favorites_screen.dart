import 'package:flutter/material.dart';
import '../../../../core/widgets/zb_empty_state.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favorites')),
      body: const ZbEmptyState(
        icon: Icons.favorite_outline,
        title: 'No favorites yet',
        subtitle: 'Heart your favorite restaurants to find them easily',
      ),
    );
  }
}
