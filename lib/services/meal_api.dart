import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal.dart';

/// Talks to the free TheMealDB API (no API key needed).
class MealApi {
  static const _base = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<Meal>> _getMeals(String path) async {
    final response = await http
        .get(Uri.parse('$_base/$path'))
        .timeout(const Duration(seconds: 10));

    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final list = data['meals'];
    if (list == null) return []; // API returns null when nothing is found
    return (list as List)
        .map((e) => Meal.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Meal>> searchByName(String query) =>
      _getMeals('search.php?s=${Uri.encodeQueryComponent(query)}');

  Future<List<Meal>> filterByCategory(String category) =>
      _getMeals('filter.php?c=${Uri.encodeQueryComponent(category)}');

  Future<Meal?> lookup(String id) async {
    final results = await _getMeals('lookup.php?i=$id');
    return results.isEmpty ? null : results.first;
  }

  Future<List<String>> categories() async {
    final response = await http
        .get(Uri.parse('$_base/categories.php'))
        .timeout(const Duration(seconds: 10));
    if (response.statusCode != 200) {
      throw Exception('Server error (${response.statusCode})');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return (data['categories'] as List)
        .map((e) => (e as Map<String, dynamic>)['strCategory'].toString())
        .toList();
  }
}
