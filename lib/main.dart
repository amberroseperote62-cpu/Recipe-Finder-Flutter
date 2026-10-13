import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/home_screen.dart';
import 'services/favorites_controller.dart';
import 'services/meal_api.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const RecipeFinderApp());
}

class RecipeFinderApp extends StatefulWidget {
  const RecipeFinderApp({super.key});

  @override
  State<RecipeFinderApp> createState() => _RecipeFinderAppState();
}

class _RecipeFinderAppState extends State<RecipeFinderApp> {
  final _favorites = FavoritesController();
  final _api = MealApi();

  @override
  void initState() {
    super.initState();
    _favorites.load();
  }

  @override
  void dispose() {
    _favorites.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
    );

    return MaterialApp(
      title: 'Recipe Finder',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        textTheme: GoogleFonts.poppinsTextTheme(base.textTheme),
        appBarTheme: AppBarTheme(
          centerTitle: true,
          backgroundColor: base.colorScheme.primary,
          foregroundColor: base.colorScheme.onPrimary,
        ),
      ),
      home: HomeScreen(api: _api, favorites: _favorites),
    );
  }
}
