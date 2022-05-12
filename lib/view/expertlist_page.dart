import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../service/models/expert_model.dart';
import '../view/widget/expertdetails/expert_details_page.dart';
import 'widget/market/filterstate.dart';

class ExpertsListPage extends StatefulWidget {
  ExpertsListPage(this.pageTitle);
  String pageTitle;

  @override
  _ExpertsListPageState createState() => new _ExpertsListPageState();
}

class _ExpertsListPageState extends State<ExpertsListPage> {
  String _orderby = 'date';
  String _selectedItem;

  @override
  void initState() {
    super.initState();
  }

  void _update(String item) {
    setState(() {
      _selectedItem = item;
    });
  }

  Widget _buildExpertListTile(
      AsyncSnapshot snapshot, DocumentSnapshot document, int index) {
    bool _canAdd = true;
    Expert expert = Expert.fromSnapShot(document);

    if (_selectedItem != null) {
      if (expert.skills.contains(_selectedItem))
        _canAdd = true;
      else
        _canAdd = false;
    }
    return _canAdd
        ? new ListTile(
            onTap: () => _navigateToExpertDetails(expert, index),
            leading: new Hero(
              tag: index,
              child: new CircleAvatar(
                backgroundImage: CachedNetworkImageProvider(expert.avator),
              ),
            ),
            title: new Text(expert.name),
            subtitle: new Text(expert.email),
          )
        : Container();
  }

  void _navigateToExpertDetails(Expert expert, Object avatarTag) {
    Navigator.of(context).push(
      new MaterialPageRoute(
        builder: (c) {
          return new ExpertDetailsPage(expert, avatarTag: avatarTag);
        },
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      onWillPop: () async => false,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text(
            widget.pageTitle,
            style: new TextStyle(color: const Color(0xFFFFFFFF)),
          ),
          titleSpacing: -1.0,
          leading: new IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Filter(
                              update: _update,
                            )));
              }),
        ),
        endDrawer: new Drawer(
            child: new ListView(
          children: <Widget>[
            new ListTile(
              leading: Icon(Icons.sort),
              title: new Text('Sort by followers'),
              onTap: () {
                setState(() {
                  _orderby = 'followers';
                });
                Navigator.pop(context);
              },
            ),
            new ListTile(
              leading: Icon(Icons.sort),
              title: new Text('Sort by latest'),
              onTap: () {
                setState(() {
                  _orderby = 'date';
                });
                Navigator.pop(context);
              },
            ),
            new ListTile(
              leading: Icon(Icons.contact_mail),
              title: new Text('Invite Friends'),
              onTap: () {
                Navigator.pushNamed(context, '/contact');
              },
            ),
          ],
        )),
        body: StreamBuilder(
          stream: Firestore.instance
              .collection('Experts')
              .orderBy(_orderby, descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return new Center(
                child: new CircularProgressIndicator(),
              );
            return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (context, index) => _buildExpertListTile(
                    snapshot, snapshot.data.documents[index], index));
          },
        ),
      ),
    );
  }
}
