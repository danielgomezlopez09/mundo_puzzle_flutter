import 'package:flutter/material.dart';
import 'package:mundo_puzzle_flutter/screens/splash_screen.dart';
import 'package:mundo_puzzle_flutter/screens/home_screen.dart';
import 'package:mundo_puzzle_flutter/screens/setup_screen.dart';

void main() {
  runApp(const MundoPuzzleApp());
}

class MundoPuzzleApp extends StatelessWidget {
  const MundoPuzzleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Mundo Puzzle',
      theme: ThemeData(
        primarySwatch: Colors.purple,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.purple,
          brightness: Brightness.light,
        ),
      ),
      home: const SplashScreen(),
      routes: {
        '/setup': (context) => const SetupScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}
