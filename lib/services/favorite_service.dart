import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_detail.dart';

class FavoriteService {
  static const String _favoritesKey = 'favorite_meals';

  Future<List<MealDetail>> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson.map((String mealJson) {
      final Map<String, dynamic> decodedMeal = jsonDecode(mealJson);
      return MealDetail.fromLocalJson(decodedMeal);
    }).toList();
  }

  Future<bool> isFavorite(String mealId) async {
    final List<MealDetail> favorites = await getFavorites();

    return favorites.any((MealDetail meal) => meal.id == mealId);
  }

  Future<void> addFavorite(MealDetail meal) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<MealDetail> favorites = await getFavorites();

    final bool alreadyExists = favorites.any(
      (MealDetail favoriteMeal) => favoriteMeal.id == meal.id,
    );

    if (!alreadyExists) {
      favorites.add(meal);
    }

    final List<String> favoritesJson = favorites.map((MealDetail favoriteMeal) {
      return jsonEncode(favoriteMeal.toLocalJson());
    }).toList();

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }

  Future<void> removeFavorite(String mealId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<MealDetail> favorites = await getFavorites();

    favorites.removeWhere((MealDetail meal) => meal.id == mealId);

    final List<String> favoritesJson = favorites.map((MealDetail favoriteMeal) {
      return jsonEncode(favoriteMeal.toLocalJson());
    }).toList();

    await prefs.setStringList(_favoritesKey, favoritesJson);
  }
}