class MealSummary {
  final String id;
  final String name;
  final String imageUrl;

  MealSummary({
    required this.id,
    required this.name,
    required this.imageUrl,
  });

  factory MealSummary.fromJson(Map<String, dynamic> json) {
    return MealSummary(
      id: json['idMeal'] ?? '',
      name: json['strMeal'] ?? '',
      imageUrl: json['strMealThumb'] ?? '',
    );
  }
}