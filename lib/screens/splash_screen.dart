import 'package:flutter/material.dart';
import 'dart:async';
import 'package:mundo_puzzle_flutter/screens/home_screen.dart';
import 'package:mundo_puzzle_flutter/services/game_service.dart';
import 'package:mundo_puzzle_flutter/services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeGame();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _initializeGame() async {
    final gameService = GameService();
    final storageService = StorageService();
    
    // Inicializar servicios
    await gameService.initialize();
    await storageService.initialize();

    // Esperar a que terminen las animaciones antes de navegar
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        // Verificar si el jugador ya fue configurado
        if (storageService.hasPlayerData()) {
          final name = storageService.getPlayerName();
          final age = storageService.getPlayerAge();
          
          // Inicializar el juego con los datos guardados
          gameService.initializePlayer(name!, age!);
          Navigator.of(context).pushReplacementNamed('/home');
        } else {
          // Ir a la pantalla de configuración
          Navigator.of(context).pushReplacementNamed('/setup');
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade400,
              Colors.purple.shade600,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.extension,
                          size: 80,
                          color: Colors.purple.shade600,
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'MUNDO PUZZLE',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.purple.shade600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Aprende jugando',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              FadeTransition(
                opacity: _fadeAnimation,
                child: const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
