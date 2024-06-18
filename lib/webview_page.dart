import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'page_accueil_widget.dart';


class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
 late final WebViewController _controller;
  int _selectedIndex = 0;
   bool notificationsEnabled = true;

   void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PageAccueilWidget()),
      );
    } else if (index == 1) {
      setState(() {
        notificationsEnabled = !notificationsEnabled;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ticket'),
      ),
      body: WebView(
        initialUrl: 'https://www.guichetbi.com/idapp/$v1',
        onWebViewCreated: (WebViewController webViewController) {
          // _webViewController = webViewController;
          _controller = webViewController;  
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.message),
              label: 'Notifications',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
    );
  }

}
