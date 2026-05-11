import 'package:flutter/material.dart';

import 'screens/home_screen.dart';
import 'screens/recipe_detail_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/search_results_screen.dart';

void main() {
  runApp(const ChefApp());
}

class ChefApp extends StatelessWidget {
  const ChefApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ChefApp',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.deepOrange,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/details': (context) => const RecipeDetailScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/search-results': (context) => const SearchResultsScreen(),
      },
    );
  }
}