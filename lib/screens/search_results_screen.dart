import 'package:flutter/material.dart';

import '../models/meal_summary.dart';
import '../services/meal_service.dart';
import 'home_screen.dart';

class SearchResultsScreen extends StatefulWidget {
  const SearchResultsScreen({super.key});

  @override
  State<SearchResultsScreen> createState() => _SearchResultsScreenState();
}

class _SearchResultsScreenState extends State<SearchResultsScreen> {
  final MealService _mealService = MealService();

  late Future<List<MealSummary>> _mealsFuture;
  late String _searchText;
  late SearchType _searchType;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final Map<String, dynamic> args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;

    _searchText = args['searchText'] as String;
    _searchType = args['searchType'] as SearchType;

    _mealsFuture = _searchMeals();
  }

  Future<List<MealSummary>> _searchMeals() {
    switch (_searchType) {
      case SearchType.nome:
        return _mealService.searchMealsByName(_searchText);
      case SearchType.ingrediente:
        return _mealService.searchMealsByIngredient(_searchText);
      case SearchType.categoria:
        return _mealService.searchMealsByCategory(_searchText);
    }
  }

  String _getSearchTypeText() {
    switch (_searchType) {
      case SearchType.nome:
        return 'nome';
      case SearchType.ingrediente:
        return 'ingrediente';
      case SearchType.categoria:
        return 'categoria';
    }
  }

  void _reloadSearch() {
    setState(() {
      _mealsFuture = _searchMeals();
    });
  }

  void _openMealDetails(MealSummary meal) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: meal.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resultados da busca'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<MealSummary>>(
          future: _mealsFuture,
          builder: (
            BuildContext context,
            AsyncSnapshot<List<MealSummary>> snapshot,
          ) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (snapshot.hasError) {
              return _buildErrorMessage();
            }

            final List<MealSummary> meals = snapshot.data ?? [];

            if (meals.isEmpty) {
              return _buildEmptyMessage();
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Busca por ${_getSearchTypeText()}: $_searchText',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 12),

                Expanded(
                  child: ListView.builder(
                    itemCount: meals.length,
                    itemBuilder: (BuildContext context, int index) {
                      final MealSummary meal = meals[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              meal.imageUrl,
                              width: 64,
                              height: 64,
                              fit: BoxFit.cover,
                              errorBuilder: (
                                BuildContext context,
                                Object error,
                                StackTrace? stackTrace,
                              ) {
                                return Container(
                                  width: 64,
                                  height: 64,
                                  color: Colors.orange.shade100,
                                  child: const Icon(
                                    Icons.restaurant_menu,
                                    color: Colors.deepOrange,
                                  ),
                                );
                              },
                            ),
                          ),
                          title: Text(
                            meal.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: const Text('Toque para ver os detalhes'),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            _openMealDetails(meal);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wifi_off,
            size: 56,
            color: Colors.deepOrange,
          ),

          const SizedBox(height: 12),

          const Text(
            'Erro ao buscar receitas.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Verifique sua conexão com a internet e tente novamente.',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: _reloadSearch,
            icon: const Icon(Icons.refresh),
            label: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off,
            size: 56,
            color: Colors.deepOrange,
          ),

          const SizedBox(height: 12),

          const Text(
            'Nenhuma receita encontrada.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Não encontramos resultados para "$_searchText".',
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.arrow_back),
            label: const Text('Voltar e tentar outra busca'),
          ),
        ],
      ),
    );
  }
}