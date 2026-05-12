import 'package:shared_preferences/shared_preferences.dart';

/// Servicio para persistencia de datos del jugador
class StorageService {
  static final StorageService _instance = StorageService._internal();
  late SharedPreferences _prefs;

  StorageService._internal();

  factory StorageService() {
    return _instance;
  }

  /// Inicializa el servicio de almacenamiento
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Guarda el nombre del jugador
  Future<void> savePlayerName(String name) async {
    await _prefs.setString('player_name', name);
  }

  /// Obtiene el nombre del jugador guardado
  String? getPlayerName() {
    return _prefs.getString('player_name');
  }

  /// Guarda la edad del jugador
  Future<void> savePlayerAge(int age) async {
    await _prefs.setInt('player_age', age);
  }

  /// Obtiene la edad del jugador guardada
  int? getPlayerAge() {
    return _prefs.getInt('player_age');
  }

  /// Verifica si el jugador ya fue configurado
  bool hasPlayerData() {
    return _prefs.containsKey('player_name') && _prefs.containsKey('player_age');
  }

  /// Limpia todos los datos del jugador
  Future<void> clearPlayerData() async {
    await _prefs.remove('player_name');
    await _prefs.remove('player_age');
  }

  /// Obtiene todos los datos del jugador
  Map<String, dynamic> getPlayerData() {
    return {
      'name': getPlayerName(),
      'age': getPlayerAge(),
    };
  }
}
