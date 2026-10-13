import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorites_controller.dart';
import '../services/meal_api.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/meal_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({
    super.key,
    required this.api,
    required this.favorites,
  });
  final MealApi api;
  final FavoritesController favorites;

  /// Removes a recipe and offers an Undo action.
  void _delete(BuildContext context, Meal meal) {
    final index = favorites.items.indexWhere((m) => m.id == meal.id);
    favorites.remove(meal.id);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('Deleted "${meal.name}"'),
          duration: const Duration(seconds: 2),
          persist: false,
          action: SnackBarAction(
            label: 'UNDO',
            onPressed: () => favorites.add(meal, index: index),
          ),
        ),
      );
  }

  Future<void> _deleteWithConfirm(BuildContext context, Meal meal) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete recipe?',
      message: 'Remove "${meal.name}" from your favorites?',
    );
    if (ok && context.mounted) _delete(context, meal);
  }

  Future<void> _clearAll(BuildContext context) async {
    final ok = await confirmDelete(
      context,
      title: 'Delete all favorites?',
      message: 'This will remove all saved recipes. This cannot be undone.',
    );
    if (ok) {
      await favorites.clearAll();
      if (context.mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            const SnackBar(
              content: Text('All favorites deleted'),
              duration: Duration(seconds: 2),
            ),
          );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        final items = favorites.items;
        return Scaffold(
          appBar: AppBar(
            title: const Text('My Favorites'),
            actions: [
              if (items.isNotEmpty)
                IconButton(
                  tooltip: 'Delete all',
                  icon: const Icon(Icons.delete_sweep),
                  onPressed: () => _clearAll(context),
                ),
            ],
          ),
          body: items.isEmpty
              ? const EmptyView(
                  icon: Icons.favorite_border,
                  title: 'No favorites yet',
                  subtitle:
                      'Tap the heart on a recipe to save it here for later.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: items.length,
                  itemBuilder: (context, i) {
                    final meal = items[i];
                    return Dismissible(
                      key: ValueKey(meal.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        padding: const EdgeInsets.only(right: 24),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.error,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.delete,
                          color: Theme.of(context).colorScheme.onError,
                        ),
                      ),
                      confirmDismiss: (_) => confirmDelete(
                        context,
                        title: 'Delete recipe?',
                        message: 'Remove "${meal.name}" from your favorites?',
                      ),
                      onDismissed: (_) => _delete(context, meal),
                      child: MealCard(
                        meal: meal,
                        trailing: IconButton(
                          tooltip: 'Delete',
                          icon: Icon(
                            Icons.delete_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          onPressed: () => _deleteWithConfirm(context, meal),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(
                              meal: meal,
                              api: api,
                              favorites: favorites,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
