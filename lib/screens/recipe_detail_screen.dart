import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/meal_detail.dart';
import '../services/favorite_service.dart';
import '../services/meal_service.dart';
import '../services/note_service.dart';
import '../services/progress_service.dart';

class RecipeDetailScreen extends StatefulWidget {
  const RecipeDetailScreen({super.key});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final MealService _mealService = MealService();
  final FavoriteService _favoriteService = FavoriteService();
  final NoteService _noteService = NoteService();
  final ProgressService _progressService = ProgressService();

  final TextEditingController _noteController = TextEditingController();

  late Future<MealDetail> _mealDetailFuture;
  late String _mealId;

  bool _isFavorite = false;
  bool _initialized = false;

  List<int> _checkedSteps = [];

  YoutubePlayerController? _youtubeController;
  String? _currentVideoId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      _mealId = ModalRoute.of(context)?.settings.arguments as String;

      _loadMealDetail();
      _loadFavoriteStatus();
      _loadNote();
      _loadProgress();

      _initialized = true;
    }
  }

  @override
  void dispose() {
    _noteController.dispose();
    _disposeYoutubeController();
    super.dispose();
  }

  void _loadMealDetail() {
    _mealDetailFuture = _mealService.fetchMealDetailById(_mealId).then((meal) {
      _setupYoutubePlayer(meal.youtubeUrl);
      return meal;
    });
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

  Future<void> _loadProgress() async {
    final List<int> savedSteps = await _progressService.getCheckedSteps(_mealId);

    if (mounted) {
      setState(() {
        _checkedSteps = savedSteps;
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

  Future<void> _toggleStep(int index, bool checked) async {
    setState(() {
      if (checked) {
        if (!_checkedSteps.contains(index)) {
          _checkedSteps.add(index);
        }
      } else {
        _checkedSteps.remove(index);
      }
    });

    await _progressService.saveCheckedSteps(
      mealId: _mealId,
      checkedSteps: _checkedSteps,
    );
  }

  Future<void> _clearProgress() async {
    await _progressService.clearProgress(_mealId);

    if (mounted) {
      setState(() {
        _checkedSteps.clear();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Progresso do preparo apagado.'),
        ),
      );
    }
  }

  void _reloadMealDetail() {
    setState(() {
      _disposeYoutubeController();
      _loadMealDetail();
    });
  }

  Future<void> _openVideoInYoutube(String youtubeUrl) async {
    final Uri videoUri = Uri.parse(youtubeUrl);

    final bool opened = await launchUrl(
      videoUri,
      mode: LaunchMode.platformDefault,
      webOnlyWindowName: '_blank',
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível abrir o vídeo no YouTube.'),
        ),
      );
    }
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

  String? _extractYoutubeVideoId(String youtubeUrl) {
    if (youtubeUrl.trim().isEmpty) {
      return null;
    }

    final Uri? uri = Uri.tryParse(youtubeUrl);

    if (uri == null) {
      return null;
    }

    if (uri.host.contains('youtu.be')) {
      if (uri.pathSegments.isNotEmpty) {
        return uri.pathSegments.first;
      }
    }

    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }

    return null;
  }

  void _setupYoutubePlayer(String youtubeUrl) {
    final String? videoId = _extractYoutubeVideoId(youtubeUrl);

    if (videoId == null || videoId.isEmpty) {
      _disposeYoutubeController();
      return;
    }

    if (_currentVideoId == videoId && _youtubeController != null) {
      return;
    }

    _disposeYoutubeController();

    _youtubeController = YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        strictRelatedVideos: true,
        enableCaption: true,
      ),
    );

    _currentVideoId = videoId;
  }

  void _disposeYoutubeController() {
    _youtubeController?.close();
    _youtubeController = null;
    _currentVideoId = null;
  }

  List<String> _getPreparationSteps(String instructions) {
    return instructions
        .split(RegExp(r'\.\s+'))
        .map((String step) => step.trim())
        .where((String step) => step.isNotEmpty)
        .map((String step) {
      if (step.endsWith('.')) {
        return step;
      }

      return '$step.';
    }).toList();
  }

  double _calculateProgressPercentage(int totalSteps) {
    if (totalSteps == 0) {
      return 0;
    }

    return _checkedSteps.length / totalSteps;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes da receita'),
        actions: [
          FutureBuilder<MealDetail>(
            future: _mealDetailFuture,
            builder: (
              BuildContext context,
              AsyncSnapshot<MealDetail> snapshot,
            ) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final MealDetail meal = snapshot.data!;

              return IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                ),
                tooltip: _isFavorite
                    ? 'Remover dos favoritos'
                    : 'Salvar nos favoritos',
                onPressed: () {
                  _toggleFavorite(meal);
                },
              );
            },
          ),
        ],
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
    final List<String> preparationSteps = _getPreparationSteps(
      meal.instructions,
    );

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

        _buildPreparationProgressSection(preparationSteps),

        const SizedBox(height: 20),

        _buildNotesSection(),

        const SizedBox(height: 20),

        _buildVideoSection(meal),

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

  Widget _buildVideoSection(MealDetail meal) {
    if (meal.youtubeUrl.isEmpty) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Vídeo da receita',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Assista ao vídeo diretamente na tela de detalhes. Se o player não reproduzir por restrição do YouTube, use o botão abaixo.',
            ),

            const SizedBox(height: 12),

            if (_youtubeController != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: YoutubePlayer(
                    controller: _youtubeController!,
                  ),
                ),
              )
            else
              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Icon(
                    Icons.play_circle_outline,
                    size: 64,
                    color: Colors.deepOrange,
                  ),
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  _openVideoInYoutube(meal.youtubeUrl);
                },
                icon: const Icon(Icons.open_in_new),
                label: const Text('Abrir vídeo no YouTube'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPreparationProgressSection(List<String> preparationSteps) {
    final double progress = _calculateProgressPercentage(
      preparationSteps.length,
    );

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Modo de preparo',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              '${_checkedSteps.length} de ${preparationSteps.length} etapas concluídas',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(value: progress),

            const SizedBox(height: 12),

            ...List.generate(
              preparationSteps.length,
              (int index) {
                final bool isChecked = _checkedSteps.contains(index);

                return CheckboxListTile(
                  value: isChecked,
                  onChanged: (bool? value) {
                    _toggleStep(index, value ?? false);
                  },
                  title: Text(
                    preparationSteps[index],
                    textAlign: TextAlign.justify,
                  ),
                  controlAffinity: ListTileControlAffinity.leading,
                );
              },
            ),

            const SizedBox(height: 8),

            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearProgress,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Limpar progresso'),
              ),
            ),
          ],
        ),
      ),
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