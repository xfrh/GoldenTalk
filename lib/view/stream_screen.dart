import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import '../manager/videochatmanager.dart';
import '../service/auth_service.dart';
import '../service/locator.dart';
import '../service/models/expert_model.dart';
import '../view/widget/paypal/paypalwebview.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../service/models/video_chat.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import './global/Colors.dart' as myColors;

class StreamPage extends StatefulWidget {
  /// non-modifiable channel name of the page
  /// non-modifiable channel name of the page
  final Expert expert;

  /// Creates a call page with given channel name.
  const StreamPage({Key key, this.expert}) : super(key: key);

  @override
  _StreamPageState createState() => _StreamPageState();
}

class _StreamPageState extends State<StreamPage> {
  final _auth = locator<AuthService>();
  static final _users = <int>[];
  final _infoStrings = <String>[];
  final messageHolder = TextEditingController();
  final _videoChatMgr = locator<VideoChatManager>();
  final _audiances = List<String>();
  bool muted = false;
  bool _isBroadcasting = true;
  FirebaseUser _me;
  String _content;
  String _notice = '';

  @override
  void dispose() {
    // clear users
    _users.clear();
    // destroy sdk
    if (_isBroadcasting) {
      AgoraRtcEngine.leaveChannel();
      AgoraRtcEngine.destroy();
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _me = _auth.activeUser;
    _audiances.add(_me.uid);
    var _lmsg = _audiances.contains(widget.expert.uid)
        ? (_audiances.length - 1).toString() + ' watching'
        : _audiances.length.toString() + ' waiting';
    _notice = widget.expert.name + " studio:" + _lmsg;
    if (widget.expert.refers != null && widget.expert.refers.length > 0) {
      if (widget.expert.refers[0].contains('youtu')) {
        setState(() {
          _isBroadcasting = false;
          _notice = widget.expert.name +
              " studio:" +
              (_audiances.length).toString() +
              ' watching';
        });
      }
    }
    if (_isBroadcasting) initialize();
  }

  Future<void> initialize() async {
    await _initAgoraRtcEngine();
    _addAgoraEventHandlers();
    await AgoraRtcEngine.enableWebSdkInteroperability(true);
    await AgoraRtcEngine.setParameters(
        '''{\"che.video.lowBitRateStreamParameter\":{\"width\":320,\"height\":180,\"frameRate\":15,\"bitRate\":140}}''');
    await AgoraRtcEngine.joinChannel(null, widget.expert.expertID, null, 0);
  }

  /// Create agora sdk instance and initialize
  Future<void> _initAgoraRtcEngine() async {
    await AgoraRtcEngine.create('7607a5490d4c415d9c391f40465340e4');
    await AgoraRtcEngine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await AgoraRtcEngine.enableVideo();
    if (_me.uid == widget.expert.uid)
      await AgoraRtcEngine.setClientRole(ClientRole.Broadcaster);
    else
      await AgoraRtcEngine.setClientRole(ClientRole.Audience);
  }

  /// Add agora event handlers
  void _addAgoraEventHandlers() {
    AgoraRtcEngine.onError = (dynamic code) {
      setState(() {
        final info = 'onError: $code';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onJoinChannelSuccess = (
      String channel,
      int uid,
      int elapsed,
    ) {
      setState(() {
        final info = 'onJoinChannel: $channel, uid: $uid';
        _infoStrings.add(info);
      });
    };

    AgoraRtcEngine.onLeaveChannel = () {
      setState(() {
        _infoStrings.add('onLeaveChannel');
        _users.clear();
      });
    };

    AgoraRtcEngine.onUserJoined = (int uid, int elapsed) {
      setState(() {
        final info = 'userJoined: $uid';
        _infoStrings.add(info);
        _users.add(uid);
      });
    };

    AgoraRtcEngine.onUserOffline = (int uid, int reason) {
      setState(() {
        final info = 'userOffline: $uid';
        _infoStrings.add(info);
        _users.remove(uid);
      });
    };

    AgoraRtcEngine.onFirstRemoteVideoFrame = (
      int uid,
      int width,
      int height,
      int elapsed,
    ) {
      setState(() {
        final info = 'firstRemoteVideo: $uid ${width}x $height';
        _infoStrings.add(info);
      });
    };
  }

  /// Helper function to get list of native views
  List<Widget> _getRenderViews() {
    final List<AgoraRenderWidget> list = [
      AgoraRenderWidget(0, local: true, preview: true),
    ];
    _users.forEach((int uid) => list.add(AgoraRenderWidget(uid)));
    return list;
  }

  YoutubePlayerController _createController() {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(widget.expert.refers[0]),
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
    return _controller;
  }

  /// Video view wrapper
  Widget _videoView(view) {
    //  return Expanded(child: Container(child: view));
    return Container(
      child: view,
      height: 250,
    );
  }

  Widget _recordVideoView() {
    return Container(
      child: Column(children: <Widget>[
        Container(
          height: 250,
          child: YoutubePlayer(
            controller: _createController(),
            liveUIColor: Colors.amber,
          ),
        ),
        _noticeWidget(),
      ]),
    );
  }

  /// Video view row wrapper
  Widget _expandedVideoRow(List<Widget> views) {
    final wrappedViews = views.map<Widget>(_videoView).toList();
    return Expanded(
      child: Row(
        children: wrappedViews,
      ),
    );
  }

  Widget _noticeWidget() {
    return Padding(
        padding: const EdgeInsets.all(16),
        child: Container(
          alignment: Alignment.bottomLeft,
          child: Text(
            _notice,
            style: TextStyle(fontSize: 16, color: myColors.orange),
          ),
        ));
  }

  /// Video layout wrapper
  Widget _viewRows() {
    final views = _getRenderViews();
    switch (views.length) {
      case 1:
        return Container(
            child: Column(
          children: <Widget>[
            _videoView(views[0]),
            _noticeWidget(),
          ],
        ));
      case 2:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow([views[0]]),
            _expandedVideoRow([views[1]])
          ],
        ));
      case 3:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 3))
          ],
        ));
      case 4:
        return Container(
            child: Column(
          children: <Widget>[
            _expandedVideoRow(views.sublist(0, 2)),
            _expandedVideoRow(views.sublist(2, 4))
          ],
        ));
      default:
    }
    return Container();
  }

  /// Toolbar layout
  Widget _toolbar() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RawMaterialButton(
            onPressed: _onToggleMute,
            child: Icon(
              muted ? Icons.mic_off : Icons.mic,
              color: muted ? Colors.white : Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: muted ? Colors.blueAccent : Colors.white,
            padding: const EdgeInsets.all(12.0),
          ),
          RawMaterialButton(
            onPressed: () => _onCallEnd(context),
            child: Icon(
              Icons.call_end,
              color: Colors.white,
              size: 35.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.redAccent,
            padding: const EdgeInsets.all(15.0),
          ),
          RawMaterialButton(
            onPressed: _onSwitchCamera,
            child: Icon(
              Icons.switch_camera,
              color: Colors.blueAccent,
              size: 20.0,
            ),
            shape: CircleBorder(),
            elevation: 2.0,
            fillColor: Colors.white,
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  _sendMessage() async {
    if (_content != null && _me != null) {
      final _videoChat = VideoChat();
      _videoChat.date = DateTime.now().millisecondsSinceEpoch;
      _videoChat.image = _me.photoUrl;
      _videoChat.lastMessage = _content;
      _videoChat.name = _me.displayName;
      _videoChat.roomId = widget.expert.expertID;
      _videoChat.uid = _me.uid;
      String messagId = await _videoChatMgr.addVideoChat(_videoChat);
      if (messagId != null) {
        setState(() {
          _content = null;
          messageHolder.clear();
        });
      }
    }
  }

  Widget _buildMessageComposer() {
    return Container(
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.money_off),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              if (widget.expert.paypalUrl != null &&
                  widget.expert.paypalUrl != '') {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) =>
                        PaypalBrowser(paymeUrl: widget.expert.paypalUrl),
                  ),
                );
              }
            },
            padding: const EdgeInsets.all(12.0),
          ),
          Expanded(
              child: TextField(
            maxLength: null,
            controller: messageHolder,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.go,
            onChanged: (value) {
              _content = value;
            },
            decoration: InputDecoration.collapsed(
              hintText: 'Send a message...',
            ),
          )),
          IconButton(
            icon: Icon(Icons.send),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _sendMessage();
            },
            padding: const EdgeInsets.all(12.0),
          )
        ],
      ),
    );
  }

  Widget _chatPanel() {
    return StreamBuilder(
        stream: Firestore.instance
            .collection('VideoChat')
            .where('roomId', isEqualTo: widget.expert.expertID)
            .orderBy('date', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return Container();
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 48),
            alignment: Alignment.bottomCenter,
            child: FractionallySizedBox(
              heightFactor: 0.5,
              child: Container(
                decoration: BoxDecoration(
                    color: myColors.backGround,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15.0),
                      topRight: Radius.circular(15.0),
                    )),
                child: ListView.builder(
                    itemCount: snapshot.data.documents.length,
                    itemBuilder: (context, index) {
                      final _vchat = VideoChat.fromSanpShot(
                          snapshot.data.documents[index]);
                      return Slidable(
                        actionPane: SlidableDrawerActionPane(),
                        actionExtentRatio: 0.25,
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  flex: 10,
                                  child: ListTile(
                                    title: Text(
                                      _vchat.name,
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    subtitle: Text(
                                      _vchat.lastMessage,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12),
                                    ),
                                    leading: CircleAvatar(
                                      backgroundImage:
                                          CachedNetworkImageProvider(
                                              _vchat.image),
                                    ),
                                    trailing: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: <Widget>[
                                        Text(
                                          timeago.format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  _vchat.date)),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        SizedBox()
                                      ],
                                    ),
                                    onTap: () {},
                                  ),
                                ),
                              ],
                            ),
                            Divider(
                              endIndent: 12.0,
                              indent: 12.0,
                              height: 0,
                            ),
                          ],
                        ),
                        secondaryActions: <Widget>[
                          IconSlideAction(
                            caption: 'Delete',
                            color: Colors.red,
                            icon: Icons.delete,
                            onTap: () {
                              if (_vchat.uid == _me.uid ||
                                  _me.uid == widget.expert.uid) {
                                _vchat.lastMessage = 'message was deleted';
                                _videoChatMgr.updateVideoChat(
                                    _vchat, _vchat.messageId);
                                setState(() {
                                  _content = null;
                                  messageHolder.clear();
                                });
                              }
                            },
                          ),
                        ],
                      );
                    }),
              ),
            ),
          );
        });
  }

  /// Info panel to show logs
  Widget _panel() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48),
      alignment: Alignment.bottomCenter,
      child: FractionallySizedBox(
        heightFactor: 0.5,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 48),
          child: ListView.builder(
            reverse: true,
            itemCount: _infoStrings.length,
            itemBuilder: (BuildContext context, int index) {
              if (_infoStrings.isEmpty) {
                return null;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 3,
                  horizontal: 10,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 2,
                          horizontal: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.yellowAccent,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          _infoStrings[index],
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _onCallEnd(BuildContext context) {
    Navigator.pop(context);
  }

  void _onToggleMute() {
    setState(() {
      muted = !muted;
    });
    AgoraRtcEngine.muteLocalAudioStream(muted);
  }

  void _onSwitchCamera() {
    AgoraRtcEngine.switchCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("video room"),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: <Widget>[
          _isBroadcasting ? _viewRows() : _recordVideoView(),

          //_panel(),
          //_toolbar(),
          _chatPanel(),
          _buildMessageComposer(),
        ],
      ),
    );
  }
}
