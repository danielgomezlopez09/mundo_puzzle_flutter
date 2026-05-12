import 'package:mundo_puzzle_flutter/models/card_model.dart';

/// Servicio que gestiona la lógica del juego y los datos
class GameService {
  static final GameService _instance = GameService._internal();

  late PlayerProfile _playerProfile;
  late List<World> _worlds;
  late Map<String, CardModel> _cardsMap;
  int _currentCorrectAnswersInARow = 0;

  GameService._internal();

  factory GameService() {
    return _instance;
  }

  /// Inicializa el servicio del juego
  Future<void> initialize() async {
    _initializeWorlds();
    _initializeCards();
    _playerProfile = PlayerProfile(
      playerId: 'player_001',
      playerName: 'Jugador',
      createdDate: DateTime.now(),
    );
  }

  /// Inicializa los mundos del juego
  void _initializeWorlds() {
    _worlds = [
      World(
        id: 'MT',
        name: 'Magia Traviesa',
        description: 'Sumas simples (hasta 20)',
        iconUrl: 'assets/icons/magic.png',
        order: 1,
        educationalLevel: 'Sumas simples',
        character: 'Mika',
        cardIds: List.generate(45, (i) => 'MT-${(i + 1).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'FC',
        name: 'Fondo de Coral',
        description: 'Conteo y números (1-10)',
        iconUrl: 'assets/icons/coral.png',
        order: 0,
        educationalLevel: 'Conteo y números',
        character: 'Spongy',
        cardIds: List.generate(45, (i) => 'FC-${(i + 46).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'IJ',
        name: 'Isla Jurásica',
        description: 'Restas y comparación',
        iconUrl: 'assets/icons/dino.png',
        order: 2,
        educationalLevel: 'Restas y comparación',
        character: 'Dinos',
        cardIds: List.generate(45, (i) => 'IJ-${(i + 91).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'FH',
        name: 'Fortaleza Hunter',
        description: 'Tablas de multiplicar',
        iconUrl: 'assets/icons/hunter.png',
        order: 3,
        educationalLevel: 'Tablas de multiplicar',
        character: 'Samurái',
        cardIds: List.generate(45, (i) => 'FH-${(i + 136).toString().padLeft(3, '0')}'),
      ),
      World(
        id: 'VR',
        name: 'Valle de la Risa',
        description: 'Divisiones y lógica',
        iconUrl: 'assets/icons/laugh.png',
        order: 4,
        educationalLevel: 'Divisiones y lógica',
        character: 'Tralaleros',
        cardIds: List.generate(45, (i) => 'VR-${(i + 181).toString().padLeft(3, '0')}'),
      ),
    ];
  }

  /// Inicializa las cartas del juego
  void _initializeCards() {
    _cardsMap = {};
    
    // Aquí se cargarían todas las 225 cartas desde una fuente de datos
    // Por ahora, creamos cartas de ejemplo
    for (var world in _worlds) {
      for (var cardId in world.cardIds) {
        _cardsMap[cardId] = _createSampleCard(cardId, world.id);
      }
    }
  }

  /// Crea una carta de ejemplo
  CardModel _createSampleCard(String cardId, String worldId) {
    final cardNumber = int.parse(cardId.split('-')[1]);
    late CardRarity rarity;

    // Determinar rareza según el número de carta
    if (cardNumber % 45 >= 41) {
      rarity = CardRarity.legendary;
    } else if (cardNumber % 45 >= 31) {
      rarity = CardRarity.special;
    } else {
      rarity = CardRarity.common;
    }

    return CardModel(
      id: cardId,
      worldId: worldId,
      name: 'Carta $cardId',
      description: 'Descripción de la carta $cardId',
      imageUrl: 'assets/cards/$cardId.png',
      rarity: rarity,
      questions: _generateQuestionsForCard(cardId, worldId),
    );
  }

  /// Genera preguntas para una carta
  List<Question> _generateQuestionsForCard(String cardId, String worldId) {
    return List.generate(12, (index) {
      return Question(
        id: '${cardId}_q${index + 1}',
        text: 'Pregunta de ejemplo ${index + 1}',
        options: ['Opción A', 'Opción B', 'Opción C', 'Opción D', 'Opción E', 'Opción F'],
        correctAnswerIndex: index % 6,
        educationalLevel: worldId,
        topic: 'Matemáticas',
      );
    });
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
    progress.resetCorrectStreak();
  }

  /// Verifica si se debe desbloquear una carta dorada
  bool shouldUnlockLegendary() => _currentCorrectAnswersInARow >= 10;

  /// Obtiene el contador actual de respuestas correctas seguidas
  int getCurrentCorrectStreak() => _currentCorrectAnswersInARow;

  /// Obtiene el progreso de una carta
  CardProgress? getCardProgress(String cardId) {
    return _playerProfile.cardProgress[cardId];
  }

  /// Obtiene el progreso total del jugador
  double getTotalProgress() {
    if (_cardsMap.isEmpty) return 0;
    return (_playerProfile.totalCardsCollected / _cardsMap.length) * 100;
  }

  /// Obtiene las cartas desbloqueadas
  List<CardModel> getUnlockedCards() {
    return _cardsMap.values
        .where((card) {
          final progress = _playerProfile.cardProgress[card.id];
          return progress != null && progress.isUnlocked;
        })
        .toList();
  }

  /// Obtiene las cartas desbloqueadas de un mundo
  List<CardModel> getUnlockedCardsFromWorld(String worldId) {
    return getUnlockedCards()
        .where((card) => card.worldId == worldId)
        .toList();
  }

  /// Verifica si un mundo está desbloqueado
  bool isWorldUnlocked(String worldId) {
    final world = getWorld(worldId);
    if (world == null) return false;
    
    // El primer mundo siempre está desbloqueado
    if (world.order == 0) return true;
    
    // Los demás mundos se desbloquean si tienes 15+ cartas del mundo anterior
    final previousWorld = _worlds.firstWhere((w) => w.order == world.order - 1);
    final unlockedFromPrevious = getUnlockedCardsFromWorld(previousWorld.id);
    
    return unlockedFromPrevious.length >= 15;
  }

  /// Reinicia el progreso del juego (para pruebas)
  void resetProgress() {
    _playerProfile.cardProgress.clear();
    _playerProfile.totalCardsCollected = 0;
    _playerProfile.totalLegendaryCards = 0;
    _currentCorrectAnswersInARow = 0;
  }
}
