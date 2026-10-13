import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorites_controller.dart';
import '../services/meal_api.dart';
import '../widgets/meal_card.dart';
import '../widgets/state_views.dart';

/// Shows the full recipe: image, ingredients, and instructions.
class DetailScreen extends StatefulWidget {
  const DetailScreen({
    super.key,
    required this.meal,
    required this.api,
    required this.favorites,
  });
  final Meal meal;
  final MealApi api;
  final FavoritesController favorites;

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  late Future<Meal?> _future;
  Meal? _full;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = widget.api.lookup(widget.meal.id).then((m) {
      _full = m;
      return m;
    });
  }

  void _toggleFavorite() {
    final meal = _full ?? widget.meal;
    final isFav = widget.favorites.isFavorite(meal.id);
    if (isFav) {
      widget.favorites.remove(meal.id);
    } else {
      widget.favorites.add(meal);
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        content: Text(isFav
            ? 'Removed from favorites'
            : 'Saved to favorites'),
        duration: const Duration(seconds: 2),
      ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.meal.name)),
      floatingActionButton: ListenableBuilder(
        listenable: widget.favorites,
        builder: (context, _) {
          final isFav = widget.favorites.isFavorite(widget.meal.id);
          return FloatingActionButton.extended(
            onPressed: _toggleFavorite,
            icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
            label: Text(isFav ? 'Saved' : 'Save recipe'),
          );
        },
      ),
      body: FutureBuilder<Meal?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const LoadingView(message: 'Loading recipe...');
          }
          if (snapshot.hasError) {
            return ErrorView(onRetry: () => setState(_load));
          }
          final meal = snapshot.data;
          if (meal == null) {
            return const EmptyView(
              icon: Icons.restaurant_menu,
              title: 'Recipe not found',
              subtitle: 'This recipe is no longer available.',
            );
          }
          return _RecipeContent(meal: meal);
        },
      ),
    );
  }
}

class _RecipeContent extends StatelessWidget {
  const _RecipeContent({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView(
      padding: const EdgeInsets.only(bottom: 96),
      children: [
        MealImage(url: meal.thumb, height: 240, width: double.infinity),
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.name,
                  style: theme.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  if (meal.category != null)
                    Chip(
                      avatar: const Icon(Icons.category, size: 18),
                      label: Text(meal.category!),
                    ),
                  if (meal.area != null)
                    Chip(
                      avatar: const Icon(Icons.public, size: 18),
                      label: Text(meal.area!),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              Text('Ingredients', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              ...meal.ingredients.map(
                (ing) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.check_circle_outline,
                          size: 20, color: theme.colorScheme.primary),
                      const SizedBox(width: 8),
                      Expanded(child: Text('${ing.measure} ${ing.name}'.trim())),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text('Instructions', style: theme.textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                meal.instructions ?? 'No instructions available.',
                style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
