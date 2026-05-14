import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class NoteService {
  static const String _notesKey = 'meal_notes';

  Future<Map<String, String>> _getAllNotes() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final String? notesJson = prefs.getString(_notesKey);

    if (notesJson == null) {
      return {};
    }

    final Map<String, dynamic> decodedNotes = jsonDecode(notesJson);

    return decodedNotes.map(
      (String key, dynamic value) {
        return MapEntry(key, value.toString());
      },
    );
  }

  Future<String> getNote(String mealId) async {
    final Map<String, String> notes = await _getAllNotes();

    return notes[mealId] ?? '';
  }

  Future<void> saveNote({
    required String mealId,
    required String note,
  }) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, String> notes = await _getAllNotes();

    notes[mealId] = note;

    await prefs.setString(_notesKey, jsonEncode(notes));
  }

  Future<void> deleteNote(String mealId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    final Map<String, String> notes = await _getAllNotes();

    notes.remove(mealId);

    await prefs.setString(_notesKey, jsonEncode(notes));
  }
}