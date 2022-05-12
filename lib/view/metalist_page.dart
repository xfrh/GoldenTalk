import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../service/locator.dart';
import '../service/market_service.dart';
import '../view/widget/news/webview_page.dart';
import '../view/widget/stock_chat.dart';
import 'package:typicons_flutter/typicons_flutter.dart';

class MetalistPage extends StatefulWidget {
  MetalistPage(this.listType);
  final String listType;

  @override
  _MetalistPageState createState() => _MetalistPageState();
}

class _MetalistPageState extends State<MetalistPage> {
  final _marketService = locator<MarketService>();
  bool _isUpdate = false;
  Timer _timer;
  @override
  void initState() {
    // TODO: implement initState
    _timer = Timer.periodic(Duration(milliseconds: 5000), (timer) {
      _marketService.fetchprices().then((value) {
        setState(() {
          _isUpdate = value;
        });
      });
    });

    super.initState();
  }

  String getLastNight() {
    var formatter = new DateFormat('yyyy-MM-dd');
    var now = new DateTime.now();
    var yesterday = new DateTime(now.year, now.month, now.day - 1, 6, 30);
    final weekday = yesterday.weekday;
    if (weekday == 6)
      yesterday = new DateTime(now.year, now.month, now.day - 2, 6, 30);
    if (weekday == 7)
      yesterday = new DateTime(now.year, now.month, now.day - 3, 6, 30);
    return formatter.format(yesterday);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: new AppBar(
          title: new Text(
            widget.listType,
            style: new TextStyle(color: const Color(0xFFFFFFFF)),
          ),
          titleSpacing: -1.0,
          leading:
              new IconButton(icon: const Icon(Icons.search), onPressed: () {}),
        ),
        endDrawer: new Drawer(
            child: new ListView(
          children: <Widget>[
            new ListTile(
              leading: Icon(Typicons.news),
              title: new Text('Global News'),
              onTap: () async {
                Navigator.pushNamed(
                  context,
                  WebViewPage.routeName,
                  arguments: 'Global News',
                );
              },
            ),
            new ListTile(
              leading: Icon(Typicons.chart_area),
              title: new Text('Market News'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  WebViewPage.routeName,
                  arguments: 'Market News',
                );
              },
            ),
            new ListTile(
              leading: Icon(Typicons.social_twitter),
              title: new Text('Street Talks'),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  WebViewPage.routeName,
                  arguments: 'Street Talks',
                );
              },
            ),
            new ListTile(
              leading: Icon(Typicons.warning_outline),
              title: new Text('Buy & Sell Signal'),
              onTap: () {
                Navigator.pushNamed(context, StockChartScreen.routeName,
                    arguments: 'XAUSIGNAL');
              },
            ),
          ],
        )),
        body: Container(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: ListView.builder(
                    itemCount: _marketService.activelst.length,
                    itemBuilder: (context, index) {
                      return Container(
                        padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        height: 220,
                        width: double.maxFinite,
                        child: Card(
                          elevation: 5,
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                    width: 2.0, color: Colors.grey[50]),
                              ),
                              color: Colors.white,
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(7),
                              child: Stack(children: <Widget>[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: Stack(
                                    children: <Widget>[
                                      Padding(
                                          padding: const EdgeInsets.only(
                                              left: 10, top: 5),
                                          child: Column(
                                            children: <Widget>[
                                              Row(
                                                children: <Widget>[
                                                  cryptoNameSymbol(
                                                      _marketService
                                                          .activelst[index]),
                                                  Spacer(),
                                                  cryptoChange(_marketService
                                                      .activelst[index]),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  changeIcon(_marketService
                                                      .activelst[index]),
                                                  SizedBox(
                                                    width: 20,
                                                  )
                                                ],
                                              ),
                                              Row(
                                                children: <Widget>[
                                                  cryptoAmount(_marketService
                                                      .activelst[index]),
                                                  Spacer(),
                                                  addbutton(_marketService
                                                      .activelst[index]),
                                                  SizedBox(
                                                    width: 20,
                                                  )
                                                ],
                                              )
                                            ],
                                          ))
                                    ],
                                  ),
                                ),
                              ]),
                            ),
                          ),
                        ),
                      );
                    }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget cryptoIcon(data) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0),
      child: Align(
          alignment: Alignment.centerLeft,
          child: Icon(
            Icons.money_off,
            color: Colors.green,
            size: 40,
          )),
    );
  }

  String _getNamefromSymbol(String code) {
    switch (code) {
      case "XAU":
        return "Gold";
      case "XAG":
        return "Silver";
      case "XPT":
        return "Platinum";
      case "XPD":
        return "Palladium";
      case "XRH":
        return "Rhodium";
      case "RUTH":
        return "Ruthenium";
    }
  }

  Widget cryptoNameSymbol(data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: RichText(
        text: TextSpan(
          text: '${data.symbol}',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.black, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
                text: '\n${data.name}',
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget cryptoChange(data) {
    //  if (data.change == 0) return Container();

    return Align(
      alignment: Alignment.topRight,
      child: RichText(
        text: TextSpan(
          text: ' ${data.change.toStringAsFixed(3)}',
          style: TextStyle(
              fontWeight: FontWeight.bold, color: Colors.green, fontSize: 20),
          children: <TextSpan>[
            TextSpan(
                text: '\n ${(data.changepct * 100).toStringAsFixed(2)}%',
                style: TextStyle(
                    color: Colors.indigoAccent,
                    fontSize: 15,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget addbutton(data) {
    return Align(
        alignment: Alignment.topRight,
        child: FlatButton(
          child: Text(
            "view chart",
            style: TextStyle(
                color: Colors.indigoAccent,
                fontSize: 15,
                fontWeight: FontWeight.bold),
          ),
          onPressed: () => {
            Navigator.pushNamed(context, StockChartScreen.routeName,
                arguments: data.symbol)
          },
        ));
  }

  Widget changeIcon(data) {
    if (data.change == 0) return Container();
    return Align(
        alignment: Alignment.topRight,
        child: data.change.toString().contains('-')
            ? Icon(
                Typicons.arrow_sorted_down,
                color: Colors.green,
                size: 30,
              )
            : Icon(
                Typicons.arrow_sorted_up,
                color: Colors.red,
                size: 30,
              ));
  }

  Widget cryptoAmount(data) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0),
        child: Row(
          children: <Widget>[
            RichText(
                textAlign: TextAlign.left,
                text: TextSpan(
                  text: '\n${data.bid.toStringAsFixed(3)}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 35,
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget bidAskHLWidget(data) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(right: 10.0),
        child: Column(children: <Widget>[
          Row(children: <Widget>[
            RichText(
                textAlign: TextAlign.right,
                text: TextSpan(
                  text: '\n${data.end_rate.toStringAsFixed(3)}',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 25,
                  ),
                )),
            Text('high'),
          ]),
          Row(
            children: <Widget>[
              RichText(
                  textAlign: TextAlign.right,
                  text: TextSpan(
                    text: '\n${data.end_rate.toStringAsFixed(3)}',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 25,
                    ),
                  )),
              Text('low'),
            ],
          )
        ]),
      ),
    );
  }

  Widget bidAskWidget(data) {
    return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
            padding: const EdgeInsets.only(left: 10.0),
            child: Column(
              children: <Widget>[
                Row(children: <Widget>[
                  RichText(
                      textAlign: TextAlign.left,
                      text: TextSpan(
                        text: '\n${data.end_rate.toStringAsFixed(3)}',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 25,
                        ),
                      )),
                  Text('bid'),
                ]),
                Row(
                  children: <Widget>[
                    RichText(
                        textAlign: TextAlign.left,
                        text: TextSpan(
                          text: '\n${data.end_rate.toStringAsFixed(3)}',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 25,
                          ),
                        )),
                    Text('ask'),
                  ],
                )
              ],
            )));
  }
}
