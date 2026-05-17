import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/meal_category.dart';
import '../models/meal_detail.dart';
import '../models/meal_summary.dart';


// Serviço responsável por consumir os endpoints da API TheMealDB.
class MealService {
  static const String _baseUrl = 'https://www.themealdb.com/api/json/v1/1';

  // Busca todas as categorias de receitas disponíveis na API.
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

  // Busca receitas pelo nome informado pelo usuário.
  Future<List<MealSummary>> searchMealsByName(String name) async {
    final Uri url = Uri.parse('$_baseUrl/search.php?s=$name');

    return _fetchMealList(url);
  }

  // Busca receitas que utilizam um ingrediente específico.
  Future<List<MealSummary>> searchMealsByIngredient(String ingredient) async {
    final Uri url = Uri.parse('$_baseUrl/filter.php?i=$ingredient');

    return _fetchMealList(url);
  }

  // Busca receitas pertencentes a uma categoria específica.
  Future<List<MealSummary>> searchMealsByCategory(String category) async {
    final Uri url = Uri.parse('$_baseUrl/filter.php?c=$category');

    return _fetchMealList(url);
  }

  // Busca os detalhes completos de uma receita usando o ID.
  Future<MealDetail> fetchMealDetailById(String mealId) async {
    final Uri url = Uri.parse('$_baseUrl/lookup.php?i=$mealId');

    try {
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);

        if (data['meals'] == null || data['meals'].isEmpty) {
          throw Exception('Receita não encontrada');
        }

        return MealDetail.fromJson(data['meals'][0]);
      } else {
        throw Exception('Erro ao buscar detalhes da receita');
      }
    } catch (error) {
      throw Exception('Falha de conexão com a API');
    }
  }
  
  // Método reutilizado pelas buscas que retornam listas de receitas.
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