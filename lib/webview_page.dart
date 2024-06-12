import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// import 'dart:async';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:webview_flutter_android/webview_flutter_android.dart';

// import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

class WebViewPage extends StatefulWidget {
  const WebViewPage({Key? key}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
 late final WebViewController _controller;
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
  // late Timer _timer;

  // late final WebViewController controller;

  @override
  // void initState() {
  //   super.initState();
  //   var initializationSettingsAndroid =
  //       const AndroidInitializationSettings('@mipmap/ic_launcher');
  //   var initializationSettings = InitializationSettings(
  //       android: initializationSettingsAndroid);
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);

  //   _startTimer();
  // }

  // void _startTimer() {
  //   _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
  //     _checkQueueStatus();
  //   });
  // }

  // Future<void> _checkQueueStatus() async {
  //   final String? notificationUrl = (await _webViewController
  //       .runJavascriptReturningResult('localStorage.getItem("notificationUrl")')) as String?;
  //   if (notificationUrl != null && notificationUrl.isNotEmpty) {
  //     final response = await http.get(Uri.parse(notificationUrl));
  //     if (response.statusCode == 200) {
  //       final data = jsonDecode(response.body);
  //       int peopleAhead = data['nombreTicketPrecedent'];
  //       if (peopleAhead == 10 || peopleAhead == 5) {
  //         _showNotification(peopleAhead);
  //       }
  //     }
  //   }
  // }

  // Future<void> _showNotification(int peopleAhead) async {
  //   const AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     'your_channel_id',
  //     'your_channel_name',
  //     channelDescription: 'your_channel_description',
  //     importance: Importance.max,
  //     priority: Priority.high,
  //     ticker: 'ticker',
  //   );
  //   const NotificationDetails platformChannelSpecifics =
  //       NotificationDetails(android: androidPlatformChannelSpecifics);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     'Notification',
  //     'There are $peopleAhead people ahead of you in the queue.',
  //     platformChannelSpecifics,
  //     payload: 'item x',
  //   );
  // }

  //  JavascriptChannel _flutterJavascriptChannel(BuildContext context) {
  //   return JavascriptChannel(
  //     name: 'Flutter',
  //     onMessageReceived: (JavascriptMessage message) {
  //       // Traitement du message reçu de la page web
  //       String data = message.message;
  //       print('Message from JavaScript: $data');


        // Vous pouvez déclencher des actions spécifiques en fonction du message reçu
        // Par exemple, mettre à jour l'état ou effectuer un appel API
        // Vous pouvez aussi parser un JSON si nécessaire:
  //       // var parsedData = jsonDecode(data);
  //     },
  //   );
  // }

  @override
  // void dispose() {
  //   _timer.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue Status'),
      ),
      body: WebView(
        initialUrl: 'https://www.guichetbi.com/index.html',
        javascriptMode: JavascriptMode.unrestricted,
        javascriptChannels:{JavascriptChannel(name:"Ticket", 
        onMessageReceived: (JavascriptMessage message){
          print(message.message);
        })
        },
        onWebViewCreated: (WebViewController webViewController) {
          // _webViewController = webViewController;
          _controller = webViewController;  
        },
        // javascriptChannels: <JavascriptChannel>{
        //   _flutterJavascriptChannel(context),
        // },
      ),
    );
  }

}
