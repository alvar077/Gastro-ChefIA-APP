import 'package:flutter/material.dart';

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

  SearchType _searchType = SearchType.nome;
  bool _kitchenMode = false;

  final List<String> categories = [
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
    final double cardFontSize = _kitchenMode ? 22 : 18;

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
            Card(
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
            ),

            const SizedBox(height: 16),

            Form(
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
              child: GridView.builder(
                itemCount: categories.length,
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 220,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemBuilder: (BuildContext context, int index) {
                  final String category = categories[index];

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
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: cardFontSize,
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