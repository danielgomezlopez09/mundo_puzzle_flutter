/// Modelo que representa una carta coleccionable en Mundo Puzzle
class Card {
  final String id;
  final String worldId;
  final String name;
  final String description;
  final String imageUrl;
  final CardRarity rarity;
  final int puzzlePieces;
  final List<Question> questions;

  Card({
    required this.id,
    required this.worldId,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.rarity,
    this.puzzlePieces = 12,
    required this.questions,
  });

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'worldId': worldId,
      'name': name,
      'description': description,
      'imageUrl': imageUrl,
      'rarity': rarity.toString(),
      'puzzlePieces': puzzlePieces,
      'questions': questions.map((q) => q.toJson()).toList(),
    };
  }

  /// Crea un modelo desde JSON
  factory Card.fromJson(Map<String, dynamic> json) {
    return Card(
      id: json['id'],
      worldId: json['worldId'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['imageUrl'],
      rarity: CardRarity.values.firstWhere(
        (e) => e.toString() == json['rarity'],
      ),
      puzzlePieces: json['puzzlePieces'] ?? 12,
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
    );
  }
}

/// Enumeración para las rarezas de cartas
enum CardRarity {
  common,    // Gris
  special,   // Azul
  legendary, // Dorado
}

/// Modelo que representa una pregunta educativa
class Question {
  final String id;
  final String text;
  final List<String> options;
  final int correctAnswerIndex;
  final String educationalLevel;
  final String topic;

  Question({
    required this.id,
    required this.text,
    required this.options,
    required this.correctAnswerIndex,
    required this.educationalLevel,
    required this.topic,
  });

  /// Obtiene la respuesta correcta
  String get correctAnswer => options[correctAnswerIndex];

  /// Verifica si una respuesta es correcta
  bool isCorrect(int selectedIndex) => selectedIndex == correctAnswerIndex;

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'options': options,
      'correctAnswerIndex': correctAnswerIndex,
      'educationalLevel': educationalLevel,
      'topic': topic,
    };
  }

  /// Crea un modelo desde JSON
  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'],
      text: json['text'],
      options: List<String>.from(json['options']),
      correctAnswerIndex: json['correctAnswerIndex'],
      educationalLevel: json['educationalLevel'],
      topic: json['topic'],
    );
  }
}

/// Modelo que representa el progreso del jugador en una carta
class CardProgress {
  final String cardId;
  int unlockedPieces;
  int correctAnswersInARow;
  bool isUnlocked;
  DateTime? unlockedDate;

  CardProgress({
    required this.cardId,
    this.unlockedPieces = 0,
    this.correctAnswersInARow = 0,
    this.isUnlocked = false,
    this.unlockedDate,
  });

  /// Agrega una pieza al puzzle
  void addPuzzlePiece() {
    if (unlockedPieces < 12) {
      unlockedPieces++;
      if (unlockedPieces == 12) {
        isUnlocked = true;
        unlockedDate = DateTime.now();
      }
    }
  }

  /// Incrementa el contador de respuestas correctas seguidas
  void incrementCorrectStreak() {
    correctAnswersInARow++;
  }

  /// Reinicia el contador de respuestas correctas seguidas
  void resetCorrectStreak() {
    correctAnswersInARow = 0;
  }

  /// Verifica si se desbloqueó una carta dorada (10 respuestas correctas seguidas)
  bool shouldUnlockLegendary() => correctAnswersInARow >= 10;

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'cardId': cardId,
      'unlockedPieces': unlockedPieces,
      'correctAnswersInARow': correctAnswersInARow,
      'isUnlocked': isUnlocked,
      'unlockedDate': unlockedDate?.toIso8601String(),
    };
  }

  /// Crea un modelo desde JSON
  factory CardProgress.fromJson(Map<String, dynamic> json) {
    return CardProgress(
      cardId: json['cardId'],
      unlockedPieces: json['unlockedPieces'] ?? 0,
      correctAnswersInARow: json['correctAnswersInARow'] ?? 0,
      isUnlocked: json['isUnlocked'] ?? false,
      unlockedDate: json['unlockedDate'] != null
          ? DateTime.parse(json['unlockedDate'])
          : null,
    );
  }
}

/// Modelo que representa un mundo en la aplicación
class World {
  final String id;
  final String name;
  final String description;
  final String iconUrl;
  final int order;
  final String educationalLevel;
  final String character;
  final List<String> cardIds;

  World({
    required this.id,
    required this.name,
    required this.description,
    required this.iconUrl,
    required this.order,
    required this.educationalLevel,
    required this.character,
    required this.cardIds,
  });

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'iconUrl': iconUrl,
      'order': order,
      'educationalLevel': educationalLevel,
      'character': character,
      'cardIds': cardIds,
    };
  }

  /// Crea un modelo desde JSON
  factory World.fromJson(Map<String, dynamic> json) {
    return World(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      iconUrl: json['iconUrl'],
      order: json['order'],
      educationalLevel: json['educationalLevel'],
      character: json['character'],
      cardIds: List<String>.from(json['cardIds']),
    );
  }
}

/// Modelo que representa el perfil del jugador
class PlayerProfile {
  final String playerId;
  String playerName;
  int totalCardsCollected;
  int totalLegendaryCards;
  DateTime createdDate;
  Map<String, CardProgress> cardProgress;

  PlayerProfile({
    required this.playerId,
    required this.playerName,
    this.totalCardsCollected = 0,
    this.totalLegendaryCards = 0,
    required this.createdDate,
    Map<String, CardProgress>? cardProgress,
  }) : cardProgress = cardProgress ?? {};

  /// Obtiene el porcentaje de progreso total
  double getProgressPercentage(int totalCards) {
    return (totalCardsCollected / totalCards) * 100;
  }

  /// Convierte el modelo a JSON
  Map<String, dynamic> toJson() {
    return {
      'playerId': playerId,
      'playerName': playerName,
      'totalCardsCollected': totalCardsCollected,
      'totalLegendaryCards': totalLegendaryCards,
      'createdDate': createdDate.toIso8601String(),
      'cardProgress': cardProgress.map(
        (key, value) => MapEntry(key, value.toJson()),
      ),
    };
  }

  /// Crea un modelo desde JSON
  factory PlayerProfile.fromJson(Map<String, dynamic> json) {
    return PlayerProfile(
      playerId: json['playerId'],
      playerName: json['playerName'],
      totalCardsCollected: json['totalCardsCollected'] ?? 0,
      totalLegendaryCards: json['totalLegendaryCards'] ?? 0,
      createdDate: DateTime.parse(json['createdDate']),
      cardProgress: (json['cardProgress'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, CardProgress.fromJson(value)),
      ),
    );
  }
}
