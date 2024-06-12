import 'package:flutter/material.dart';
import 'page_accueil_widget.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Smart Queue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: PageAccueilWidget(),
    );
  }
}
