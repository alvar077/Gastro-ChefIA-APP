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
}