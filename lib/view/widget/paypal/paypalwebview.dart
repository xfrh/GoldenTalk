import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PaypalBrowser extends StatefulWidget {
  PaypalBrowser({@required this.paymeUrl});
  final String paymeUrl;
  @override
  _PaypalBrowserState createState() => _PaypalBrowserState();
}

class _PaypalBrowserState extends State<PaypalBrowser> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Award'),
      ),
      body: WebView(
        initialUrl: widget.paymeUrl,
        javascriptMode: JavascriptMode.unrestricted,
      ),
    );
  }
}
