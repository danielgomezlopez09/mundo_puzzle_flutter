import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mundo_puzzle_flutter/models/card_model.dart';
import 'package:mundo_puzzle_flutter/services/question_generator.dart';

/// Servicio que gestiona la lógica del juego y los datos
class GameService {
  static final GameService _instance = GameService._internal();
  static GameService get instance => _instance;

  late PlayerProfile _playerProfile;
  late List<World> _worlds;
  late Map<String, CardModel> _cardsMap;
  int _currentCorrectAnswersInARow = 0;
  int _playerAge = 10; // Edad por defecto

  GameService._internal();

  factory GameService() {
    return _instance;
  }

  static GameService get() {
    return _instance;
  }

  /// Inicializa el servicio del juego
  Future<void> initialize() async {
    _initializeWorlds();
    await _initializeCards();
    _playerProfile = PlayerProfile(
      playerId: 'player_001',
      playerName: 'Jugador',
      createdDate: DateTime.now(),
    );
  }

  /// Inicializa el perfil del jugador con nombre y edad
  void initializePlayer(String playerName, int age) {
    _playerProfile = PlayerProfile(
      playerId: 'player_${DateTime.now().millisecondsSinceEpoch}',
      playerName: playerName,
      createdDate: DateTime.now(),
    );
    _playerAge = age;
  }

  /// Obtiene la edad del jugador
  int get playerAge => _playerAge;

  /// Obtiene el nombre del jugador
  String get playerName => _playerProfile.playerName;

