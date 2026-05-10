import 'package:flutter/material.dart';

import '../models/meal_category.dart';
import '../services/meal_service.dart';

enum SearchType {
  nome,
  ingrediente,
  categoria,
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  final MealService _mealService = MealService();

  SearchType _searchType = SearchType.nome;
  bool _kitchenMode = false;

  late Future<List<MealCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _mealService.fetchCategories();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchRecipe() {
    if (_formKey.currentState!.validate()) {
      final String searchText = _searchController.text.trim();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Buscando "$searchText" por ${_getSearchTypeText()}',
          ),
        ),
      );

      Navigator.pushNamed(
        context,
        '/details',
        arguments: searchText,
      );
    }
  }

  void _openCategoryDetails(MealCategory category) {
    Navigator.pushNamed(
      context,
      '/details',
      arguments: category.name,
    );
  }

  void _reloadCategories() {
    setState(() {
      _categoriesFuture = _mealService.fetchCategories();
    });
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

  Widget _buildRadioOption({
    required String title,
    required SearchType value,
    required double fontSize,
  }) {
    return RadioListTile<SearchType>(
      title: Text(
        title,
        style: TextStyle(fontSize: fontSize),
      ),
      value: value,
      groupValue: _searchType,
      onChanged: (SearchType? selectedValue) {
        if (selectedValue != null) {
          setState(() {
            _searchType = selectedValue;
          });
        }
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double titleFontSize = _kitchenMode ? 24 : 20;
    final double textFontSize = _kitchenMode ? 18 : 14;
    final double cardFontSize = _kitchenMode ? 20 : 16;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ChefApp'),
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildKitchenModeCard(
              titleFontSize: titleFontSize,
              textFontSize: textFontSize,
            ),

            const SizedBox(height: 16),

            _buildSearchForm(
              titleFontSize: titleFontSize,
              textFontSize: textFontSize,
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categorias',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: _buildCategoriesFromApi(
                cardFontSize: cardFontSize,
                textFontSize: textFontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKitchenModeCard({
    required double titleFontSize,
    required double textFontSize,
  }) {
    return Card(
      child: SwitchListTile(
        title: Text(
          'Modo cozinha',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Aumenta a fonte para facilitar o uso durante o preparo',
          style: TextStyle(fontSize: textFontSize),
        ),
        secondary: const Icon(Icons.soup_kitchen),
        value: _kitchenMode,
        onChanged: (bool value) {
          setState(() {
            _kitchenMode = value;
          });
        },
      ),
    );
  }

  Widget _buildSearchForm({
    required double titleFontSize,
    required double textFontSize,
  }) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _searchController,
            style: TextStyle(fontSize: textFontSize),
            decoration: InputDecoration(
              labelText: 'Buscar receita',
              hintText: 'Ex: frango, bolo, massa...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            validator: (String? value) {
              if (value == null || value.trim().isEmpty) {
                return 'Digite algo para buscar';
              }

              if (value.trim().length < 3) {
                return 'Digite pelo menos 3 caracteres';
              }

              return null;
            },
          ),

          const SizedBox(height: 12),

          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Buscar por:',
              style: TextStyle(
                fontSize: titleFontSize,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          _buildRadioOption(
            title: 'Nome da receita',
            value: SearchType.nome,
            fontSize: textFontSize,
          ),

          _buildRadioOption(
            title: 'Ingrediente',
            value: SearchType.ingrediente,
            fontSize: textFontSize,
          ),

          _buildRadioOption(
            title: 'Categoria',
            value: SearchType.categoria,
            fontSize: textFontSize,
          ),

          const SizedBox(height: 8),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _searchRecipe,
              icon: const Icon(Icons.search),
              label: Text(
                'Pesquisar',
                style: TextStyle(fontSize: textFontSize),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoriesFromApi({
    required double cardFontSize,
    required double textFontSize,
  }) {
    return FutureBuilder<List<MealCategory>>(
      future: _categoriesFuture,
      builder: (
        BuildContext context,
        AsyncSnapshot<List<MealCategory>> snapshot,
      ) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
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

                Text(
                  'Não foi possível carregar as categorias.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: textFontSize,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                Text(
                  'Verifique sua conexão com a internet e tente novamente.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: textFontSize),
                ),

                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed: _reloadCategories,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Tentar novamente'),
                ),
              ],
            ),
          );
        }

        final List<MealCategory> categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Center(
            child: Text(
              'Nenhuma categoria encontrada.',
              style: TextStyle(fontSize: textFontSize),
            ),
          );
        }

        return GridView.builder(
          itemCount: categories.length,
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 240,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.9,
          ),
          itemBuilder: (BuildContext context, int index) {
            final MealCategory category = categories[index];

            return InkWell(
              onTap: () {
                _openCategoryDetails(category);
              },
              borderRadius: BorderRadius.circular(16),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: Image.network(
                        category.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (
                          BuildContext context,
                          Object error,
                          StackTrace? stackTrace,
                        ) {
                          return Container(
                            color: Colors.orange.shade100,
                            child: const Center(
                              child: Icon(
                                Icons.restaurant_menu,
                                size: 48,
                                color: Colors.deepOrange,
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        category.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: cardFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}