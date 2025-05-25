import 'package:flutter/material.dart';
import 'package:estuda_ai_novo/screens/home_screen.dart';
import 'screens/home_screen.dart';
import 'screens/adicionar_materia_screen.dart';
import 'screens/resumo_screen.dart';
import 'screens/desempenho_screen.dart';


void main() {
  runApp(const EstudaAiApp());
}

class EstudaAiApp extends StatelessWidget {
  const EstudaAiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estuda Aí',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2196F3),
        scaffoldBackgroundColor: const Color(0xFFF5F5F5),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}