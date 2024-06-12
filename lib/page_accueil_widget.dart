import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'page_accueil_model.dart';

class PageAccueilWidget extends StatefulWidget {
  const PageAccueilWidget({super.key});

  @override
  State<PageAccueilWidget> createState() => _PageAccueilWidgetState();
}

class _PageAccueilWidgetState extends State<PageAccueilWidget> {
  late PageAccueilModel _model;

  final _url = Uri.parse("https://www.guichetbi.com");

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => PageAccueilModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _launchURL() async {
    if (!await launchUrl(_url)) throw 'Could not launch $_url';
  }

  Future<void> scan() async {
    try {
      var barcode = await BarcodeScanner.scan();
      checkingValueAndOpen(barcode.rawContent);
    } on PlatformException catch (e) {
      if (e.code == BarcodeScanner.cameraAccessDenied) {
        showSnackBar('Sorry, will you give me permission to use the camera?');
      } else {
        showSnackBar('Unknown error $e');
      }
    } on FormatException {
      showSnackBar('You pressed the back button before scanning anything.');
    } catch (e) {
      showSnackBar('Unknown error: $e');
    }
  }

  Future<void> checkingValueAndOpen(String url) async {
    if (url.isNotEmpty) {
      if (url.contains("https") || url.contains("http")) {
        if (!await launchUrl(Uri.parse(url))) {
          throw 'Could not launch $url';
        }
      } else {
        showSnackBar('The QR code format is incorrect! Please try another QR code.');
      }
    } else {
      showSnackBar('The QR content is empty!');
    }
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                    onPressed: _launchURL,
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
