import 'package:flutter/material.dart';
import 'package:mundo_puzzle_flutter/models/card_model.dart';
import 'package:mundo_puzzle_flutter/services/game_service.dart';
import 'package:mundo_puzzle_flutter/screens/game_screen_v2.dart';

class WorldScreen extends StatefulWidget {
  final World world;

  const WorldScreen({Key? key, required this.world}) : super(key: key);

  @override
  State<WorldScreen> createState() => _WorldScreenState();
}

class _WorldScreenState extends State<WorldScreen> {
  final GameService _gameService = GameService();

  @override
  Widget build(BuildContext context) {
    final cards = _gameService.getCardsFromWorld(widget.world.id);
    final unlockedCards = _gameService.getUnlockedCardsFromWorld(widget.world.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.world.name),
        backgroundColor: Colors.purple.shade600,
      ),
      body: Column(
        children: [
          // Header con información del mundo
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.purple.shade50,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personaje: ${widget.world.character}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.world.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cartas desbloqueadas: ${unlockedCards.length}/${cards.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${((unlockedCards.length / cards.length) * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: unlockedCards.length / cards.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.green.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Grid de cartas
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.75,
              ),
              itemCount: cards.length,
              itemBuilder: (context, index) {
                final card = cards[index];
                final progress = _gameService.getCardProgress(card.id);
                final isUnlocked = progress != null && progress.isUnlocked;

                return _buildCardTile(
                  card: card,
                  isUnlocked: isUnlocked,
                  unlockedPieces: progress?.unlockedPieces ?? 0,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => GameScreenV2(card: card, worldId: widget.world.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardTile({
    required CardModel card,
    required bool isUnlocked,
    required int unlockedPieces,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _getRarityColor(card.rarity),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Fondo de la carta con imagen
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey.shade200,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo
                  if (card.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        card.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey.shade300,
                            child: const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            ),
                          );
                        },
                      ),
                    )
                  else
                    Container(
                      color: Colors.grey.shade300,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
                  // Overlay oscuro para cartas bloqueadas
                  if (!isUnlocked)
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  // Contenido superpuesto
                  Center(
                    child: isUnlocked
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle,
                                size: 40,
                                color: Colors.green.shade400,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                card.name,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.lock,
                                size: 40,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '$unlockedPieces/12',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ),
            // Indicador de rareza
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: _getRarityColor(card.rarity),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _getRarityLabel(card.rarity),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Indicador de progreso del puzzle
            if (!isUnlocked)
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: unlockedPieces / 12,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade400,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getRarityColor(card.rarity),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getRarityColor(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return Colors.grey;
      case CardRarity.special:
        return Colors.blue;
      case CardRarity.legendary:
        return Colors.amber;
    }
  }

  String _getRarityLabel(CardRarity rarity) {
    switch (rarity) {
      case CardRarity.common:
        return 'Común';
      case CardRarity.special:
        return 'Especial';
      case CardRarity.legendary:
        return 'Dorada';
    }
  }
}
