import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

String v1 = DateTime.now().millisecondsSinceEpoch.toString();
String notificationUrl = 'https://www.guichetbi.com/idapp/$v1';

Future<String> _generateUrl() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('notificationUrl', notificationUrl);

    if (!await launchUrl(Uri.parse(notificationUrl))) {
      throw 'Could not launch $notificationUrl';
    }

    return notificationUrl;
  }

