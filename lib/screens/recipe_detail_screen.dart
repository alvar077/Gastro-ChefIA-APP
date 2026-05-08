import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  const RecipeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final String recipeName =
        ModalRoute.of(context)?.settings.arguments as String? ?? 'Receita';

    return Scaffold(
      appBar: AppBar(
        title: Text(recipeName),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.fastfood,
                size: 80,
                color: Colors.deepOrange,
              ),
            ),

            const SizedBox(height: 16),

            Text(
              recipeName,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Ingredientes',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text('- Ingrediente 1\n- Ingrediente 2\n- Ingrediente 3'),

            const SizedBox(height: 20),

            const Text(
              'Modo de preparo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            CheckboxListTile(
              value: false,
              onChanged: (value) {},
              title: const Text('Separar os ingredientes'),
            ),
            CheckboxListTile(
              value: false,
              onChanged: (value) {},
              title: const Text('Misturar tudo em uma tigela'),
            ),
            CheckboxListTile(
              value: false,
              onChanged: (value) {},
              title: const Text('Levar ao forno ou preparar no fogão'),
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.favorite_border),
              label: const Text('Salvar nos favoritos'),
            ),
          ],
        ),
      ),
    );
  }
}