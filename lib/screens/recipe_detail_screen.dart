import 'package:flutter/material.dart';

import '../models/meal_detail.dart';
import '../services/favorite_service.dart';
import '../services/meal_service.dart';
import '../services/note_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final MealService _mealService = MealService();
  final FavoriteService _favoriteService = FavoriteService();
  final NoteService _noteService = NoteService();

  final TextEditingController _noteController = TextEditingController();

  late Future<MealDetail> _mealDetailFuture;
  late String _mealId;

  bool _isFavorite = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _mealId = ModalRoute.of(context)?.settings.arguments as String;
      _mealDetailFuture = _mealService.fetchMealDetailById(_mealId);

      _loadFavoriteStatus();
      _loadNote();

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _loadFavoriteStatus() async {
    final bool favoriteStatus = await _favoriteService.isFavorite(_mealId);

    if (mounted) {
      setState(() {
        _isFavorite = favoriteStatus;
      });
    }
  }

  Future<void> _loadNote() async {
    final String savedNote = await _noteService.getNote(_mealId);

    if (mounted) {
      setState(() {
        _noteController.text = savedNote;
      });
    }
  }

  Future<void> _saveNote() async {
    final String note = _noteController.text.trim();

    await _noteService.saveNote(
      mealId: _mealId,
      note: note,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação salva com sucesso.'),
        ),
      );
    }
  }

  Future<void> _deleteNote() async {
    await _noteService.deleteNote(_mealId);

    if (mounted) {
      setState(() {
        _noteController.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação apagada.'),
        ),
      );
    }
  }

  void _reloadMealDetail() {
    setState(() {
      _mealDetailFuture = _mealService.fetchMealDetailById(_mealId);
    });
  }

  Future<void> _toggleFavorite(MealDetail meal) async {
    if (_isFavorite) {
      await _favoriteService.removeFavorite(meal.id);

      if (mounted) {
        setState(() {
          _isFavorite = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita removida dos favoritos.'),
          ),
        );
      }
    } else {
      await _favoriteService.addFavorite(meal);

      if (mounted) {
        setState(() {
          _isFavorite = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Receita salva nos favoritos.'),
          ),
        );
      }
    }
  }

  void _showVideoUnavailableMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Vídeo da receita ainda não integrado nesta versão.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da receita'),
      ),
      body: FutureBuilder<MealDetail>(
        future: _mealDetailFuture,
        builder: (
          BuildContext context,
          AsyncSnapshot<MealDetail> snapshot,
        ) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return _buildErrorMessage();
          }

          final MealDetail? meal = snapshot.data;

          if (meal == null) {
            return _buildEmptyMessage();
          }

          return _buildMealDetail(meal);
        },
      ),
    );
  }

  Widget _buildMealDetail(MealDetail meal) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.network(
            meal.imageUrl,
            height: 220,
            width: double.infinity,
            fit: BoxFit.cover,
            errorBuilder: (
              BuildContext context,
              Object error,
              StackTrace? stackTrace,
            ) {
              return Container(
                height: 220,
                color: Colors.orange.shade100,
                child: const Icon(
                  Icons.restaurant_menu,
                  size: 80,
                  color: Colors.deepOrange,
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        Text(
          meal.name,
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            Chip(
              avatar: const Icon(Icons.category),
              label: Text(meal.category),
            ),
            Chip(
              avatar: const Icon(Icons.public),
              label: Text(meal.area),
            ),
          ],
        ),

        const SizedBox(height: 20),

        const Text(
          'Ingredientes',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        ...meal.ingredients.map(
          (String ingredient) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(ingredient),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        const Text(
          'Modo de preparo',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 8),

        Text(
          meal.instructions,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),

        const SizedBox(height: 20),

        _buildNotesSection(),

        const SizedBox(height: 20),

        if (meal.youtubeUrl.isNotEmpty)
          ElevatedButton.icon(
            onPressed: _showVideoUnavailableMessage,
            icon: const Icon(Icons.play_circle),
            label: const Text('Ver vídeo da receita'),
          ),

        const SizedBox(height: 12),

        ElevatedButton.icon(
          onPressed: () {
            _toggleFavorite(meal);
          },
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
          ),
          label: Text(
            _isFavorite ? 'Remover dos favoritos' : 'Salvar nos favoritos',
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Anotações pessoais',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Use este espaço para salvar ajustes, lembretes ou observações sobre a receita.',
            ),

            const SizedBox(height: 12),

            TextField(
              controller: _noteController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Ex: colocar menos sal, adicionar queijo...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveNote,
                    icon: const Icon(Icons.save),
                    label: const Text('Salvar anotação'),
                  ),
                ),

                const SizedBox(width: 8),

                IconButton(
                  onPressed: _deleteNote,
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Apagar anotação',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.deepOrange,
            ),

            const SizedBox(height: 12),

            const Text(
              'Erro ao carregar detalhes da receita.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Verifique sua conexão e tente novamente.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: _reloadMealDetail,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyMessage() {
    return const Center(
      child: Text('Receita não encontrada.'),
    );
  }
}