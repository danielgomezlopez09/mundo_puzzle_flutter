import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Widget que muestra un puzzle de 12 piezas con partes reveladas
class PuzzleGridWidget extends StatelessWidget {
  /// URL de la imagen completa
  final String imageUrl;

  /// Número de piezas reveladas (0-12)
  final int revealedPieces;

  /// Tamaño del widget
  final double size;

  const PuzzleGridWidget({
    Key? key,
    required this.imageUrl,
    required this.revealedPieces,
    this.size = 300,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Grid de 4x3 = 12 piezas
    const int rows = 3;
    const int cols = 4;
    final pieceSize = size / cols;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey.shade200,
      ),
      child: Stack(
        children: [
          // Fondo gris para piezas no reveladas
          Container(
            color: Colors.grey.shade300,
          ),
          // Grid de piezas
          GridView.builder(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
            ),
            itemCount: rows * cols,
            itemBuilder: (context, index) {
              final isRevealed = index < revealedPieces;
              return _buildPuzzlePiece(
                index: index,
                isRevealed: isRevealed,
                pieceSize: pieceSize,
                rows: rows,
                cols: cols,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPuzzlePiece({
    required int index,
    required bool isRevealed,
    required double pieceSize,
    required int rows,
    required int cols,
  }) {
    final row = index ~/ cols;
    final col = index % cols;

    if (!isRevealed) {
      // Pieza no revelada: mostrar símbolo de interrogación
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade400, width: 1),
          color: Colors.grey.shade300,
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              fontSize: pieceSize * 0.4,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }

    // Pieza revelada: mostrar parte de la imagen
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.purple.shade200, width: 1),
      ),
      child: ClipRRect(
        child: Stack(
          children: [
            // Imagen con offset para mostrar solo la parte correspondiente
            Positioned(
              left: -col * pieceSize,
              top: -row * pieceSize,
              width: size,
              height: size,
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.purple.shade100,
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            // Efecto de brillo para piezas reveladas
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Colors.white.withValues(alpha: 0.3),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget mejorado que muestra el puzzle con animación al revelar piezas
class AnimatedPuzzleWidget extends StatefulWidget {
  final String imageUrl;
  final int revealedPieces;
  final double size;
  final VoidCallback? onPuzzleComplete;

  const AnimatedPuzzleWidget({
    Key? key,
    required this.imageUrl,
    required this.revealedPieces,
    this.size = 300,
    this.onPuzzleComplete,
  }) : super(key: key);

  @override
  State<AnimatedPuzzleWidget> createState() => _AnimatedPuzzleWidgetState();
}

class _AnimatedPuzzleWidgetState extends State<AnimatedPuzzleWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );

    _scaleController.forward();

    // Si se completó el puzzle, mostrar animación especial
    if (widget.revealedPieces == 12) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          widget.onPuzzleComplete?.call();
        }
      });
    }
  }

  @override
  void didUpdateWidget(AnimatedPuzzleWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.revealedPieces > oldWidget.revealedPieces) {
      _scaleController.reset();
      _scaleController.forward();
    }
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: PuzzleGridWidget(
        imageUrl: widget.imageUrl,
        revealedPieces: widget.revealedPieces,
        size: widget.size,
      ),
    );
  }
}
