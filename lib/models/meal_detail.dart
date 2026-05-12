class MealDetail {
  final String id;
  final String name;
  final String imageUrl;
  final String instructions;
  final String category;
  final String area;
  final String youtubeUrl;
  final List<String> ingredients;

  MealDetail({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.instructions,
    required this.category,
    required this.area,
    required this.youtubeUrl,
    required this.ingredients,
  });

  factory MealDetail.fromJson(Map<String, dynamic> json) {
    final List<String> ingredientsList = [];

    for (int i = 1; i <= 20; i++) {
      final String ingredient = json['strIngredient$i'] ?? '';
      final String measure = json['strMeasure$i'] ?? '';

      if (ingredient.trim().isNotEmpty) {
        ingredientsList.add('${measure.trim()} ${ingredient.trim()}'.trim());
      }
    }

    return MealDetail(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
      instructions: json['strInstructions'] ?? '',
      category: json['strCategory'] ?? '',
      area: json['strArea'] ?? '',
      youtubeUrl: json['strYoutube'] ?? '',
      ingredients: ingredientsList,
    );
  }

  factory MealDetail.fromLocalJson(Map<String, dynamic> json) {
    return MealDetail(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      instructions: json['instructions'] ?? '',
      category: json['category'] ?? '',
      area: json['area'] ?? '',
      youtubeUrl: json['youtubeUrl'] ?? '',
      ingredients: List<String>.from(json['ingredients'] ?? []),
    );
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'instructions': instructions,
      'category': category,
      'area': area,
      'youtubeUrl': youtubeUrl,
      'ingredients': ingredients,
    };
  }
}