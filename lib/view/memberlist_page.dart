import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../manager/notifymanager.dart';
import '../service/auth_service.dart';
import '../service/locator.dart';
import '../service/models/expert_model.dart';
import 'package:timeago/timeago.dart' as timeago;

class MemberListPage extends StatefulWidget {
  MemberListPage(this.selectedExpert, {this.update = null});
  final Expert selectedExpert;
  final Function update;
  @override
  _MemberListPageState createState() => _MemberListPageState();
}

class _MemberListPageState extends State<MemberListPage> {
  final _noticeMgr = locator<NotifyManager>();
  final _auth = locator<AuthService>();
  FirebaseUser _me;
  @override
  void initState() {
    _me = _auth.activeUser;
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: new AppBar(
          title: new Text(
            'Members',
            style: new TextStyle(color: const Color(0xFFFFFFFF)),
          ),
          titleSpacing: -1.0,
          leading: new BackButton(color: Colors.white),
        ),
        body: StreamBuilder(
            stream: Firestore.instance
                .collection('notices')
                .where('roomId', isEqualTo: widget.selectedExpert.expertID)
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) return const Text('Loading...');
              return new ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) =>
                      _buildItemList(snapshot, snapshot.data.documents[index]));
            }));
  }

  Padding _buildItemList(AsyncSnapshot snapshot, DocumentSnapshot document) {
    return new Padding(
        padding: const EdgeInsets.all(0.0),
        child: Slidable(
          actionPane: SlidableScrollActionPane(),
          actionExtentRatio: 0.25,
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => {
                _me.uid == widget.selectedExpert.uid
                    ? _noticeMgr.removeNotice(document.documentID)
                    : null
              },
            ),
          ],
          child: new Card(
            elevation: 1.0,
            color: Colors.white,
            child: new Column(
              children: <Widget>[
                new ListTile(
                  onTap: () {
                    widget.update(document['displayName']);
                    Navigator.pop(context);
                  },
                  leading: document['imageUrl'] == null
                      ? Text('')
                      : new CircleAvatar(
                          backgroundImage: new CachedNetworkImageProvider(
                              document['imageUrl']),
                          backgroundColor: Colors.grey,
                        ),
                  title: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Text(
                        document['displayName'] ?? '',
                        style: new TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black),
                      ),
                    ],
                  ),
                  subtitle: new Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      new Column(
                        children: <Widget>[
                          new Row(
                            children: <Widget>[
                              new Text(timeago.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      document['date']))),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
