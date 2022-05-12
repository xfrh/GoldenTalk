import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:meta/meta.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../manager/expertmanager.dart';
import '../../../../manager/notifymanager.dart';
import '../../../../service/auth_service.dart';
import '../../../../service/locator.dart';
import '../../../../service/message_service.dart';
import '../../../../service/models/expert_model.dart';
import '../../../../service/models/message_model.dart';
import '../../../../service/models/notification_model.dart';
import '../../../chat_screen.dart';
import '../../../stream_screen.dart';
import 'diagonally_cut_colored_image.dart';

class ExpertDetailHeader extends StatefulWidget {
  static const BACKGROUND_IMAGE = 'images/profile_header_background.png';

  ExpertDetailHeader(
    this.expert, {
    @required this.avatarTag,
  });

  final Expert expert;
  final Object avatarTag;

  @override
  _ExpertDetailHeaderState createState() => _ExpertDetailHeaderState();
}

class _ExpertDetailHeaderState extends State<ExpertDetailHeader> {
  final _experDetailMger = locator<ExpertManager>();
  final _noticeMgr = locator<NotifyManager>();
  final _auth = locator<AuthService>();
  final _msgService = locator<MessageService>();
  bool _isMatch = false;
  FirebaseUser _me;
  Widget _buildDiagonalImageBackground(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    return new DiagonallyCutColoredImage(
      new Image.asset(
        ExpertDetailHeader.BACKGROUND_IMAGE,
        width: screenWidth,
        height: 280.0,
        fit: BoxFit.cover,
      ),
      color: const Color(0xBB8338f4),
    );
  }

  Widget _buildAvatar() {
    return new Hero(
      tag: widget.avatarTag,
      child: new CircleAvatar(
        backgroundImage: CachedNetworkImageProvider(widget.expert.avator),
        radius: 50.0,
      ),
    );
  }

  Widget _buildFollowerInfo(TextTheme textTheme) {
    var followerStyle =
        textTheme.subhead.copyWith(color: const Color(0xBBFFFFFF));

    return new Padding(
      padding: const EdgeInsets.only(top: 16.0),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(widget.expert.members.length.toString() + "Following",
              style: followerStyle),
          new Text(
            ' | ',
            style: followerStyle.copyWith(
                fontSize: 24.0, fontWeight: FontWeight.normal),
          ),
          new Text(widget.expert.members.length.toString() + "Follower",
              style: followerStyle),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme, BuildContext context) {
    return new Padding(
      padding: const EdgeInsets.only(
        top: 16.0,
        left: 16.0,
        right: 16.0,
      ),
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          _createPillButton(
            'JOIN',
            context,
            backgroundColor: theme.accentColor,
          ),
          new DecoratedBox(
            decoration: new BoxDecoration(
              border: new Border.all(color: Colors.white30),
              borderRadius: new BorderRadius.circular(30.0),
            ),
            child: _createFollowButton(
              'STUDIO',
              context,
              textColor: Colors.white70,
              backgroundColor: theme.accentColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _createPillButton(
    String text,
    BuildContext context, {
    Color backgroundColor = Colors.transparent,
    Color textColor = Colors.white70,
  }) {
    return new ClipRRect(
      borderRadius: new BorderRadius.circular(30.0),
      child: new MaterialButton(
        minWidth: 140.0,
        color: backgroundColor,
        textColor: textColor,
        onPressed: () {
          if (_me.uid != widget.expert.uid &&
              widget.expert.members.indexOf(_me.uid) == -1)
            createWelcomeMessage();
          Navigator.of(context).push(
            new MaterialPageRoute(
              builder: (c) {
                return new ChatScreen(selectedExpert: widget.expert);
              },
            ),
          );
        },
        child: new Text(text),
      ),
    );
  }

//  void matchMembers() async{
//    var _lst=await _noticeMgr.getNoticesByRoomId(widget.expert.expertID);

//    if(_lst.length!=widget.expert.members.length){
//      widget.expert.members=[];
//      _lst.forEach((element) {
//        if(element.uid!=null)
//          widget.expert.members.add(element.uid);
//      });
//     _experDetailMger.updateExpert(widget.expert, widget.expert.expertID);
//     setState(() {
//       _isMatch=true;
//     });
//    }
//  }

  void createWelcomeMessage() {
    String message = " hi, ${_me.displayName ?? _me.email}";
    widget.expert.members.add(_me.uid);
    _experDetailMger.updateExpert(widget.expert, widget.expert.expertID);
    message += " welcome to join ${widget.expert.name} team";
    final _noitic = Notify(roomId: widget.expert.expertID, message: message);
    _noitic.uid = _me.uid;
    _noitic.displayName = _me.displayName;
    _noitic.email = _me.email;
    _noitic.imageUrl = _me.photoUrl;
    _noitic.date = DateTime.now().millisecondsSinceEpoch;
    _noticeMgr.addNotice(_noitic);
    SendWelcomeMessage(message);
  }

  void SendWelcomeMessage(String message) {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd');
    String formatday = formatter.format(now);
    dynamic currentTime = DateFormat.jms().format(DateTime.now());
    Message _message = new Message(
        roomId: widget.expert.expertID,
        senderId: widget.expert.uid,
        senderName: widget.expert.name,
        date: DateTime.now().millisecondsSinceEpoch,
        senderpic: widget.expert.avator,
        content: message,
        unread: 'true',
        type: '0');
    FirebaseDatabase.instance
        .reference()
        .child("message")
        .push()
        .set(_message.toJson());
  }

  Widget _createFollowButton(
    String text,
    BuildContext context, {
    Color backgroundColor = Colors.transparent,
    Color textColor = Colors.white70,
  }) {
    return new ClipRRect(
      borderRadius: new BorderRadius.circular(30.0),
      child: new MaterialButton(
        minWidth: 140.0,
        color: backgroundColor,
        textColor: textColor,
        onPressed: () async {
          if (_me.uid == widget.expert.uid ||
              widget.expert.members.contains(_me.uid)) {
            await _handleCameraAndMic();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => StreamPage(expert: widget.expert),
              ),
            );
          } else {
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text('Join team first'),
                action: SnackBarAction(
                    label: 'info', onPressed: () => {Navigator.pop(context)}),
                duration: Duration(milliseconds: 2000)));
          }
          // await Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder: (context) => CallPage(
          //       expert: widget.expert,
          //       role: widget.expert.uid == _me.uid
          //           ? ClientRole.Broadcaster
          //           : ClientRole.Audience,
          //     ),
          //   ),
          // );
        },
        child: new Text(text),
      ),
    );
  }

  Future<void> _handleCameraAndMic() async {
    await PermissionHandler().requestPermissions(
      [PermissionGroup.camera, PermissionGroup.microphone],
    );
  }

  @override
  void initState() {
    _me = _auth.activeUser;

    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    if (_me == null) return Container();
    return new Stack(
      children: <Widget>[
        _buildDiagonalImageBackground(context),
        new Align(
          alignment: FractionalOffset.bottomCenter,
          heightFactor: 1.4,
          child: new Column(
            children: <Widget>[
              _buildAvatar(),
              _buildFollowerInfo(textTheme),
              _buildActionButtons(theme, context),
            ],
          ),
        ),
        new Positioned(
          top: 26.0,
          left: 4.0,
          child: new BackButton(color: Colors.white),
        ),
      ],
    );
  }
}
