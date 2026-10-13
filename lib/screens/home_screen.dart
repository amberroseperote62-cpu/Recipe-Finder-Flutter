import 'package:flutter/material.dart';

import '../services/favorites_controller.dart';
import '../services/meal_api.dart';
import 'favorites_screen.dart';
import 'search_screen.dart';

/// Main shell with bottom navigation between Search and Favorites.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.api, required this.favorites});
  final MealApi api;
  final FavoritesController favorites;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          SearchScreen(api: widget.api, favorites: widget.favorites),
          FavoritesScreen(api: widget.api, favorites: widget.favorites),
        ],
      ),
      bottomNavigationBar: ListenableBuilder(
        listenable: widget.favorites,
        builder: (context, _) {
          final count = widget.favorites.items.length;
          return NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: (i) => setState(() => _index = i),
            destinations: [
              const NavigationDestination(
                icon: Icon(Icons.search),
                label: 'Search',
              ),
              NavigationDestination(
                icon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.favorite_border),
                ),
                selectedIcon: Badge(
                  isLabelVisible: count > 0,
                  label: Text('$count'),
                  child: const Icon(Icons.favorite),
                ),
                label: 'Favorites',
              ),
            ],
          );
        },
      ),
    );
  }
}
