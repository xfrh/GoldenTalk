import 'package:flutter/services.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import '../service/locator.dart';
import '../service/models/friends_model.dart';
import '../service/permission_service.dart';
import 'package:email_validator/email_validator.dart';
import 'package:share/share.dart';

class CallseditPage extends StatefulWidget {
  @override
  _CallseditPageState createState() => _CallseditPageState();
}

class _CallseditPageState extends State<CallseditPage> {
  var profileimageControl = TextEditingController();
  final _permissonMgr = locator<PermissionsService>();
  Iterable<Contact> _contacts;
  final _formKey = GlobalKey<FormState>();
  Friend _friend = Friend();
  @override
  initState() {
    refreshContacts();
    super.initState();
  }

  _shareLink() {
    debugPrint("in share link");
    Share.share("https://privchat.page.link/jofZ");
  }

  Future sendMailInvite() async {
    final MailOptions mailOptions = MailOptions(
      body: 'https://privchat.page.link/jofZ',
      subject: 'check out the link and join us to Golden House',
      recipients: [_friend.email],
      isHTML: false,
    );
    await FlutterMailer.send(mailOptions);
    _showDialog('Email', 'invite email send to your friend' + _friend.name);
  }
// Future _sendSMS(String phonenum)async {
//   //  SmsSender sender = new SmsSender();
//   // var sms=await  sender.sendSms(new SmsMessage(phonenum, 'https://privchat.page.link/jofZ'));
//   //  _showDialog('SMS','invite message send to your friend' +_friend.name);
//   }

  void _showDialog(String code, String msg) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text(code),
          content: new Text(msg),
          actions: <Widget>[
            new FlatButton(
              child: new Text("OK"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  bool _validateAndSave() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _validateAndSubmit() async {
    if (_validateAndSave()) {
      await sendMailInvite();
    }
  }

  Widget AddContactPage() {
    return Scaffold(
      appBar: AppBar(
        title: Text("Invite a friend"),
        actions: <Widget>[
          FlatButton(
            onPressed: () {
              _validateAndSubmit();
            },
            child: Icon(
              Icons.email,
              color: Colors.white,
              size: 30.0,
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.share),
        onPressed: () {
          _shareLink();
        },
      ),
      body: Container(
        padding: EdgeInsets.all(12.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                    labelText:
                        'Enter friend email,then press email icon on top'),
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Email can\'t be empty';
                  } else if (!EmailValidator.validate(value)) {
                    return 'Entered email isn\'t valid';
                  } else
                    return null;
                },
                onSaved: (v) => _friend.email = v,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget ContactPage() {
    return Scaffold(
      appBar: AppBar(title: Text('Contacts')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {
          gotoAddContact();
        },
      ),
      body: SafeArea(
        child: _contacts != null
            ? ListView.builder(
                itemCount: _contacts?.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  Contact c = _contacts?.elementAt(index);
                  var mobilenum = c.phones.toList();
                  return Slidable(
                    actionPane: SlidableScrollActionPane(),
                    actionExtentRatio: 0.25,
                    secondaryActions: <Widget>[
                      IconSlideAction(
                        caption: 'Delete',
                        color: Colors.red,
                        icon: Icons.delete,
                        onTap: () => {},
                      ),
                    ],
                    child: ListTile(
                      onTap: () {
                        // if (mobilenum.length > 0) {
                        //   var _phonenum = mobilenum[0];
                        //   _sendSMS(_phonenum.value);
                        // }
                      },
                      leading: (c.avatar != null && c.avatar.length > 0)
                          ? CircleAvatar(backgroundImage: MemoryImage(c.avatar))
                          : CircleAvatar(child: Text(c.initials())),
                      title: Text(c.displayName ?? ""),
                      subtitle: Text(
                          mobilenum.length == 0 ? "" : c.phones.last.value),
                    ),
                  );
                },
              )
            : Center(
                child: CircularProgressIndicator(),
              ),
      ),
    );
  }

  gotoAddContact() {
    _controller.animateToPage(
      0,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  gotoContact() {
    _controller.animateToPage(
      1,
      duration: Duration(milliseconds: 800),
      curve: Curves.bounceOut,
    );
  }

  refreshContacts() async {
    bool b = await _permissonMgr.requestContactsPermission();
    if (b) {
      var contacts = await ContactsService.getContacts();
      setState(() {
        _contacts = contacts;
      });
    } else {
      _contacts = null;
    }
  }

  bool _isIos;
  PageController _controller =
      new PageController(initialPage: 1, viewportFraction: 1.0);
  @override
  Widget build(BuildContext context) {
    _isIos = Theme.of(context).platform == TargetPlatform.iOS;
    return Container(
        height: MediaQuery.of(context).size.height,
        child: PageView(
          controller: _controller,
          physics: new AlwaysScrollableScrollPhysics(),
          children: <Widget>[
            AddContactPage(),
            ContactPage(),
          ],
          scrollDirection: Axis.horizontal,
        ));
  }
}
