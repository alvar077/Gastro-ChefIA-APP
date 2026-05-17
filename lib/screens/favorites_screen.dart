import 'package:flutter/material.dart';

import '../models/meal_detail.dart';
import '../services/favorite_service.dart';
import '../widgets/loading_view.dart';
import '../widgets/state_message.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final FavoriteService _favoriteService = FavoriteService();

  late Future<List<MealDetail>> _favoritesFuture;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  void _loadFavorites() {
    _favoritesFuture = _favoriteService.getFavorites();
  }

  Future<void> _removeFavorite(String mealId) async {
    await _favoriteService.removeFavorite(mealId);

    if (mounted) {
      setState(() {
        _loadFavorites();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Receita removida dos favoritos.'),
        ),
      );
    }
  }

  void _openMealDetails(String mealId) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: mealId,
    ).then((_) {
      setState(() {
        _loadFavorites();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas favoritas'),
      ),
      body: FutureBuilder<List<MealDetail>>(
        future: _favoritesFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<List<MealDetail>> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const LoadingView(
              message: 'Carregando receitas favoritas',
            );
          }

          if (snapshot.hasError) {
            return _buildErrorMessage();
          }

          final List<MealDetail> favorites = snapshot.data ?? [];

          if (favorites.isEmpty) {
            return _buildEmptyFavorites();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (BuildContext context, int index) {
              final MealDetail meal = favorites[index];

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
                  subtitle: Text('${meal.category} • ${meal.area}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () {
                      _removeFavorite(meal.id);
                    },
                  ),
                  onTap: () {
                    _openMealDetails(meal.id);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyFavorites() {
    return StateMessage(
      icon: Icons.favorite_border,
      title: 'Nenhuma receita favorita ainda.',
      message: 'Abra uma receita e toque em "Salvar nos favoritos".',
      buttonText: 'Buscar receitas',
      onButtonPressed: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildErrorMessage() {
    return const StateMessage(
      icon: Icons.error_outline,
      title: 'Erro ao carregar favoritos.',
      message: 'Não foi possível carregar suas receitas favoritas.',
    );
  }
}