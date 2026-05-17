import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/meal_detail.dart';

// Serviço responsável por salvar, listar e remover receitas favoritas localmente.
class FavoriteService {
  static const String _favoritesKey = 'favorite_meals';

  // Lê a lista de receitas favoritas salva no SharedPreferences.
  Future<List<MealDetail>> getFavorites() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final List<String> favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

    return favoritesJson.map((String mealJson) {
      final Map<String, dynamic> decodedMeal = jsonDecode(mealJson);
      return MealDetail.fromLocalJson(decodedMeal);
    }).toList();
  }
  
  // Verifica se uma receita já está salva como favorita.
  Future<bool> isFavorite(String mealId) async {
    final List<MealDetail> favorites = await getFavorites();

    return favorites.any((MealDetail meal) => meal.id == mealId);
  }

  // Adiciona uma receita aos favoritos, evitando duplicidade.
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

  // Remove uma receita favorita usando o ID.
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