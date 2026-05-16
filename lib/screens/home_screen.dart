import 'package:flutter/material.dart';

import '../models/meal_category.dart';
import '../services/meal_service.dart';
import '../services/preferences_service.dart';

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
  final PreferencesService _preferencesService = PreferencesService();

  SearchType _searchType = SearchType.nome;
  bool _kitchenMode = false;

  late Future<List<MealCategory>> _categoriesFuture;

  @override
  void initState() {
    super.initState();
    _categoriesFuture = _mealService.fetchCategories();
    _loadKitchenMode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadKitchenMode() async {
    final bool savedKitchenMode = await _preferencesService.getKitchenMode();

    if (mounted) {
      setState(() {
        _kitchenMode = savedKitchenMode;
      });
    }
  }

  Future<void> _refreshCategories() async {
    setState(() {
      _categoriesFuture = _mealService.fetchCategories();
    });

    await _categoriesFuture;
  }

  void _searchRecipe() {
    if (_formKey.currentState!.validate()) {
      final String searchText = _searchController.text.trim();

      Navigator.pushNamed(
        context,
        '/search-results',
        arguments: {
          'searchText': searchText,
          'searchType': _searchType,
        },
      );
    }
  }

  void _openCategoryRecipes(MealCategory category) {
    Navigator.pushNamed(
      context,
      '/search-results',
      arguments: {
        'searchText': category.name,
        'searchType': SearchType.categoria,
      },
    );
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
      dense: true,
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
        title: const Text('Gastrô ChefIA'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Receitas favoritas',
            onPressed: () {
              Navigator.pushNamed(context, '/favorites');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshCategories,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(
                titleFontSize: titleFontSize,
                textFontSize: textFontSize,
              ),

              const SizedBox(height: 16),

              _buildSearchCard(
                titleFontSize: titleFontSize,
                textFontSize: textFontSize,
              ),

              const SizedBox(height: 16),

              _buildKitchenModeCard(
                titleFontSize: titleFontSize,
                textFontSize: textFontSize,
              ),

              const SizedBox(height: 24),

              _buildCategoriesHeader(
                titleFontSize: titleFontSize,
                textFontSize: textFontSize,
              ),

              const SizedBox(height: 12),

              _buildCategoriesFromApi(
                cardFontSize: cardFontSize,
                textFontSize: textFontSize,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard({
    required double titleFontSize,
    required double textFontSize,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepOrange.shade100,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.restaurant_menu,
              size: 42,
              color: Colors.deepOrange,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Olá, chef!',
                  style: TextStyle(
                    fontSize: titleFontSize + 4,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Encontre receitas por nome, ingrediente ou categoria.',
                  style: TextStyle(
                    fontSize: textFontSize,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchCard({
    required double titleFontSize,
    required double textFontSize,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buscar receita',
                style: TextStyle(
                  fontSize: titleFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _searchController,
                style: TextStyle(fontSize: textFontSize),
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(
                  hintText: 'Ex: chicken, pasta, dessert...',
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
                onFieldSubmitted: (String value) {
                  _searchRecipe();
                },
              ),

              const SizedBox(height: 12),

              Text(
                'Tipo de busca:',
                style: TextStyle(
                  fontSize: textFontSize,
                  fontWeight: FontWeight.bold,
                ),
              ),

              RadioGroup<SearchType>(
                groupValue: _searchType,
                onChanged: (SearchType? selectedValue) {
                  if (selectedValue != null) {
                    setState(() {
                      _searchType = selectedValue;
                    });
                  }
                },
                child: Column(
                  children: [
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
                  ],
                ),
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
        ),
      ),
    );
  }

  Widget _buildKitchenModeCard({
    required double titleFontSize,
    required double textFontSize,
  }) {
    return Card(
      elevation: 2,
      child: SwitchListTile(
        title: Text(
          'Modo cozinha',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Aumenta a fonte para facilitar o uso durante o preparo.',
          style: TextStyle(fontSize: textFontSize),
        ),
        secondary: const Icon(
          Icons.soup_kitchen,
          color: Colors.deepOrange,
        ),
        value: _kitchenMode,
        onChanged: (bool value) async {
          setState(() {
            _kitchenMode = value;
          });

          await _preferencesService.saveKitchenMode(value);
        },
      ),
    );
  }

  Widget _buildCategoriesHeader({
    required double titleFontSize,
    required double textFontSize,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Categorias',
          style: TextStyle(
            fontSize: titleFontSize,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 4),

        Text(
          'Escolha uma categoria para visualizar receitas relacionadas.',
          style: TextStyle(
            fontSize: textFontSize,
            color: Colors.grey.shade700,
          ),
        ),
      ],
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
          return const Padding(
            padding: EdgeInsets.all(32),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return _buildCategoriesError(textFontSize);
        }

        final List<MealCategory> categories = snapshot.data ?? [];

        if (categories.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nenhuma categoria encontrada.',
                style: TextStyle(fontSize: textFontSize),
              ),
            ),
          );
        }

        return GridView.builder(
          itemCount: categories.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 260,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (BuildContext context, int index) {
            final MealCategory category = categories[index];

            return InkWell(
              onTap: () {
                _openCategoryRecipes(category);
              },
              borderRadius: BorderRadius.circular(18),
              child: Card(
                clipBehavior: Clip.antiAlias,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
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

  Widget _buildCategoriesError(double textFontSize) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
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
              onPressed: () {
                setState(() {
                  _categoriesFuture = _mealService.fetchCategories();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }
}