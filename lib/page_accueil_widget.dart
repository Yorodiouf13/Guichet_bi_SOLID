import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'page_accueil_model.dart';
export 'page_accueil_model.dart';
import 'webview_page.dart';
import 'package:appflutter/utils.dart';

String tokennotificationUrl = 'https://www.guichetbi.com/tokennotification/$v1';

class PageAccueilWidget extends StatefulWidget {
  const PageAccueilWidget({super.key});

  @override
  State<PageAccueilWidget> createState() => _PageAccueilWidgetState();
}

class _PageAccueilWidgetState extends State<PageAccueilWidget> {
  late PageAccueilModel _model;
  late Timer _timer;
  bool notificationsEnabled = true;

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String branch = '';
  String etablissement = '';
  String token = '';
  String department = '';
  String currentToken = '';
  String encryptedToken = '';
  int userTokenId = 0;
  int currentTokenId = 0;
  int nombreTicketPrecedent = 0;

  // int _selectedIndex = 0;

  bool notification10Sent = false;
  bool notification0Sent = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageAccueilModel());
    _initNotifications();
     _loadNotificationState();
     _checkFirstRun();
    _startTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _model.dispose();
    super.dispose();
  }

   Future<void> _initNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _checkFirstRun() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

    if (isFirstRun) {
      _showNotificationPermissionDialog();
      await prefs.setBool('isFirstRun', false);
    }
  }

  void _showNotificationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Notifications'),
          content: Text('L\'application doit vous envoyer des notifications. Voulez-vous les activer ?'),
          actions: <Widget>[
            TextButton(
              child: Text('Non'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Oui'),
              onPressed: () {
                _requestNotificationPermissions();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

   Future<void> _requestNotificationPermissions() async {
    // Demandez la permission d'envoyer des notifications sur iOS
    final IOSFlutterLocalNotificationsPlugin? iosImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();

    if (iosImplementation != null) {
      await iosImplementation.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
    }

    // Pour Android, la permission est déjà gérée dans les paramètres de l'application
    // Vous pouvez ajouter des configurations spécifiques si nécessaire
  }

   Future<void> _loadNotificationState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notification10Sent = prefs.getBool('notification10Sent') ?? false;
      notification0Sent = prefs.getBool('notification5Sent') ?? false;
    });
  }

  Future<void> _saveNotificationState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('notification10Sent', notification10Sent);
    prefs.setBool('notification5Sent', notification0Sent);
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (notificationsEnabled) {
        _checkQueueStatus();
      }
    });
  }

  void _checkQueueStatus() async {
    try {
      final response = await http.get(Uri.parse(tokennotificationUrl));
      print(response.body);
      print('tokennotificationUrl: $tokennotificationUrl');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _extractDataFromResponse(data);
        print('Nombre de tickets précédents: $nombreTicketPrecedent');
        print('encryptedToken: $encryptedToken');

        if (nombreTicketPrecedent == 10) {
          _showNotification(10);
          notification10Sent = true;
          _saveNotificationState();
        } else if (nombreTicketPrecedent == 5) {
          _showNotification(5);
           notification0Sent = true;
          _saveNotificationState();
        }

      } else {
        print('Failed to load queue status');
      }
    } catch (e) {
      print('Error fetching queue status: $e');
    }
  }

  void _extractDataFromResponse(Map<String, dynamic> data) {
    setState(() {
      branch = data['branch'];
      etablissement = data['etablissement'];
      token = data['token'];
      department = data['department'];
      currentToken = data['current_token'];
      encryptedToken = data['encryptedtoken'];
      userTokenId = data['userTokenId'];
      currentTokenId = data['currentTokenId'];
      nombreTicketPrecedent = data['nombreTicketPrecedent'];
    });
  }


  Future<void> _generateTokenNumberUrl() async {
    String url = 'https://www.guichetbi.com/token/number/$encryptedToken';
    print('url: $url');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(initialUrl: url), 
      ),
    );
  }

  Future<void> _showNotification(int peopleAhead) async {
    String message = 'Il reste $peopleAhead personnes avant votre passage.';
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'your_channel_id',
      'your_channel_name',
      channelDescription: 'your_channel_description',
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Notification',
      message,
      platformChannelSpecifics,
      payload: 'item x',
    );
  }

  Future<void> scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      checkingValueAndOpen(barcode.rawContent);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        showSnackBar('Désolé, puis-je utiliser la caméra ?');
      } else {
        showSnackBar('Erreur inconnue $e');
      }
    } on FormatException {
      showSnackBar('Vous avez appuyé sur le bouton retour avant de scanner quoi que ce soit.');
    } catch (e) {
      showSnackBar('Erreur inconnue: $e');
    }
  }

  Future<void> checkingValueAndOpen(String url) async {
    if (url.isNotEmpty) {
      if (url.contains("https") || url.contains("http")) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewPage(initialUrl: url), // Passer l'URL à WebViewPage
          ),
        );
      } else {
        showSnackBar('Le format du QR code est incorrect ! Veuillez essayer un autre QR code.');
      }
    } else {
      showSnackBar('Le contenu du QR est vide !');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // void _onItemTapped(int index) {
  //   setState(() {
  //     _selectedIndex = index;
  //   });
  //   if (index == 0) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (context) => const PageAccueilWidget()),
  //     );
  //   } 
  // }

  Future<void> _navigateToWebView() async {
    String url = await generateUrl(); // Utiliser generateUrl pour obtenir l'URL
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WebViewPage(initialUrl: url), // Passer l'URL à WebViewPage
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_model.unfocusNode.canRequestFocus) {
          FocusScope.of(context).requestFocus(_model.unfocusNode);
        } else {
          FocusScope.of(context).unfocus();
        }
      },
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: const Color(0xFF343A40),
        body: SafeArea(
          top: true,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0, 30, 0, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      'https://www.guichetbi.com/logo/logo.png',
                      width: 350,
                      height: 70,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 170, 16, 0),
                  child: ElevatedButton(
                    onPressed: scan,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF3987EF),
                      minimumSize: const Size(265, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(37),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    child: const Text('Scan'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _navigateToWebView,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF3987EF),
                      minimumSize: const Size(265, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(37),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    child: const Text('Ticket'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    onPressed: _generateTokenNumberUrl,
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: const Color(0xFF3987EF),
                      minimumSize: const Size(265, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(37),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: 'Outfit',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                      ),
                    ),
                    child: const Text('Suivi du ticket'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
