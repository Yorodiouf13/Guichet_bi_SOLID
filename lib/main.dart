import 'package:flutter/material.dart';
import 'package:appflutter/utils.dart';
import 'page_accueil_widget.dart';
import 'webview_page.dart';

void main() => runApp(const App());

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Smart Queue',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
       initialRoute: '/', // Route initiale
      routes: {
        '/': (context) => const PageAccueilWidget(), // Page d'accueil
        '/webview': (context) => WebViewPage(notificationUrl: notificationUrl), // Nouvelle route pour WebViewPage
  },
  );
  }
}
