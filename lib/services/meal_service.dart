import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal_category.dart';
import '../models/meal_summary.dart';

class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  Future<List<MealCategory>> fetchCategories() async {
    final Uri url = Uri.parse('$_baseUrl/categories.php');

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final List<dynamic> categoriesJson = data['categories'] ?? [];

        return categoriesJson
            .map((categoryJson) => MealCategory.fromJson(categoryJson))
            .toList();
      } else {
        throw Exception('Erro ao buscar categorias');
      }
    } catch (error) {
      throw Exception('Falha de conexão com a API');
    }
  }

  Future<List<MealSummary>> searchMealsByName(String name) async {
    final Uri url = Uri.parse('$_baseUrl/search.php?s=$name');

    return _fetchMealList(url);
  }

  Future<List<MealSummary>> searchMealsByIngredient(String ingredient) async {
    final Uri url = Uri.parse('$_baseUrl/filter.php?i=$ingredient');

    return _fetchMealList(url);
  }

  Future<List<MealSummary>> searchMealsByCategory(String category) async {
    final Uri url = Uri.parse('$_baseUrl/filter.php?c=$category');

    return _fetchMealList(url);
  }

  Future<List<MealSummary>> _fetchMealList(Uri url) async {
    try {
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['meals'] == null) {
          return [];
        }

        final List<dynamic> mealsJson = data['meals'];

        return mealsJson
            .map((mealJson) => MealSummary.fromJson(mealJson))
            .toList();
      } else {
        throw Exception('Erro ao buscar receitas');
      }
    } catch (error) {
      throw Exception('Falha de conexão com a API');
    }
  }
}