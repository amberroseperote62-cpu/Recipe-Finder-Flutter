import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorites_controller.dart';

/// Heart button that adds/removes a recipe from favorites with feedback.
class FavoriteButton extends StatelessWidget {
  const FavoriteButton({super.key, required this.meal, required this.favorites});
  final Meal meal;
  final FavoritesController favorites;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: favorites,
      builder: (context, _) {
        final isFav = favorites.isFavorite(meal.id);
        return IconButton(
          tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
          iconSize: 28,
          color: Theme.of(context).colorScheme.primary,
          icon: Icon(isFav ? Icons.favorite : Icons.favorite_border),
          onPressed: () {
            final messenger = ScaffoldMessenger.of(context);
            if (isFav) {
              favorites.remove(meal.id);
            } else {
              favorites.add(meal);
            }
            messenger
              ..hideCurrentSnackBar()
              ..showSnackBar(SnackBar(
                content: Text(isFav
                    ? 'Removed "${meal.name}" from favorites'
                    : 'Saved "${meal.name}" to favorites'),
                duration: const Duration(seconds: 2),
              ));
          },
        );
      },
    );
  }
}
