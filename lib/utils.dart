// utils.dart
import 'package:shared_preferences/shared_preferences.dart';

String v1 = DateTime.now().millisecondsSinceEpoch.toString(); // Variable globale

Future<String> generateUrl() async {
  String notificationUrl = 'https://www.guichetbi.com/idapp/$v1';
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('notificationUrl', notificationUrl);

  return notificationUrl; 
}
