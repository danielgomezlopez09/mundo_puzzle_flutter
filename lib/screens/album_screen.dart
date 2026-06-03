import 'package:flutter/material.dart';
import 'package:mundo_puzzle_flutter/models/card_model.dart';
import 'package:mundo_puzzle_flutter/services/game_service.dart';

class AlbumScreen extends StatefulWidget {
  const AlbumScreen({Key? key}) : super(key: key);

  @override
  State<AlbumScreen> createState() => _AlbumScreenState();
}

class _AlbumScreenState extends State<AlbumScreen> {
  final GameService _gameService = GameService();
  String _selectedWorldId = 'FC';

  @override
  Widget build(BuildContext context) {
    final worlds = _gameService.getWorlds();
    final selectedWorld = _gameService.getWorld(_selectedWorldId);
    final cardsInWorld = _gameService.getCardsFromWorld(_selectedWorldId);
    final unlockedCards = _gameService.getUnlockedCardsFromWorld(_selectedWorldId);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Álbum de Cartas'),
        backgroundColor: Colors.purple.shade600,
      ),
      body: Column(
        children: [
          // Selector de mundos
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12),
            color: Colors.purple.shade50,
            child: SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                itemCount: worlds.length,
                itemBuilder: (context, index) {
                  final world = worlds[index];
                  final isSelected = world.id == _selectedWorldId;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedWorldId = world.id;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.purple.shade600
                            : Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? Colors.purple.shade600
                              : Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Center(
                        child: Text(
                          world.name,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // Información del mundo
          if (selectedWorld != null)
            Container(
              padding: const EdgeInsets.all(16),
              color: Colors.blue.shade50,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedWorld.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Cartas: ${unlockedCards.length}/${cardsInWorld.length}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    '${((unlockedCards.length / cardsInWorld.length) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green.shade600,
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
              itemCount: cardsInWorld.length,
              itemBuilder: (context, index) {
                final card = cardsInWorld[index];
                final progress = _gameService.getCardProgress(card.id);
                final isUnlocked = progress != null && progress.isUnlocked;

                return _buildCardTile(
                  card: card,
                  isUnlocked: isUnlocked,
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
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getRarityColor(card.rarity),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Fondo de la carta
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: isUnlocked ? Colors.white : Colors.grey.shade300,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isUnlocked ? Icons.check_circle : Icons.lock,
                    size: 40,
                    color: isUnlocked
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    card.id,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
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
          // Indicador especial para cartas doradas
          if (card.rarity == CardRarity.legendary && isUnlocked)
            Positioned(
              top: 8,
              left: 8,
              child: Icon(
                Icons.star,
                color: Colors.amber.shade600,
                size: 24,
              ),
            ),
        ],
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
