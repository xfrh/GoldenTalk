import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StockDetialChat extends StatefulWidget {
  StockDetialChat({@required this.chatUrl});
  final chatUrl;
  @override
  _StockDetialChatState createState() => _StockDetialChatState();
}

class _StockDetialChatState extends State<StockDetialChat> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
  }

  @override
  dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => {Navigator.pop(context)},
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: NetworkImage(widget.chatUrl), fit: BoxFit.cover),
          ),
        ));
  }
}
