import 'package:flutter/material.dart';
import 'package:mundo_puzzle_flutter/models/card_model.dart';
import 'package:mundo_puzzle_flutter/services/game_service.dart';
import 'package:mundo_puzzle_flutter/widgets/puzzle_widget.dart';

class GameScreen extends StatefulWidget {
  final Card card;

  const GameScreen({Key? key, required this.card}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final GameService _gameService = GameService();
  late CardProgress _cardProgress;
  int _currentQuestionIndex = 0;
  int _selectedAnswerIndex = -1;
  bool _answered = false;
  bool _isCorrect = false;
  int _correctAnswersInARow = 0;

  @override
  void initState() {
    super.initState();
    _initializeProgress();
  }

  void _initializeProgress() {
    _cardProgress = _gameService.getCardProgress(widget.card.id) ??
        CardProgress(cardId: widget.card.id);
    _correctAnswersInARow = _gameService.getCurrentCorrectStreak();
  }

  void _selectAnswer(int index) {
    if (_answered) return;

    setState(() {
      _selectedAnswerIndex = index;
      _answered = true;
      _isCorrect = widget.card.questions[_currentQuestionIndex]
          .isCorrect(index);

      if (_isCorrect) {
        _correctAnswersInARow++;
        _gameService.processCorrectAnswer(widget.card.id);
      } else {
        _correctAnswersInARow = 0;
        _gameService.processIncorrectAnswer(widget.card.id);
      }
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < widget.card.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswerIndex = -1;
        _answered = false;
        _isCorrect = false;
      });
    } else {
      _showCardCompleteDialog();
    }
  }

  void _showCardCompleteDialog() {
    final isCardUnlocked = _cardProgress.isUnlocked;
    final isLegendary = _gameService.shouldUnlockLegendary() &&
        widget.card.rarity == CardRarity.legendary;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(
          isCardUnlocked ? '¡Carta Desbloqueada!' : 'Progreso Guardado',
          style: TextStyle(
            color: isCardUnlocked ? Colors.green.shade600 : Colors.blue.shade600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isCardUnlocked ? Icons.check_circle : Icons.save,
              size: 64,
              color: isCardUnlocked ? Colors.green.shade600 : Colors.blue.shade600,
            ),
            const SizedBox(height: 16),
            Text(
              isCardUnlocked
                  ? '¡Felicidades! Has desbloqueado la carta ${widget.card.id}'
                  : 'Has completado ${_cardProgress.unlockedPieces} piezas del puzzle',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            if (isLegendary) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade600, width: 2),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber.shade600,
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '¡Carta Dorada Desbloqueada! (10 respuestas correctas seguidas)',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              'Racha actual: $_correctAnswersInARow respuestas correctas seguidas',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Volver'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.card.questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / widget.card.questions.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.card.id),
        backgroundColor: Colors.purple.shade600,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Barra de progreso
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Pregunta ${_currentQuestionIndex + 1}/${widget.card.questions.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Racha: $_correctAnswersInARow',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _correctAnswersInARow >= 10
                            ? Colors.amber.shade600
                            : Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.purple.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Puzzle visual
          Container(
            padding: const EdgeInsets.all(16),
            child: PuzzleWidget(
              unlockedPieces: _cardProgress.unlockedPieces,
              totalPieces: 12,
            ),
          ),
          // Pregunta
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.text,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Opciones de respuesta
                  ...List.generate(
                    question.options.length,
                    (index) => _buildAnswerButton(
                      index: index,
                      option: question.options[index],
                      isSelected: _selectedAnswerIndex == index,
                      isCorrect: _isCorrect && _selectedAnswerIndex == index,
                      isWrong: _answered &&
                          _selectedAnswerIndex == index &&
                          !_isCorrect,
                      showCorrectAnswer: _answered &&
                          index == question.correctAnswerIndex,
                      onTap: () => _selectAnswer(index),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Botón siguiente
          if (_answered)
            Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isCorrect
                        ? Colors.green.shade600
                        : Colors.orange.shade600,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    _isCorrect ? '¡Correcto! Siguiente' : 'Siguiente',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAnswerButton({
    required int index,
    required String option,
    required bool isSelected,
    required bool isCorrect,
    required bool isWrong,
    required bool showCorrectAnswer,
    required VoidCallback onTap,
  }) {
    Color backgroundColor = Colors.white;
    Color borderColor = Colors.grey.shade300;
    Color textColor = Colors.black;

    if (isCorrect) {
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green.shade600;
      textColor = Colors.green.shade900;
    } else if (isWrong) {
      backgroundColor = Colors.red.shade100;
      borderColor = Colors.red.shade600;
      textColor = Colors.red.shade900;
    } else if (showCorrectAnswer) {
      backgroundColor = Colors.green.shade100;
      borderColor = Colors.green.shade600;
      textColor = Colors.green.shade900;
    } else if (isSelected && !_answered) {
      backgroundColor = Colors.blue.shade100;
      borderColor = Colors.blue.shade600;
      textColor = Colors.blue.shade900;
    }

    return GestureDetector(
      onTap: _answered ? null : onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: borderColor, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: borderColor, width: 2),
                color: isCorrect || showCorrectAnswer
                    ? Colors.green.shade600
                    : isWrong
                        ? Colors.red.shade600
                        : Colors.transparent,
              ),
              child: isCorrect || showCorrectAnswer
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 16,
                    )
                  : isWrong
                      ? const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 16,
                        )
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
