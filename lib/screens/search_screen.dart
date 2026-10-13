import 'package:flutter/material.dart';

import '../models/meal.dart';
import '../services/favorites_controller.dart';
import '../services/meal_api.dart';
import '../widgets/favorite_button.dart';
import '../widgets/meal_card.dart';
import '../widgets/state_views.dart';
import 'detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.api, required this.favorites});
  final MealApi api;
  final FavoritesController favorites;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  static const _defaultQuery = 'chicken';

  final _controller = TextEditingController();
  late Future<List<Meal>> _future;
  late Future<List<Meal>> Function() _request;
  List<String> _categories = [];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _run(() => widget.api.searchByName(_defaultQuery));
    _loadCategories();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _run(Future<List<Meal>> Function() request) {
    _request = request;
    _future = request();
  }

  Future<void> _loadCategories() async {
    try {
      final cats = await widget.api.categories();
      if (mounted) setState(() => _categories = cats);
    } catch (_) {
      // Category chips are optional; search still works without them.
    }
  }

  void _search() {
    final query = _controller.text.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('Type a dish or ingredient to search.')),
        );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _selectedCategory = null;
      _run(() => widget.api.searchByName(query));
    });
  }

  void _selectCategory(String category, bool selected) {
    FocusScope.of(context).unfocus();
    setState(() {
      _controller.clear();
      if (selected) {
        _selectedCategory = category;
        _run(() => widget.api.filterByCategory(category));
      } else {
        _selectedCategory = null;
        _run(() => widget.api.searchByName(_defaultQuery));
      }
    });
  }

  void _retry() => setState(() => _run(_request));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Finder')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: TextField(
              controller: _controller,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              decoration: InputDecoration(
                hintText: 'Search recipes (e.g. pasta, beef)',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  tooltip: 'Search',
                  icon: const Icon(Icons.arrow_forward),
                  onPressed: _search,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
              ),
            ),
          ),
          if (_categories.isNotEmpty)
            SizedBox(
              height: 52,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: _categories.length,
                itemBuilder: (context, i) {
                  final cat = _categories[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: _selectedCategory == cat,
                      onSelected: (sel) => _selectCategory(cat, sel),
                    ),
                  );
                },
              ),
            ),
          Expanded(
            child: FutureBuilder<List<Meal>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const LoadingView(message: 'Finding recipes...');
                }
                if (snapshot.hasError) {
                  return ErrorView(onRetry: _retry);
                }
                final meals = snapshot.data ?? [];
                if (meals.isEmpty) {
                  return const EmptyView(
                    icon: Icons.search_off,
                    title: 'No recipes found',
                    subtitle: 'Try a different dish, ingredient, or category.',
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: meals.length,
                  itemBuilder: (context, i) {
                    final meal = meals[i];
                    return MealCard(
                      meal: meal,
                      trailing: FavoriteButton(
                        meal: meal,
                        favorites: widget.favorites,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailScreen(
                            meal: meal,
                            api: widget.api,
                            favorites: widget.favorites,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
