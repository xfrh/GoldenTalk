import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../detailimage_screen.dart';
import 'stocke_detail.dart';

class StockChartScreen extends StatelessWidget {
  static const routeName = '/selectedSymbol';
  String _urltop;
  String _urlbottom;
  @override
  Widget build(BuildContext context) {
    String symbol = ModalRoute.of(context).settings.arguments;
    switch (symbol) {
      case 'XAUUSD':
        _urltop = 'https://www.kitco.com/images/live/gold.gif';
        _urlbottom = 'https://www.kitco.com/images/live/nygold.gif';
        break;
      case 'XAGUSD':
        _urltop = 'https://www.kitco.com/images/live/silver.gif';
        _urlbottom = 'https://www.kitco.com/images/live/nysilver.gif';
        break;
      case 'XPTUSD':
        _urltop = 'https://www.kitco.com/images/live/plati.gif';
        _urlbottom = '';
        break;
      case 'XPDUSD':
        _urltop = 'https://www.kitco.com/images/live/plad.gif';
        _urlbottom = '';
        break;
      case 'XAUSIGNAL':
        _urltop = 'https://d.mamatainfotech.com/all/10M/Gold_10M_Basic.gif';
        _urlbottom =
            'https://d.mamatainfotech.com/all/Daily/GOLD_Daily_Basic.gif';
        break;
    }
    return Scaffold(
        backgroundColor: Colors.black,
        appBar: new AppBar(
          title: new Text(
            symbol,
            style: new TextStyle(color: const Color(0xFFFFFFFF)),
          ),
          titleSpacing: -1.0,
          leading: new IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              }),
        ),
        body: Container(
            child: ListView(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                    child: GestureDetector(
                        onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => StockDetialChat(
                                            chatUrl: _urltop,
                                          )))
                            },
                        child: Hero(
                            tag: 'imageHero_top',
                            child: CachedNetworkImage(
                              imageUrl: _urltop,
                              placeholder: (context, builder) =>
                                  new CircularProgressIndicator(),
                              errorWidget: (context, string, dynamic) =>
                                  new Icon(Icons.error),
                            )))),
              ],
            ),
            _urlbottom == ''
                ? Container()
                : Row(
                    children: <Widget>[
                      Expanded(
                          child: GestureDetector(
                              onTap: () => {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                StockDetialChat(
                                                  chatUrl: _urlbottom,
                                                )))
                                  },
                              child: Hero(
                                  tag: 'imageHero_bottom',
                                  child: CachedNetworkImage(
                                    imageUrl: _urlbottom,
                                    placeholder: (context, builder) =>
                                        new CircularProgressIndicator(),
                                    errorWidget: (context, string, dynamic) =>
                                        new Icon(Icons.error),
                                  )))),
                    ],
                  )
          ],
        )));
  }
}
