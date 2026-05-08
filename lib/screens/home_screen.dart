import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SearchType {
  nome,
  ingrediente,
  categoria,
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _searchController = TextEditingController();

  SearchType _searchType = SearchType.nome;

  final categories = [
    'Sobremesas',
    'Carnes',
    'Massas',
    'Frango',
    'Peixes',
    'Vegetariano',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchRecipe() {
    if (_formKey.currentState!.validate()) {
      final searchText = _searchController.text.trim();

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
  }) {
    return RadioListTile<SearchType>(
      title: Text(title),
      value: value,
      groupValue: _searchType,
      onChanged: (SearchType? selectedValue) {
        setState(() {
          _searchType = selectedValue!;
        });
      },
      contentPadding: EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
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
            Form(
              key: _formKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar receita',
                      hintText: 'Ex: frango, bolo, massa...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
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
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),

                  _buildRadioOption(
                    title: 'Nome da receita',
                    value: SearchType.nome,
                  ),
                  _buildRadioOption(
                    title: 'Ingrediente',
                    value: SearchType.ingrediente,
                  ),
                  _buildRadioOption(
                    title: 'Categoria',
                    value: SearchType.categoria,
                  ),

                  const SizedBox(height: 8),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _searchRecipe,
                      icon: const Icon(Icons.search),
                      label: const Text('Pesquisar'),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Categorias',
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),

            const SizedBox(height: 12),

            Expanded(
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return InkWell(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/details',
                        arguments: category,
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.restaurant_menu,
                            size: 42,
                            color: Colors.deepOrange,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            category,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}