import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../service/models/market_model.dart';
import '../shared/widgets/portfolioStockCard.dart';

class Camera extends StatelessWidget {
  Camera(this.listType);
  final String listType;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text(
            listType,
            style: new TextStyle(color: const Color(0xFFFFFFFF)),
          ),
          titleSpacing: -1.0,
          leading:
              new IconButton(icon: const Icon(Icons.search), onPressed: () {}),
          actions: <Widget>[
            new IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
          ],
        ),
        endDrawer: Container(
            width: 200,
            child: Drawer(
                child: ListView(children: <Widget>[
              ListTile(
                leading: Icon(Icons.contact_mail),
                title: Text('Add Contact'),
                onTap: () {
                  Navigator.pushNamed(context, '/contact');
                },
              ),
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Transactions'),
                onTap: () {
                  Navigator.pushNamed(context, '/transactionsList');
                },
              ),
            ]))),
        body: StreamBuilder(
          stream: Firestore.instance.collection('Stock').snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Text('Loading...');
            return new ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) {
                  var markdata = snapshot.data.documents[index];
                  return PortfolioStockCard(
                      data: Stock(
                          id: markdata.documentID,
                          symbol: markdata['symbol'],
                          name: markdata['name'],
                          high: markdata['high'],
                          low: markdata['low'],
                          chg: markdata['chg'],
                          chgPercent: markdata['chgPercent'],
                          rating: markdata['rating']));
                });
          },
        ));
  }
}
