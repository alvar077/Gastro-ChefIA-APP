import 'package:flutter/material.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final favoriteRecipes = [
      'Bolo de chocolate',
      'Macarrão à bolonhesa',
      'Frango assado',
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Receitas favoritas'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: favoriteRecipes.length,
        itemBuilder: (context, index) {
          final recipe = favoriteRecipes[index];

          return Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, color: Colors.red),
              title: Text(recipe),
              subtitle: const Text('Receita salva localmente'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/details',
                  arguments: recipe,
                );
              },
            ),
          );
        },
      ),
    );
  }
}