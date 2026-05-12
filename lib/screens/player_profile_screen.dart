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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: _gameService.getPlayerProfile().playerName,
    );
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
                  color: Colors.black.withOpacity(0.2),
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
                        color: Colors.black.withOpacity(0.2),
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
                  'Maestro Coleccionista',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
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
            final unlockedInWorld =
                _gameService.getUnlockedCardsFromWorld(world.id);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.green.shade50 : Colors.grey.shade100,
                border: Border.all(
                  color: isUnlocked ? Colors.green.shade300 : Colors.grey.shade300,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        world.name,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isUnlocked
                              ? Colors.green.shade700
                              : Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${unlockedInWorld.length}/45 cartas',
                        style: TextStyle(
                          fontSize: 12,
                          color: isUnlocked
                              ? Colors.green.shade600
                              : Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    isUnlocked ? Icons.lock_open : Icons.lock,
                    color: isUnlocked
                        ? Colors.green.shade600
                        : Colors.grey.shade600,
                    size: 28,
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 32),
          // Botón de zona de padres
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                _showParentZone();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.shade600,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Zona de Padres',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
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
        color: color.withOpacity(0.1),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showParentZone() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Zona de Padres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Resuelve la siguiente operación matemática:',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                '15 × 2 = ?',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Respuesta',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onSubmitted: (value) {
                if (value == '30') {
                  Navigator.pop(context);
                  _showParentOptions();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Respuesta incorrecta'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _showParentOptions() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Opciones de Padres'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Selecciona una opción:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Ver Estadísticas Completas'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Estadísticas: 225 cartas totales, 45 por mundo'),
                    duration: Duration(seconds: 3),
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Reiniciar Progreso'),
              onTap: () {
                Navigator.pop(context);
                _showResetConfirmation();
              },
            ),
            ListTile(
              title: const Text('Información de Seguridad'),
              onTap: () {
                Navigator.pop(context);
                _showSecurityInfo();
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Reiniciar Progreso?'),
        content: const Text(
          'Esto eliminará todo el progreso del jugador. ¿Estás seguro?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              _gameService.resetProgress();
              Navigator.pop(context);
              setState(() {});
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Progreso reiniciado'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
            child: const Text('Reiniciar'),
          ),
        ],
      ),
    );
  }

  void _showSecurityInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Información de Seguridad'),
        content: const Text(
          'Mundo Puzzle es una aplicación educativa segura para niños. '
          'No recopilamos datos personales y toda la información se almacena localmente en el dispositivo.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
}
