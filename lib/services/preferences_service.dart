import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _kitchenModeKey = 'kitchen_mode';

  Future<bool> getKitchenMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kitchenModeKey) ?? false;
  }

  Future<void> saveKitchenMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_kitchenModeKey, value);
  }
}