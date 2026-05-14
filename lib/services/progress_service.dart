import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class ProgressService {
  static const String _progressKey = 'meal_progress';

  Future<Map<String, List<int>>> _getAllProgress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? progressJson = prefs.getString(_progressKey);

    if (progressJson == null) {
      return {};
    }

    final Map<String, dynamic> decodedProgress = jsonDecode(progressJson);

    return decodedProgress.map(
      (String mealId, dynamic checkedIndexes) {
        return MapEntry(
          mealId,
          List<int>.from(checkedIndexes),
        );
      },
    );
  }

  Future<List<int>> getCheckedSteps(String mealId) async {
    final Map<String, List<int>> allProgress = await _getAllProgress();

    return allProgress[mealId] ?? [];
  }

  Future<void> saveCheckedSteps({
    required String mealId,
    required List<int> checkedSteps,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, List<int>> allProgress = await _getAllProgress();

    allProgress[mealId] = checkedSteps;

    await prefs.setString(_progressKey, jsonEncode(allProgress));
  }

  Future<void> clearProgress(String mealId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, List<int>> allProgress = await _getAllProgress();

    allProgress.remove(mealId);

    await prefs.setString(_progressKey, jsonEncode(allProgress));
  }
}