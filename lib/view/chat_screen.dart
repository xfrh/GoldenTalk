import 'dart:async';
import 'dart:io' as io;
import 'package:audioplayer/audioplayer.dart';
import 'package:file/local.dart';
import 'package:bubble/bubble.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_audio_recorder/flutter_audio_recorder.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:image_picker/image_picker.dart';
import '../service/auth_service.dart';
import '../service/locator.dart';
import '../service/models/expert_model.dart';
import '../service/models/message_model.dart';
import 'package:path/path.dart' as Path;
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../view/widget/paypal/paypalwebview.dart';
import 'detailimage_screen.dart';
import 'memberlist_page.dart';
import 'package:path_provider/path_provider.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({@required this.selectedExpert});
  Expert selectedExpert;
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  FirebaseDatabase _database = FirebaseDatabase.instance;
  Query _todoQuery;
  List<Message> messages = [];
  final _auth = locator<AuthService>();
  final messageHolder = TextEditingController();
  FlutterAudioRecorder _recorder;
  Recording _current;
  RecordingStatus _currentStatus = RecordingStatus.Unset;
  AudioPlayer audioplayer = AudioPlayer();
  FirebaseUser currentUser;
  String _content;
  bool isShowSticker;
  bool isShowSpeaker;
  io.File imageFile;
  io.File voiceFile;
  BuildContext dialogContext;

  @override
  void initState() {
    isShowSticker = false;
    isShowSpeaker = false;
    imageFile = null;
    _todoQuery = _database
        .reference()
        .child("message")
        .orderByChild("roomId")
        .equalTo(widget.selectedExpert.expertID);

    setState(() {
      currentUser = _auth.activeUser;
    });

    super.initState();
    _init();
    KeyboardVisibility.onChange.listen((bool visible) {
      if (visible == false && _content != null && _content.isNotEmpty)
        _sendMessage();
    });
  }

  _init() async {
    try {
      if (await FlutterAudioRecorder.hasPermissions) {
        String customPath = '/flutter_audio_recorder_';
        io.Directory appDocDirectory;
        if (io.Platform.isIOS) {
          appDocDirectory = await getApplicationDocumentsDirectory();
        } else {
          appDocDirectory = await getExternalStorageDirectory();
        }
        customPath = appDocDirectory.path +
            customPath +
            DateTime.now().millisecondsSinceEpoch.toString();
        _recorder =
            FlutterAudioRecorder(customPath, audioFormat: AudioFormat.WAV);

        await _recorder.initialized;
        var current = await _recorder.current(channel: 0);
        print(current);
        // should be "Initialized", if all working fine
        setState(() {
          _current = current;
          _currentStatus = current.status;
          print(_currentStatus);
        });
      } else {
        Scaffold.of(context).showSnackBar(
            new SnackBar(content: new Text("You must accept permissions")));
      }
    } catch (e) {
      print(e);
    }
  }

  _start() async {
    try {
      await _recorder.start();
      var recording = await _recorder.current(channel: 0);
      setState(() {
        _current = recording;
      });

      const tick = const Duration(milliseconds: 50);
      new Timer.periodic(tick, (Timer t) async {
        if (_currentStatus == RecordingStatus.Stopped) {
          t.cancel();
          this._content = await uploadVoice();
          _sendMessage();
          _init();
        }

        var current = await _recorder.current(channel: 0);
        // print(current.status);
        setState(() {
          _current = current;
          _currentStatus = _current.status;
        });
      });
    } catch (e) {
      print(e);
    }
  }

  _stop() async {
    var result = await _recorder.stop();
    print("Stop recording: ${result.path}");
    print("Stop recording: ${result.duration}");
    this.voiceFile = LocalFileSystem().file(result.path);
    var len = await voiceFile.length();
    print("File length: ${len}");

    setState(() {
      _current = result;
      _currentStatus = _current.status;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  _openCamera() async {
    //Navigator.pop(dialogContext);
    Navigator.pop(context);
    this.imageFile = await ImagePicker.pickImage(source: ImageSource.camera);
    this._content = await uploadFile();
    if (this._content != null) _sendMessage();
  }

  _openGallery() async {
    //Navigator.pop(dialogContext);
    Navigator.pop(context);
    this.imageFile = await ImagePicker.pickImage(source: ImageSource.gallery);
    this._content = await uploadFile();
    if (this._content != null) _sendMessage();
  }

  YoutubePlayerController _createController(Message message) {
    YoutubePlayerController _controller = YoutubePlayerController(
      initialVideoId: YoutubePlayer.convertUrlToId(message.content),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
    return _controller;
  }

  Future<String> uploadFile() async {
    setState(() {
      messageHolder.text = 'Uploading...please wait';
    });
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chat/${Path.basename(this.imageFile.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(this.imageFile);
    await uploadTask.onComplete;
    return await storageReference.getDownloadURL();
  }

  Future<String> uploadVoice() async {
    setState(() {
      messageHolder.text = 'Uploading...please wait';
    });
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('chat/${Path.basename(this.voiceFile.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(this.voiceFile);
    await uploadTask.onComplete;
    return await storageReference.getDownloadURL();
  }

  _showModalBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
          height: 160.0,
          child: ListView(
            children: <Widget>[
              ListTile(
                onTap: () => {_openCamera()},
                leading: new Icon(Icons.camera_alt),
                title: Text(
                  'Camera',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Take a picture'),
              ),
              ListTile(
                onTap: () => {_openGallery()},
                leading: new Icon(Icons.photo_album),
                title: Text(
                  'Album',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Get a picture in album'),
              ),
              ListTile(
                onTap: () => {
                  if (widget.selectedExpert.paypalUrl != null &&
                      widget.selectedExpert.paypalUrl != '')
                    {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) => PaypalBrowser(
                              paymeUrl: widget.selectedExpert.paypalUrl),
                        ),
                      )
                    }
                },
                leading: new Icon(Icons.favorite_border),
                title: Text(
                  'Reward ${widget.selectedExpert.name}',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Reward through paypal'),
              ),
              ListTile(
                onTap: () => {},
                leading: new Icon(Icons.video_call),
                title: Text(
                  'Hint',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                subtitle: Text('Paste youtube  url can share your favor video'),
              ),
            ],
          )),
    );
  }

// user defined function
  void _showDialog(String title, String content) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(title),
          content: new Text(content),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else if (isShowSpeaker) {
      setState(() {
        isShowSpeaker = false;
      });
    } else {
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  void _removeRoomMessage() {
    messages.forEach((element) {
      _database.reference().child('message').child(element.messageId).remove();
    });
    messages.clear();
  }

  _sendMessage() {
    if (_content != null && currentUser != null) {
      Message _message = new Message(
          roomId: widget.selectedExpert.expertID,
          senderId: currentUser.uid,
          senderName: currentUser.displayName,
          date: DateTime.now().millisecondsSinceEpoch,
          senderpic: currentUser.photoUrl,
          content: _content,
          unread: 'false',
          type: this.imageFile == null ? "0" : "1");
      if (_message.content.contains('youtu.be')) _message.type = '2';
      if (this.voiceFile != null) _message.type = '3';
      _database.reference().child("message").push().set(_message.toJson());
      messageHolder.clear();
      isShowSticker = false;
      imageFile = null;
      voiceFile = null;
      _content = null;
    }
  }

  _buildMessage(Message message, bool isMe) {
    double pixelRatio = MediaQuery.of(context).devicePixelRatio;
    double px = 1 / pixelRatio;
    BubbleStyle styleSomebody = BubbleStyle(
      nip: BubbleNip.leftTop,
      color: Colors.white,
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, right: 50.0),
      alignment: Alignment.topLeft,
    );
    BubbleStyle styleMe = BubbleStyle(
      nip: BubbleNip.rightTop,
      color: Color.fromARGB(255, 225, 255, 199),
      elevation: 1 * px,
      margin: BubbleEdges.only(top: 8.0, left: 50.0),
      alignment: Alignment.topRight,
    );

    String timeTitle = '';
    isMe = currentUser.uid == message.senderId;
    if (isMe)
      timeTitle =
          timeago.format(DateTime.fromMillisecondsSinceEpoch(message.date));
    else if (widget.selectedExpert.members.length == 2)
      timeTitle =
          timeago.format(DateTime.fromMillisecondsSinceEpoch(message.date));
    else {
      if (message.senderId == widget.selectedExpert.uid)
        timeTitle = 'owner:' +
            timeago.format(DateTime.fromMillisecondsSinceEpoch(message.date));
      else
        timeTitle = message.senderName +
            ':' +
            timeago.format(DateTime.fromMillisecondsSinceEpoch(message.date));
    }
    final Container msg = Container(
      width: MediaQuery.of(context).size.width * 0.75,
      margin: isMe
          ? EdgeInsets.only(top: 7.0, bottom: 8.0)
          : EdgeInsets.only(top: 8.0, bottom: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Bubble(
            alignment: Alignment.center,
            color: Color.fromARGB(255, 212, 234, 244),
            elevation: 1 * px,
            margin: BubbleEdges.only(top: 8.0),
            child: Text(timeTitle, style: TextStyle(fontSize: 13)),
          ),
          Container(
              padding: EdgeInsets.symmetric(horizontal: 3.0),
              child: isMe
                  ? _buildmeraw(styleMe, message)
                  : _buildoterraw(styleSomebody, message)),
        ],
      ),
    );

    return msg;
  }

  Slidable _buildoterraw(BubbleStyle styleSomebody, Message message) {
    return Slidable(
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => {
            if (widget.selectedExpert.uid == currentUser.uid)
              {
                _database
                    .reference()
                    .child('message')
                    .child(message.messageId)
                    .remove()
              }
          },
        ),
      ],
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          GestureDetector(
            onTap: () {},
            child: new CircleAvatar(
              backgroundImage:
                  new CachedNetworkImageProvider(message.senderpic),
              backgroundColor: Colors.grey,
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => {
                if (message.type == "1")
                  {
                    Navigator.pushNamed(context, DetailScreen.routeName,
                        arguments: message.content)
                  }
              },
              child: new Bubble(
                style: styleSomebody,
                child: message.type == "0"
                    ? SelectableText(message.content,
                        style: TextStyle(fontSize: 15))
                    : message.type == "1"
                        ? CachedNetworkImage(
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                            imageUrl: message.content,
                            placeholder: (context, builder) =>
                                Center(child: CircularProgressIndicator()))
                        : message.type == '2'
                            ? YoutubePlayer(
                                controller: _createController(message),
                                liveUIColor: Colors.amber,
                              )
                            : IconButton(
                                icon: Icon(Icons.volume_up),
                                onPressed: () =>
                                    {audioplayer.play(message.content)}),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Slidable _buildmeraw(BubbleStyle styleMe, Message message) {
    return Slidable(
      actionPane: SlidableScrollActionPane(),
      actionExtentRatio: 0.25,
      secondaryActions: <Widget>[
        IconSlideAction(
          caption: 'Delete',
          color: Colors.red,
          icon: Icons.delete,
          onTap: () => {
            _database
                .reference()
                .child('message')
                .child(message.messageId)
                .remove()
          },
        ),
      ],
      child: new Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => {
                if (message.type == "1")
                  {
                    Navigator.pushNamed(context, DetailScreen.routeName,
                        arguments: message.content)
                  }
              },
              child: new Bubble(
                style: styleMe,
                child: message.type == "0"
                    ? SelectableText(message.content,
                        style: TextStyle(fontSize: 15))
                    : message.type == "1"
                        ? CachedNetworkImage(
                            height: 200,
                            width: 200,
                            fit: BoxFit.cover,
                            imageUrl: message.content,
                            placeholder: (context, builder) =>
                                Center(child: CircularProgressIndicator()))
                        : message.type == '2'
                            ? YoutubePlayer(
                                controller: _createController(message),
                                liveUIColor: Colors.amber,
                              )
                            : IconButton(
                                icon: Icon(Icons.volume_up),
                                onPressed: () =>
                                    {audioplayer.play(message.content)}),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: new CircleAvatar(
              backgroundImage:
                  new CachedNetworkImageProvider(currentUser.photoUrl),
              backgroundColor: Colors.grey,
            ),
          )
        ],
      ),
    );
  }

  Widget buildSticker() {
    return EmojiPicker(
      rows: 3,
      columns: 7,
      buttonMode: ButtonMode.MATERIAL,
      // recommendKeywords: [Category.SMILEYS.toString()],
      numRecommended: 10,
      onEmojiSelected: (emoji, category) {
        messageHolder.text += emoji.emoji;
        this._content = messageHolder.text;
      },
    );
  }

  Function aitHime(String name) {
    messageHolder.text = '@' + name + ":";
  }

  _buildMessageComposer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: isShowSpeaker == false
                ? Icon(Icons.volume_up)
                : Icon(Icons.keyboard),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                isShowSpeaker = !isShowSpeaker;
              });
              // _showChoiceDialog();
              //  _showModalBottomSheet(1);
            },
          ),
          Expanded(
            child: isShowSpeaker == false
                ? TextField(
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
                  )
                : Row(
                    children: <Widget>[
                      GestureDetector(
                          onTap: () => {},
                          onTapDown: (_) {
                            if (_currentStatus == RecordingStatus.Initialized) {
                              _start();
                            }
                          },
                          onTapUp: (_) {
                            if (_currentStatus != RecordingStatus.Unset)
                              _stop();
                          },
                          child: Container(
                            padding: EdgeInsets.all(12.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).buttonColor,
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text('Slight Tab To Speach',
                                style: TextStyle(
                                    color: Colors.indigoAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold)),
                          )),
                      _currentStatus == RecordingStatus.Recording
                          ? Icon(Icons.record_voice_over)
                          : Container()
                    ],
                  ),
          ),
          IconButton(
            icon: Icon(Icons.insert_emoticon),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              setState(() {
                isShowSticker = !isShowSticker;
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.add_circle),
            iconSize: 25.0,
            color: Theme.of(context).primaryColor,
            onPressed: () {
              _showModalBottomSheet();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text(
          widget.selectedExpert.name,
          style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
        ),
        elevation: 0.0,
      ),
      endDrawer: new Drawer(
          child: new ListView(
        children: <Widget>[
          new ListTile(
            leading: Icon(Icons.people),
            title: new Text('Group Members'),
            onTap: () {
              Navigator.pop(context);
              Navigator.of(context).push(
                new MaterialPageRoute(
                  builder: (c) {
                    return new MemberListPage(widget.selectedExpert,
                        update: aitHime);
                  },
                ),
              );
            },
          ),
          currentUser.uid == widget.selectedExpert.uid
              ? new ListTile(
                  leading: Icon(Icons.delete),
                  title: new Text('Clear Talks'),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.selectedExpert.uid == currentUser.uid)
                      _removeRoomMessage();
                  },
                )
              : Container(),
        ],
      )),
      body: StreamBuilder(
          stream: _todoQuery.onValue,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              messages.clear();

              DataSnapshot dataValues = snapshot.data.snapshot;
              Map<dynamic, dynamic> values = dataValues.value;
              if (values != null) {
                values.forEach((key, values) {
                  Message _msg = new Message(
                      messageId: key,
                      roomId: values['roomId'],
                      senderId: values['senderId'],
                      senderName: values['senderName'],
                      date: values['date'],
                      senderpic: values['senderpic'],
                      content: values['content'],
                      unread: values['unread'],
                      type: values['type']);
                  messages.add(_msg);
                  if (messages.length > 1)
                    messages.sort((a, b) => b.messageId.compareTo(a.messageId));
                });
              }
              return GestureDetector(
                onTap: () => FocusScope.of(context).unfocus(),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow.withAlpha(64),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(30.0),
                            topRight: Radius.circular(30.0),
                          ),
                          child: ListView.builder(
                            reverse: true,
                            padding: EdgeInsets.only(top: 15.0),
                            itemCount: messages.length,
                            itemBuilder: (BuildContext context, int index) {
                              if (messages.length > 0) {
                                final Message message = messages[index];
                                final bool isMe =
                                    message.senderId == currentUser.uid;
                                return _buildMessage(message, isMe);
                              }
                              return Center(child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ),
                    ),
                    _buildMessageComposer(),
                    (isShowSticker ? buildSticker() : Container()),
                  ],
                ),
              );
            } else
              return Center(child: CircularProgressIndicator());
          }),
    );
  }
}
