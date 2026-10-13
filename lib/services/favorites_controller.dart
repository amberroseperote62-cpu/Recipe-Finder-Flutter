import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal.dart';

/// Holds the saved recipes and persists them on the device.
class FavoritesController extends ChangeNotifier {
  static const _key = 'favorite_meals';
  final List<Meal> _items = [];

  List<Meal> get items => List.unmodifiable(_items);

  bool isFavorite(String id) => _items.any((m) => m.id == id);

  Future<void> load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_key);
      if (raw != null) {
        final list = jsonDecode(raw) as List;
        _items
          ..clear()
          ..addAll(list.map((e) => Meal.fromSavedJson(e as Map<String, dynamic>)));
        notifyListeners();
      }
    } catch (_) {
      // If saved data is corrupted, just start with an empty list.
    }
  }

  Future<void> add(Meal meal, {int? index}) async {
    if (isFavorite(meal.id)) return;
    if (index == null || index > _items.length) {
      _items.add(meal);
    } else {
      _items.insert(index, meal);
    }
    notifyListeners();
    await _save();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((m) => m.id == id);
    notifyListeners();
    await _save();
  }

  Future<void> clearAll() async {
    _items.clear();
    notifyListeners();
    await _save();
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(_items.map((m) => m.toSavedJson()).toList()),
    );
  }
}
