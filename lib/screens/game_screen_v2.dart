import 'package:flutter/material.dart';
import 'package:mundo_puzzle_flutter/models/card_model.dart';
import 'package:mundo_puzzle_flutter/services/game_service.dart';
import 'package:mundo_puzzle_flutter/services/question_generator.dart';
import 'package:mundo_puzzle_flutter/widgets/puzzle_grid_widget.dart';

/// Pantalla mejorada del juego con puzzle visual
class GameScreenV2 extends StatefulWidget {
  final CardModel card;
  final String worldId;

  const GameScreenV2({
    Key? key,
    required this.card,
    required this.worldId,
  }) : super(key: key);

  @override
  State<GameScreenV2> createState() => _GameScreenV2State();
}

class _GameScreenV2State extends State<GameScreenV2> {
  late GameService _gameService;
  late List<Question> _questions;
  late CardProgress _cardProgress;

  int _currentQuestionIndex = 0;
  bool _isAnswered = false;
  bool _isCorrect = false;
  int _selectedAnswerIndex = -1;

  @override
  void initState() {
    super.initState();
    _gameService = GameService.instance;
    _cardProgress = _gameService.getCardProgress(widget.card.id) ??
        CardProgress(cardId: widget.card.id);

    // Verifica si la carta está bloqueada
    if (_cardProgress.isBlocked()) {
      _showBlockedDialog();
      return;
    }

    // Genera preguntas según la edad del jugador
    _questions = QuestionGenerator.generateQuestionsForCard(
      _gameService.playerAge,
      widget.card.id,
      count: 12,
    );
  }

  void _showBlockedDialog() {
    final remainingMinutes = _cardProgress.getBlockedTimeRemaining();
    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Carta Bloqueada 🔒'),
        content: Text(
          'Has fallado 3 veces en esta carta. Vuelve en $hours horas y $minutes minutos para intentar de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  void _answerQuestion(int selectedIndex) {
    if (_isAnswered) return;

    final question = _questions[_currentQuestionIndex];
    final correct = question.isCorrect(selectedIndex);

    setState(() {
      _isAnswered = true;
      _isCorrect = correct;
      _selectedAnswerIndex = selectedIndex;
    });

    if (correct) {
      _cardProgress.incrementCorrectStreak();
      _cardProgress.addPuzzlePiece();
      _cardProgress.resetFailCount();

      // Verifica si se desbloqueó una carta dorada
      if (_cardProgress.shouldUnlockLegendary()) {
        _showLegendaryUnlockedDialog();
      }

      // Espera un poco antes de pasar a la siguiente pregunta
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted) {
          if (_currentQuestionIndex < _questions.length - 1) {
            setState(() {
              _currentQuestionIndex++;
              _isAnswered = false;
              _selectedAnswerIndex = -1;
            });
          } else {
            _showVictoryDialog();
          }
        }
      });
    } else {
      _cardProgress.incrementFailCount();
      _cardProgress.resetCorrectStreak();

      // Verifica si la carta se bloqueó
      if (_cardProgress.isBlocked()) {
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            _showBlockedAfterFailDialog();
          }
        });
      } else {
        // Muestra error y espera antes de volver
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    }
  }

  void _showLegendaryUnlockedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¡Carta Dorada Desbloqueada! ✨'),
        content: const Text(
          '¡Felicidades! Has respondido 10 preguntas correctas seguidas y desbloqueaste una carta legendaria.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  void _showBlockedAfterFailDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Carta Bloqueada 🔒'),
        content: const Text(
          'Has fallado 3 veces en esta carta. Vuelve en 24 horas para intentar de nuevo.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('¡Carta Completada! 🎉'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Mostrar la imagen completa del personaje
            if (widget.card.imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.card.imageUrl,
                  height: 200,
                  width: 200,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 200,
                      width: 200,
                      color: Colors.purple.shade100,
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.card.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.card.description,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cardProgress.isBlocked()) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Carta Bloqueada'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock, size: 80, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Esta carta está bloqueada',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Vuelve en ${_cardProgress.getBlockedTimeRemaining()} minutos',
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final progress = ((_currentQuestionIndex + 1) / _questions.length * 100).toInt();

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.card.name} - Pregunta ${_currentQuestionIndex + 1}/12'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Barra de progreso
              LinearProgressIndicator(
                value: progress / 100,
                minHeight: 8,
                backgroundColor: Colors.grey.shade300,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.purple.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Progreso: $progress%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Puzzle visual
              AnimatedPuzzleWidget(
                imageUrl: widget.card.imageUrl,
                revealedPieces: _cardProgress.unlockedPieces,
                size: 280,
              ),
              const SizedBox(height: 24),

              // Información de fallos
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade700),
                    const SizedBox(width: 8),
                    Text(
                      'Fallos: ${_cardProgress.failCount}/3',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Pregunta
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  question.text,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 24),

              // Opciones de respuesta
              ...List.generate(
                question.options.length,
                (index) => _buildAnswerButton(
                  index,
                  question.options[index],
                  question.correctAnswerIndex,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerButton(
    int index,
    String answer,
    int correctIndex,
  ) {
    bool isSelected = _selectedAnswerIndex == index;
    bool isCorrectAnswer = index == correctIndex;
    bool showResult = _isAnswered;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black;

    if (showResult) {
      if (isSelected) {
        if (_isCorrect) {
          backgroundColor = Colors.green.shade100;
          borderColor = Colors.green;
          textColor = Colors.green.shade900;
        } else {
          backgroundColor = Colors.red.shade100;
          borderColor = Colors.red;
          textColor = Colors.red.shade900;
        }
      } else if (isCorrectAnswer && !_isCorrect) {
        backgroundColor = Colors.green.shade100;
        borderColor = Colors.green;
        textColor = Colors.green.shade900;
      }
    } else if (isSelected) {
      backgroundColor = Colors.purple.shade100;
      borderColor = Colors.purple;
      textColor = Colors.purple.shade900;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton(
        onPressed: _isAnswered ? null : () => _answerQuestion(index),
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          side: BorderSide(color: borderColor, width: 2),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          answer,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
