import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../manager/expertmanager.dart';
import '../service/auth_service.dart';
import '../service/dynamiclinke_service.dart';
import '../service/locator.dart';
import '../service/models/chat_model.dart';
import '../service/models/expert_model.dart';
import '../service/models/post_model.dart';
import '../view/chat_screen.dart';
import '../view/widget/blog/viewPost.dart';
import '../view/widget/expertdetails/expert_details_page.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class Home extends StatefulWidget {
  final String listType;

  Home(this.listType);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final _auth = locator<AuthService>();
  final _expertMgr = locator<ExpertManager>();
  final _dynamicService = locator<DynamicLinkService>();
  final _recentChat = List<ChatModel>();
  final _querytodo = FirebaseDatabase.instance.reference().child('message');

  StreamSubscription<Event> _onRecentAdd;
  StreamSubscription<Event> _onRecendChange;
  StreamSubscription<Event> _onRecentRemove;
  FirebaseUser _me;

  Future _initDynaimicLink() async {
    await _dynamicService.handleDynamicLinks();
  }

  Post _openBlog(DocumentSnapshot document) {
    return Post.FromSnapShot(document);
  }

  // Future _updateToken() async {
  //   var _me = _pre.myinfo ?? User();
  //   if (_me.phoneToken != null) {
  //     FirebaseUser _currentUser = await _auth.getCurrentUser();
  //     if (_currentUser != null) {
  //       bool isExist = await _noticeMger.checkExist(_currentUser.uid);
  //       if (!isExist) {
  //         var _notice = Notify(
  //             uid: _currentUser.uid, deviceToken: _me.phoneToken, unread: true);
  //         _noticeMger.addNotice(_notice);
  //       } else {
  //         Notify _curnotice =
  //             await _noticeMger.getNoticeByUid(_currentUser.uid);
  //         if (_curnotice.deviceToken != _me.phoneToken) {
  //           _curnotice.deviceToken = _me.phoneToken;
  //           _noticeMger.updateNotice(_curnotice, _curnotice.noticeID);
  //         }
  //       }
  //     }
  //   }
  // }

  @override
  void initState() {
    // TODO: implement initState

    _onRecentAdd = _querytodo.onChildAdded.listen(_getRecent);
    _onRecendChange = _querytodo.onChildChanged.listen(_getRecent);
    _onRecentRemove = _querytodo.onChildRemoved.listen(_removeRecent);
    setState(() {
      _me = _auth.activeUser;
    });
    super.initState();
  }

  void _removeRecent(Event event) {
    var data = event.snapshot.value;
    var oldEntry = _recentChat.singleWhere((entry) {
      return entry.messageID == event.snapshot.key;
    });
    if (oldEntry != null) {
      setState(() {
        _recentChat.remove(oldEntry);
      });
    }
  }

  void _getRecent(Event event) {
    var data = event.snapshot.value;
    var dummy = new ChatModel();
    var p = _recentChat.firstWhere((e) => e.roomId == data['roomId'],
        orElse: () => dummy);
    if (p != dummy) {
      ChatModel lx = _recentChat[_recentChat.indexOf(p)];
      lx.messageID = event.snapshot.key;
      lx.name = data['senderName'];
      if (lx.name.length > 15) lx.name = lx.name.substring(0, 15);
      lx.imageUrl = data['senderpic'];
      if (data['type'] == "1")
        lx.message = 'a image post at';
      else if (data['type'] == "2")
        lx.message = ' a video post at';
      else if (data['type'] == "3")
        lx.message = ' a voice post at';
      else {
        if (data['content'].length > 50)
          lx.message = data['content'].toString().substring(0, 50) + "...";
        else
          lx.message = data['content'];
      }

      lx.date = data['date'];
      lx.roomId = data['roomId'];
      setState(() {
        _recentChat.sort((b, a) => a.date.compareTo(b.date));
      });
    } else {
      dummy.messageID = event.snapshot.key;
      dummy.roomId = data['roomId'];
      dummy.name = data['senderName'];
      dummy.imageUrl = data['senderpic'];
      if (data['type'] == "1")
        dummy.message = 'a image post at';
      else if (data['type'] == "2")
        dummy.message = ' a video post at';
      else if (data['type'] == "3")
        dummy.message = ' a voice post at';
      else {
        if (data['content'].length > 50)
          dummy.message = data['content'].toString().substring(0, 50) + "...";
        else
          dummy.message = data['content'];
      }
      dummy.date = data['date'];
      _recentChat.add(dummy);
      setState(() {
        _recentChat.sort((b, a) => a.date.compareTo(b.date));
      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _onRecendChange.cancel();
    _onRecentAdd.cancel();
    _onRecentRemove.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _width = MediaQuery.of(context).size.width;
    final _height = MediaQuery.of(context).size.height;
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
          actions: <Widget>[
            new IconButton(
                icon: const Icon(Icons.video_library), onPressed: () {}),
          ],
        ),
        body: new Column(
          children: <Widget>[
            new Padding(padding: const EdgeInsets.fromLTRB(0.0, 3.0, 0.0, 8.0)),
            StreamBuilder(
                stream: Firestore.instance
                    .collection('Posts')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return Container();
                  else {
                    return new Container(
                      height: 220.0,
                      color: Colors.grey[200],
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: snapshot.data.documents.length,
                          itemBuilder: (context, int position) =>
                              new GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => PostView(
                                                _openBlog(snapshot.data
                                                    .documents[position]))));
                                  },
                                  child: new Column(
                                    children: <Widget>[
                                      new Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            5.0, 5.0, 5.0, 5.0),
                                        child: new Container(
                                          color: Colors.grey[200],
                                          width: 100.0, //story container width
                                          height:
                                              210.0, //story container height
                                          child: new Stack(
                                            alignment: Alignment.center,
                                            children: <Widget>[
                                              new Column(
                                                children: <Widget>[
                                                  new Container(
                                                    decoration: new BoxDecoration(
                                                        image: new DecorationImage(
                                                            image: new CachedNetworkImageProvider(snapshot
                                                                            .data
                                                                            .documents[
                                                                        position]
                                                                    [
                                                                    'imgUrl'] ??
                                                                "https://images.unsplash.com/photo-1538543917671-5116452b49e7?ixlib=rb-0.3.5&ixid=eyJhcHBfaWQiOjEyMDd9&s=78488bf52c88add77bbfa1b53a39455b&auto=format&fit=crop&w=500&q=60"),
                                                            fit: BoxFit.cover),
                                                        borderRadius:
                                                            new BorderRadius
                                                                    .circular(
                                                                10.0)),
                                                    width:
                                                        100.0, //story image width
                                                    height: 140.0,
                                                    child: new Padding(
                                                      padding: const EdgeInsets
                                                              .fromLTRB(
                                                          5.0, 85.0, 5.0, 5.0),
                                                      child: new Text(
                                                        snapshot.data.documents[
                                                            position]['title'],
                                                        style: new TextStyle(
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 18.0,
                                                            fontStyle: FontStyle
                                                                .normal,
                                                            color:
                                                                Colors.white),
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        textAlign:
                                                            TextAlign.center,
                                                      ),
                                                    ), //story image height
                                                  ),
                                                ],
                                              ),
                                              new Padding(
                                                child: new PhysicalModel(
                                                  borderRadius:
                                                      new BorderRadius.circular(
                                                          25.0),
                                                  color: Colors.transparent,
                                                  child: new Container(
                                                    width: 50.0,
                                                    height: 50.0,
                                                    decoration:
                                                        new BoxDecoration(
                                                      image: new DecorationImage(
                                                          image: new CachedNetworkImageProvider(
                                                              snapshot.data
                                                                          .documents[
                                                                      position]
                                                                  ['thumb']),
                                                          fit: BoxFit.cover),
                                                      borderRadius:
                                                          new BorderRadius
                                                              .circular(25.0),
                                                      border: new Border.all(
                                                          width: 3.0,
                                                          color: Color(
                                                              0xFF2845E7)),
                                                    ),
                                                  ),
                                                ),
                                                padding:
                                                    const EdgeInsets.fromLTRB(
                                                        5.0, 65.0, 5.0, 0.0),
                                              ),
                                              new Padding(
                                                  padding:
                                                      const EdgeInsets.fromLTRB(
                                                          20.0,
                                                          172.0,
                                                          5.0,
                                                          0.0),
                                                  child: new Center(
                                                    child: new Text(
                                                      //    snapshot.data.documents[position]['body'],
                                                      timeago.format(DateTime
                                                          .fromMillisecondsSinceEpoch(
                                                              snapshot.data
                                                                          .documents[
                                                                      position]
                                                                  ['date'])),
                                                    ),
                                                  )),
                                              // new Padding(
                                              //   padding: const EdgeInsets.fromLTRB(
                                              //       5.0, 172.0, 5.0, 0.0),
                                              //   child:
                                              //       new Text(timeago.format(DateTime.fromMillisecondsSinceEpoch(snapshot.data.documents[position]['date']))),

                                              // )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ))),
                    );
                  }
                }),

            recentDataOnly(),
            //  sampleDataOnly(),
          ],
        ),
      ),
    );
  }

  void _navigateToExpertDetails(Expert expert, Object avatarTag) {
    if ((_me != null && _me.uid == expert.uid) ||
        expert.members.contains(_me.uid)) {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (c) {
            return new ChatScreen(selectedExpert: expert);
          },
        ),
      );
    } else {
      Navigator.of(context).push(
        new MaterialPageRoute(
          builder: (c) {
            return new ExpertDetailsPage(expert, avatarTag: avatarTag);
          },
        ),
      );
    }
  }

  Widget recentDataOnly() {
    return new Expanded(
      child: ListView.builder(
          itemBuilder: (context, position) {
            return new Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                child: new Card(
                    elevation: 1.0,
                    color: const Color(0xFFFFFFFF),
                    child: new ListTile(
                      onTap: () async {
                        var _expert = await _expertMgr.getExpertBYfield(
                            'expertID', _recentChat[position].roomId);
                        if (_expert != null && _me != null)
                          _navigateToExpertDetails(_expert, position);
                      },
                      leading: new CircleAvatar(
                        backgroundImage: new CachedNetworkImageProvider(
                            _recentChat[position].imageUrl),
                      ),
                      title: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text(
                            _recentChat[position].name,
                            style: new TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(
                              //    snapshot.data.documents[position]['body'],
                              timeago.format(
                                  DateTime.fromMillisecondsSinceEpoch(
                                      _recentChat[position].date)),
                              style: new TextStyle(
                                  color: Colors.grey, fontSize: 14.0)),
                        ],
                      ),
                      subtitle: new Container(
                        padding: const EdgeInsets.only(top: 5.0),
                        child: new Text(
                          _recentChat[position].message,
                          style:
                              new TextStyle(color: Colors.grey, fontSize: 15.0),
                        ),
                      ),
                    )));
          },
          itemCount: _recentChat.length),
    );
  }
}
