import 'package:flutter/material.dart';

import '../models/meal.dart';

/// Network image with a loading spinner and a fallback icon.
class MealImage extends StatelessWidget {
  const MealImage({super.key, required this.url, this.height, this.width});
  final String url;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      url,
      height: height,
      width: width,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, progress) => progress == null
          ? child
          : SizedBox(
              height: height,
              width: width,
              child: const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
      errorBuilder: (context, error, stack) => Container(
        height: height,
        width: width,
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        child: const Icon(Icons.restaurant, size: 32),
      ),
    );
  }
}

/// Reusable list item used on the Search and Favorites screens.
class MealCard extends StatelessWidget {
  const MealCard({
    super.key,
    required this.meal,
    required this.onTap,
    this.trailing,
  });

  final Meal meal;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            MealImage(url: meal.thumb, width: 96, height: 96),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (meal.category != null) ...[
                      const SizedBox(height: 4),
                      Text(meal.category!, style: theme.textTheme.bodySmall),
                    ],
                  ],
                ),
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}
