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
// import 'package:twilio_flutter/twilio_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
// import 'package:permission_handler/permission_handler.dart';



String tokennotificationUrl = 'https://www.guichetbi.com/tokennotification/$v1';
  bool notification10Sent = false;
  bool notification05Sent = false;

class PageAccueilWidget extends StatefulWidget {
  const PageAccueilWidget({super.key});

  @override
  State<PageAccueilWidget> createState() => _PageAccueilWidgetState();
}

class _PageAccueilWidgetState extends State<PageAccueilWidget> {
  late PageAccueilModel _model;
  // late TwilioFlutter twilioFlutter;
  late Timer _timer;
  bool notificationsEnabled = true;


  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final FlutterTts flutterTts = FlutterTts();

  final scaffoldKey = GlobalKey<ScaffoldState>();

  String branch = '';
  String etablissement = '';
  String token = '';
  String department = '';
  String currentToken = '';
  String encryptedToken = '';
  String numeroTelephone= '';
  int userTokenId = 0;
  int currentTokenId = 0;
  int nombreTicketPrecedent = 0;


  // int _selectedIndex = 0;

  // bool notification10Sent = false;
  // bool notification05Sent = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageAccueilModel());
    _initNotifications();
    _loadNotificationState();
        //  _checkFirstRun();
    _startTimer();
    //  twilioFlutter = TwilioFlutter(
    //   accountSid: 'my_account_sid', 
    //   authToken: 'my_auth_token', 
    //   twilioNumber: 'my_twilio_whatsapp_number', 
    // );
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
     await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
        String? payload = notificationResponse.payload;
      if (payload != null) {
        if (payload == 'navigateToSuiviTicket') {
          _generateTokenNumberUrl();
        }
      }
    },
    );
    await _createNotificationChannel();

    
  }

    Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'default_channel',
      'Default Channel',
      description: 'This channel is used for important notifications.',
      importance: Importance.max,
    );

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);
  }

  // Future<void> _checkFirstRun() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   bool isFirstRun = prefs.getBool('isFirstRun') ?? true;

  //   if (isFirstRun) {
  //     // _showNotificationPermissionDialog();
  //     //  _requestNotificationPermissions();
  //     await prefs.setBool('isFirstRun', false);
  //   }
  // }

//  void _showNotificationPermissionDialog() {
//   showDialog(
//     context: context,
//     barrierDismissible: false,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Guichet bi'),
//         content: Text('L\'application doit vous envoyer des notifications. Voulez-vous les activer ?'),
//         actions: <Widget>[
//           TextButton(
//             child: Text('Non'),
//             onPressed: () {
//               setState(() {
//                 notificationsEnabled = false;
//               });
//               Navigator.of(context).pop();
//             },
//           ),
//           TextButton(
//             child: Text('Oui'),
//             onPressed: () {
//               notificationsEnabled = true;
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }


  //  Future<void> _requestNotificationPermissions() async {
  //   // Demandez la permission d'envoyer des notifications sur iOS
  //   final IOSFlutterLocalNotificationsPlugin? iosImplementation =
  //       flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
  //           IOSFlutterLocalNotificationsPlugin>();

  //   if (iosImplementation != null) {
  //     await iosImplementation.requestPermissions(
  //       alert: true,
  //       badge: true,
  //       sound: true,
  //     );

  //     final status = await Permission.notification.status;
  // if (status.isDenied || status.isRestricted) {
  //   if (await Permission.notification.request().isGranted) {
  //     print("Permission Donnée.");
  //     setState(() {
  //       notificationsEnabled = true;
  //     });
  //   } else {
  //     print("Permission refusé.");
  //     setState(() {
  //       notificationsEnabled = false;
  //     });
  //   }
  // } else if (status.isGranted) {
  //   print("Permission déjà donnée.");
  //   setState(() {
  //     notificationsEnabled = true;
  //   });
  // }
  //   }

  // }

   Future<void> _loadNotificationState() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notification10Sent = prefs.getBool('notification10Sent') ?? false;
      notification05Sent = prefs.getBool('notification5Sent') ?? false;
    });
  }

  // Future<void> _saveNotificationState() async {
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   prefs.setBool('notification10Sent', notification10Sent);
  //   prefs.setBool('notification5Sent', notification05Sent);
  // }

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
          print('Data from API: $data'); 
          _extractDataFromResponse(data);
          print('Nombre de tickets précédents: $nombreTicketPrecedent');
          print('encryptedToken: $encryptedToken');
          
         SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      notification10Sent = prefs.getBool('notification10Sent') ?? false;
      notification05Sent = prefs.getBool('notification5Sent') ?? false;
    });

          print('notification10Sent: $notification10Sent');
          print('notification05Sent: $notification05Sent');

          if (nombreTicketPrecedent == 10 && notification10Sent == false) {
            _showNotification(10);
            notification10Sent = true;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('notification10Sent', notification10Sent);


          } else if (nombreTicketPrecedent == 5 && notification05Sent == false) {
            _showNotification(5);
            notification05Sent = true;
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool('notification5Sent', notification05Sent);


          }
          else if (nombreTicketPrecedent > 10) {
        notification10Sent = false;
        prefs.setBool('notification10Sent', notification10Sent);
      } else if (nombreTicketPrecedent > 5) {
        notification05Sent = false;
        prefs.setBool('notification5Sent', notification05Sent);
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
      // numeroTelephone = data['numeroTelephone'];
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
      'default_channel', 
      'Default Channel',
      channelDescription: 'your_channel_description',
      importance: Importance.low,
      priority: Priority.high,
      sound: RawResourceAndroidNotificationSound('notifsilencieuse'),
      ticker: 'ticker',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.show(
      0,
      'Guichet Bi',
      message,
      platformChannelSpecifics,
      payload: 'navigateToSuiviTicket',
    );
    await _speak(message);
  }

  Future<void> _speak(String message) async {
    await flutterTts.setLanguage('fr-FR');
    await flutterTts.setPitch(-10.0);
    await flutterTts.speak(message);
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
