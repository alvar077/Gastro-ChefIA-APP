import 'package:shared_preferences/shared_preferences.dart';

// Serviço responsável por salvar preferências gerais do aplicativo.
class PreferencesService {
  static const String _kitchenModeKey = 'kitchen_mode';

  // Carrega a preferência do modo cozinha.
  Future<bool> getKitchenMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_kitchenModeKey) ?? false;
  }

  // Salva se o modo cozinha está ativado ou desativado.
  Future<void> saveKitchenMode(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setBool(_kitchenModeKey, value);
  }
}