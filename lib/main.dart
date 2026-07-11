import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const GenDesignApp());
}

class GenDesignApp extends StatelessWidget {
  const GenDesignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Generative Design Studio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B5BFD),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF3B5BFD),
        brightness: Brightness.dark,
      ),
      home: const HomeScreen(),
    );
  }
}
