import 'package:flutter/material.dart';
import 'page_accueil_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gestion des Examens',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PageAccueilWidget(),
    );
  }
}