  /// Inicializa los mundos del juego
  void _initializeWorlds() {
    _worlds = [
      World(
        id: 'FC',
        name: 'Fondo de Coral',
        description: 'Conteo y números (1-10)',
        iconUrl: 'assets/icons/coral.png',
        order: 0,
        educationalLevel: 'Conteo y números',
        character: 'Spongy',
        cardIds: List.generate(45, (i) => 'FC_${(i + 1).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'MT',
        name: 'Magia Traviesa',
        description: 'Sumas simples (hasta 20)',
        iconUrl: 'assets/icons/magic.png',
        order: 1,
        educationalLevel: 'Sumas simples',
        character: 'Mika',
        cardIds: List.generate(45, (i) => 'MT_${(i + 1).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'IJ',
        name: 'Isla Jurásica',
        description: 'Restas y comparación',
        iconUrl: 'assets/icons/dino.png',
        order: 2,
        educationalLevel: 'Restas y comparación',
        character: 'Dinos',
        cardIds: List.generate(45, (i) => 'IJ_${(i + 1).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'FH',
        name: 'Fortaleza Hunter',
        description: 'Tablas de multiplicar',
        iconUrl: 'assets/icons/hunter.png',
        order: 3,
        educationalLevel: 'Tablas de multiplicar',
        character: 'Samurái',
        cardIds: List.generate(45, (i) => 'FH_${(i + 1).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'VR',
        name: 'Valle de la Risa',
        description: 'Divisiones y lógica',
        iconUrl: 'assets/icons/laugh.png',
        order: 4,
        educationalLevel: 'Divisiones y lógica',
        character: 'Tralaleros',
        cardIds: List.generate(45, (i) => 'VR_${(i + 1).toString().padLeft(3, '0')}'),
      ),
    ];
  }

  /// Inicializa las cartas del juego
  Future<void> _initializeCards() async {
    _cardsMap = {};
    await _loadCardsFromJson();
  }

  /// Carga las cartas desde el archivo JSON
  Future<void> _loadCardsFromJson() async {
    try {
      final jsonString = await rootBundle.loadString('assets/cards_data.json');
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
      final worlds = jsonData['worlds'] as List<dynamic>;

      for (var worldData in worlds) {
        final worldId = worldData['id'] as String;
        final cards = worldData['cards'] as List<dynamic>;

        for (var cardData in cards) {
          final cardId = cardData['id'] as String;
          final name = cardData['name'] as String;
          final imageUrl = cardData['imageUrl'] as String;
          final rarity = _parseRarity(cardData['rarity'] as String);

          _cardsMap[cardId] = CardModel(
            id: cardId,
            worldId: worldId,
            name: name,
            description: 'Carta coleccionable de $name',
            imageUrl: imageUrl,
            rarity: rarity,
            questions: [],
          );
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading cards from JSON: $e');
      }
      // Fallback: crear cartas de ejemplo sin imágenes
      for (var world in _worlds) {
        for (var cardId in world.cardIds) {
          _cardsMap[cardId] = _createSampleCard(cardId, world.id);
        }
      }
    }
  }

  /// Convierte string de rareza a enum
  CardRarity _parseRarity(String rarityString) {
    switch (rarityString.toLowerCase()) {
      case 'legendary':
        return CardRarity.legendary;
      case 'special':
        return CardRarity.special;
      default:
        return CardRarity.common;
    }
  }

  /// Crea una carta de ejemplo (fallback)
  CardModel _createSampleCard(String cardId, String worldId) {
    late CardRarity rarity;

    // Determinar rareza según el número de carta
    if (cardId.contains('_45')) {
      rarity = CardRarity.legendary;
    } else if (cardId.contains('_3') || cardId.contains('_4')) {
      rarity = CardRarity.special;
    } else {
      rarity = CardRarity.common;
    }

    return CardModel(
      id: cardId,
      worldId: worldId,
      name: 'Carta $cardId',
      description: 'Descripción de la carta $cardId',
      imageUrl: '', // Sin imagen en fallback
      rarity: rarity,
      questions: [],
    );
  }

  /// Obtiene todos los mundos
  List<World> getWorlds() => _worlds;

  /// Obtiene un mundo por ID
  World? getWorld(String worldId) {
    try {
      return _worlds.firstWhere((w) => w.id == worldId);
    } catch (e) {
      return null;
    }
  }

  /// Obtiene una carta por ID
  CardModel? getCard(String cardId) => _cardsMap[cardId];

  /// Obtiene todas las cartas de un mundo
  List<CardModel> getCardsFromWorld(String worldId) {
    return _cardsMap.values
        .where((card) => card.worldId == worldId)
        .toList();
  }

  /// Obtiene el perfil del jugador
  PlayerProfile getPlayerProfile() => _playerProfile;

  /// Actualiza el nombre del jugador
  void updatePlayerName(String newName) {
    _playerProfile.playerName = newName;
  }

  /// Procesa una respuesta correcta
  void processCorrectAnswer(String cardId) {
    _currentCorrectAnswersInARow++;
    
    if (!_playerProfile.cardProgress.containsKey(cardId)) {
      _playerProfile.cardProgress[cardId] = CardProgress(cardId: cardId);
    }
    
    final progress = _playerProfile.cardProgress[cardId]!;
    progress.addPuzzlePiece();
    progress.incrementCorrectStreak();

    // Si la carta se desbloqueó
    if (progress.isUnlocked) {
      _playerProfile.totalCardsCollected++;
    }
  }

  /// Procesa una respuesta incorrecta
  void processIncorrectAnswer(String cardId) {
    _currentCorrectAnswersInARow = 0;
    
    if (!_playerProfile.cardProgress.containsKey(cardId)) {
      _playerProfile.cardProgress[cardId] = CardProgress(cardId: cardId);
    }
    
    final progress = _playerProfile.cardProgress[cardId]!;
    progress.incrementFailCount();
  }

  /// Obtiene el progreso de una carta
  CardProgress? getCardProgress(String cardId) {
    return _playerProfile.cardProgress[cardId];
  }

  /// Obtiene todas las cartas desbloqueadas
  List<CardModel> getUnlockedCards() {
    return _playerProfile.cardProgress.entries
        .where((entry) => entry.value.isUnlocked)
        .map((entry) => getCard(entry.key))
        .whereType<CardModel>()
        .toList();
  }

  /// Obtiene las cartas desbloqueadas de un mundo específico
  List<CardModel> getUnlockedCardsFromWorld(String worldId) {
    return getUnlockedCards()
        .where((card) => card.worldId == worldId)
        .toList();
  }

  /// Obtiene el progreso total del jugador
  double getTotalProgress() {
    final totalCards = _cardsMap.length;
    if (totalCards == 0) return 0;
    return (_playerProfile.totalCardsCollected / totalCards) * 100;
  }

  /// Verifica si un mundo está desbloqueado
  bool isWorldUnlocked(String worldId) {
    // El primer mundo siempre está desbloqueado
    if (worldId == 'FC') return true;
    
    // Los demás mundos se desbloquean cuando se completan 10 cartas del mundo anterior
    final worldOrder = _worlds.firstWhere((w) => w.id == worldId).order;
    if (worldOrder == 0) return true;
    
    final previousWorld = _worlds.firstWhere((w) => w.order == worldOrder - 1);
    final unlockedInPrevious = getUnlockedCardsFromWorld(previousWorld.id).length;
    
    return unlockedInPrevious >= 10;
  }

  /// Reinicia el progreso del jugador
  void resetProgress() {
    _playerProfile.cardProgress.clear();
    _playerProfile.totalCardsCollected = 0;
    _playerProfile.totalLegendaryCards = 0;
    _currentCorrectAnswersInARow = 0;
  }
}
