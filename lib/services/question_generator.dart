import 'dart:math';
import 'package:mundo_puzzle_flutter/models/card_model.dart';

/// Generador automático de preguntas matemáticas según nivel de edad
class QuestionGenerator {
  static final Random _random = Random();

  /// Define los rangos de números según la edad
  static final Map<int, Map<String, dynamic>> _ageRanges = {
    7: {'min': 1, 'max': 10, 'operations': ['suma', 'resta'], 'name': 'Principiante'},
    8: {'min': 1, 'max': 20, 'operations': ['suma', 'resta'], 'name': 'Básico'},
    9: {'min': 1, 'max': 50, 'operations': ['suma', 'resta', 'multiplicación'], 'name': 'Intermedio'},
    10: {'min': 1, 'max': 100, 'operations': ['suma', 'resta', 'multiplicación'], 'name': 'Avanzado'},
    11: {'min': 1, 'max': 100, 'operations': ['suma', 'resta', 'multiplicación', 'división'], 'name': 'Experto'},
    12: {'min': 1, 'max': 200, 'operations': ['suma', 'resta', 'multiplicación', 'división'], 'name': 'Maestro'},
    13: {'min': 1, 'max': 500, 'operations': ['suma', 'resta', 'multiplicación', 'división'], 'name': 'Profesional'},
    14: {'min': 1, 'max': 1000, 'operations': ['suma', 'resta', 'multiplicación', 'división'], 'name': 'Élite'},
    15: {'min': 1, 'max': 1000, 'operations': ['suma', 'resta', 'multiplicación', 'división'], 'name': 'Campeón'},
  };

  /// Genera una pregunta matemática según la edad del jugador
  static Question generateQuestion(int playerAge, String questionId) {
    final ageConfig = _ageRanges[playerAge] ?? _ageRanges[15]!;
    final min = (ageConfig['min'] as int?) ?? 1;
    final max = (ageConfig['max'] as int?) ?? 100;
    final operations = (ageConfig['operations'] as List<String>?) ?? ['suma', 'resta'];

    // Selecciona una operación aleatoria
    final operation = operations[_random.nextInt(operations.length)];

    // Genera números aleatorios
    int num1 = _random.nextInt(max - min + 1) + min;
    int num2 = _random.nextInt(max - min + 1) + min;

    // Asegura que num1 >= num2 para restas
    if (operation == 'resta' && num1 < num2) {
      final temp = num1;
      num1 = num2;
      num2 = temp;
    }

    // Calcula la respuesta correcta
    int correctAnswer;
    String questionText;

    switch (operation) {
      case 'suma':
        correctAnswer = num1 + num2;
        questionText = '$num1 + $num2 = ?';
        break;
      case 'resta':
        correctAnswer = num1 - num2;
        questionText = '$num1 - $num2 = ?';
        break;
      case 'multiplicación':
        correctAnswer = num1 * num2;
        questionText = '$num1 × $num2 = ?';
        break;
      case 'división':
        // Asegura que la división sea exacta
        num2 = _random.nextInt(10) + 1; // Divisor entre 1 y 10
        num1 = correctAnswer = _random.nextInt(100) + 1;
        num1 = num1 * num2; // Multiplica para asegurar división exacta
        correctAnswer = num1 ~/ num2;
        questionText = '$num1 ÷ $num2 = ?';
        break;
      default:
        correctAnswer = num1 + num2;
        questionText = '$num1 + $num2 = ?';
    }

    // Genera opciones de respuesta incorrectas
    final List<String> options = [correctAnswer.toString()];

    // Genera 5 opciones incorrectas
    while (options.length < 6) {
      int wrongAnswer;
      
      if (operation == 'división') {
        wrongAnswer = _random.nextInt(correctAnswer * 2) + 1;
      } else if (operation == 'multiplicación') {
        wrongAnswer = correctAnswer + _random.nextInt(correctAnswer ~/ 2 + 1) - (correctAnswer ~/ 4);
      } else {
        wrongAnswer = correctAnswer + _random.nextInt(20) - 10;
      }

      if (wrongAnswer != correctAnswer && !options.contains(wrongAnswer.toString())) {
        options.add(wrongAnswer.toString());
      }
    }

    // Mezcla las opciones
    options.shuffle();

    // Encuentra el índice de la respuesta correcta
    final correctAnswerIndex = options.indexOf(correctAnswer.toString());

    return Question(
      id: questionId,
      text: questionText,
      options: options,
      correctAnswerIndex: correctAnswerIndex,
      educationalLevel: (ageConfig['name'] as String?) ?? 'Desconocido',
      topic: operation,
    );
  }

  /// Genera múltiples preguntas para una carta
  static List<Question> generateQuestionsForCard(int playerAge, String cardId, {int count = 12}) {
    final questions = <Question>[];
    for (int i = 0; i < count; i++) {
      questions.add(generateQuestion(playerAge, '$cardId-q$i'));
    }
    return questions;
  }

  /// Obtiene el nivel educativo según la edad
  static String getEducationalLevel(int age) {
    return _ageRanges[age]?['name'] ?? 'Desconocido';
  }

  /// Obtiene el rango de números según la edad
  static Map<String, int> getNumberRange(int age) {
    final config = _ageRanges[age] ?? _ageRanges[15]!;
    return {
      'min': (config['min'] as int?) ?? 1,
      'max': (config['max'] as int?) ?? 100,
    };
  }
}
