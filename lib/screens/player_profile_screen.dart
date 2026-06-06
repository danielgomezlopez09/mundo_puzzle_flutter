import 'package:flutter/material.dart';
import 'package:mundo_puzzle_flutter/services/game_service.dart';

class PlayerProfileScreen extends StatefulWidget {
  const PlayerProfileScreen({Key? key}) : super(key: key);

  @override
  State<PlayerProfileScreen> createState() => _PlayerProfileScreenState();
}

class _PlayerProfileScreenState extends State<PlayerProfileScreen> {
  final GameService _gameService = GameService();
  late TextEditingController _nameController;
  late int _selectedAge;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _gameService.getPlayerProfile().playerName,
    );
    _selectedAge = _gameService.playerAge;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _updatePlayerName() {
    _gameService.updatePlayerName(_nameController.text);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Nombre actualizado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _showAgeChangeDialog(int newAge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('⚠️ Cambiar Edad'),
        content: const Text(
          'Si cambias tu edad, perderás TODO tu progreso en el juego. '
          '¿Estás seguro de que deseas continuar?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _selectedAge = newAge;
              });
              _gameService.resetProgress();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Edad actualizada y progreso reiniciado'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _gameService.getPlayerProfile();
    final unlockedCards = _gameService.getUnlockedCards();
    final legendaryCards = unlockedCards
        .where((card) => card.rarity.toString() == 'CardRarity.legendary')
        .length;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tarjeta de perfil
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.purple.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.purple.shade600,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  profile.playerName,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Edad: $_selectedAge años',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Maestro Coleccionista',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Sección para cambiar nombre
          Text(
            'Editar Perfil',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Nombre del Jugador',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              prefixIcon: const Icon(Icons.edit),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _updatePlayerName,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Guardar Cambios',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Selector de edad
          Text(
            'Cambiar Edad',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(
                  'Edad: $_selectedAge años',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Slider(
                  value: _selectedAge.toDouble(),
                  min: 7,
                  max: 15,
                  divisions: 8,
                  label: '$_selectedAge',
                  onChanged: (value) {
                    final newAge = value.toInt();
                    if (newAge != _selectedAge) {
                      _showAgeChangeDialog(newAge);
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          // Estadísticas
          Text(
            'Estadísticas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 16),
          _buildStatCard(
            title: 'Cartas Desbloqueadas',
            value: '${profile.totalCardsCollected}/225',
            icon: Icons.collections,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Cartas Doradas',
            value: '$legendaryCards',
            icon: Icons.star,
            color: Colors.amber,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Progreso Total',
            value: '${_gameService.getTotalProgress().toStringAsFixed(1)}%',
            icon: Icons.trending_up,
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildStatCard(
            title: 'Miembro desde',
            value: _formatDate(profile.createdDate),
            icon: Icons.calendar_today,
            color: Colors.purple,
          ),
          const SizedBox(height: 32),
          // Sección de mundos desbloqueados
          Text(
            'Mundos Desbloqueados',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.purple.shade600,
            ),
          ),
          const SizedBox(height: 16),
          ..._gameService.getWorlds().map((world) {
            final isUnlocked = _gameService.isWorldUnlocked(world.id);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isUnlocked ? Colors.green.shade50 : Colors.grey.shade100,
                  border: Border.all(
                    color: isUnlocked ? Colors.green : Colors.grey,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      isUnlocked ? Icons.check_circle : Icons.lock,
                      color: isUnlocked ? Colors.green : Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            world.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            world.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
