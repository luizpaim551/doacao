import 'package:flutter/material.dart';

import 'screens/home_screen.dart';

void main() {
  runApp(const ListaDoacaoApp());
}

/// Aplicativo "Lista de Doação de Roupas".
///
/// Sistema para organização de roupas destinadas à doação, com cadastro,
/// edição, exclusão, listagem, categorias e busca. Uso individual, sem
/// autenticação, com persistência local (conforme Documento de Visão - 2026/1).
class ListaDoacaoApp extends StatelessWidget {
  const ListaDoacaoApp({super.key});

  @override
  Widget build(BuildContext context) {
    final esquemaCores = ColorScheme.fromSeed(
      seedColor: const Color(0xFF2E7D32),
      brightness: Brightness.light,
    );

    return MaterialApp(
      title: 'Lista de Doação de Roupas',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: esquemaCores,
        appBarTheme: AppBarTheme(
          backgroundColor: esquemaCores.primary,
          foregroundColor: esquemaCores.onPrimary,
          centerTitle: false,
        ),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          filled: true,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
