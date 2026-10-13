class Ingredient {
  final String name;
  final String measure;
  const Ingredient(this.name, this.measure);
}

class Meal {
  final String id;
  final String name;
  final String thumb;
  final String? category;
  final String? area;
  final String? instructions;
  final List<Ingredient> ingredients;

  const Meal({
    required this.id,
    required this.name,
    required this.thumb,
    this.category,
    this.area,
    this.instructions,
    this.ingredients = const [],
  });

  /// Builds a Meal from a TheMealDB API response item.
  factory Meal.fromJson(Map<String, dynamic> json) {
    final ingredients = <Ingredient>[];
    for (var i = 1; i <= 20; i++) {
      final name = (json['strIngredient$i'] ?? '').toString().trim();
      final measure = (json['strMeasure$i'] ?? '').toString().trim();
      if (name.isNotEmpty) ingredients.add(Ingredient(name, measure));
    }
    return Meal(
      id: json['idMeal'].toString(),
      name: (json['strMeal'] ?? '').toString(),
      thumb: (json['strMealThumb'] ?? '').toString(),
      category: json['strCategory'] as String?,
      area: json['strArea'] as String?,
      instructions: json['strInstructions'] as String?,
      ingredients: ingredients,
    );
  }

  /// Small version saved to local storage for the favorites list.
  Map<String, dynamic> toSavedJson() => {
        'id': id,
        'name': name,
        'thumb': thumb,
        'category': category,
      };

  factory Meal.fromSavedJson(Map<String, dynamic> json) => Meal(
        id: json['id'].toString(),
        name: json['name'].toString(),
        thumb: json['thumb'].toString(),
        category: json['category'] as String?,
      );
}
