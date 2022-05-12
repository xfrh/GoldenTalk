import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../manager/postmanager.dart';
import '../../../service/auth_service.dart';
import '../../../service/locator.dart';
import '../../../service/models/post_model.dart';
import 'package:path/path.dart' as Path;

class AddPost extends StatefulWidget {
  final _postMgr = locator<PostManager>();
  @override
  _AddPostState createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  final GlobalKey<FormState> formkey = new GlobalKey();
  final _auth = locator<AuthService>();
  FirebaseUser _user;
  final post = new Post();
  void initState() {
    setState(() {
      _user = _auth.activeUser;
    });

    // TODO: implement initState
    super.initState();
  }

  Future<File> imageFile;
  pickImageFromGallery(ImageSource source) {
    setState(() {
      imageFile = ImagePicker.pickImage(source: source);
    });
  }

  void _showCharttoomanyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Too Many"),
          content: new Text("Maxium charts is three!"),
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

  Widget showImage() {
    return FutureBuilder<File>(
      future: imageFile,
      builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
        if (snapshot.connectionState == ConnectionState.done &&
            snapshot.data != null) {
          return Image.file(
            snapshot.data,
            width: 200,
            height: 200,
          );
        } else if (snapshot.error != null) {
          return const Text(
            'Error Picking Image',
            textAlign: TextAlign.center,
          );
        } else {
          return const Text(
            'No Image Selected',
            textAlign: TextAlign.center,
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return _user == null
        ? Center(child: CircularProgressIndicator())
        : Scaffold(
            appBar: AppBar(
              title: Text(
                "Add Post",
                style: TextStyle(
                  fontFamily: 'Roboto Mono',
                ),
              ),
              backgroundColor: Colors.deepPurple,
              elevation: 0.0,
              actions: <Widget>[
                IconButton(
                  icon: Icon(Icons.photo),
                  onPressed: () => {pickImageFromGallery(ImageSource.gallery)},
                )
              ],
            ),
            body: Form(
              key: formkey,
              child: ListView(
                padding: const EdgeInsets.only(top: 10.0),
                children: <Widget>[
                  Row(children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Post Title",
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto Mono',
                            ),
                            border: OutlineInputBorder()),
                        onSaved: (val) => post.title = val,
                        validator: (val) {
                          if (val.isEmpty) {
                            return "Title filed can't be empty";
                          }
                        },
                      ),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                            labelText: "Subtitle(optional)",
                            labelStyle: TextStyle(
                              fontFamily: 'Roboto Mono',
                            ),
                            border: OutlineInputBorder()),
                        onSaved: (val) => post.subtitle = val,
                      ),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              labelText: "paste Youtube url (optional)",
                              labelStyle: TextStyle(fontFamily: 'Roboto Mono'),
                              border: OutlineInputBorder()),
                          onSaved: (val) => post.videoUrl = val,
                        ),
                      ),
                    ),
                  ]),
                  Row(children: <Widget>[
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          decoration: InputDecoration(
                              labelText: "Post Body",
                              labelStyle: TextStyle(fontFamily: 'Roboto Mono'),
                              border: OutlineInputBorder()),
                          onSaved: (val) => post.body = val,
                          validator: (val) {
                            if (val.isEmpty) {
                              return "Body field can't be empty";
                            }
                          },
                        ),
                      ),
                    ),
                  ]),
                  Row(
                    children: <Widget>[Expanded(child: showImage())],
                  ),
                ],
              ),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                insertPost();
                Navigator.pop(context);
                //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => HomePage()));
              },
              child: Icon(
                Icons.add,
                //color=Colors.white,
              ),
              backgroundColor: Colors.deepPurple,
              tooltip: "Add a post",
            ),
          );
  }

  Future<String> uploadFile(String folder, File _imageFile) async {
    StorageReference storageReference = FirebaseStorage.instance
        .ref()
        .child('$folder/${Path.basename(_imageFile.path)}}');
    StorageUploadTask uploadTask = storageReference.putFile(_imageFile);
    await uploadTask.onComplete;
    return await storageReference.getDownloadURL();
  }

  void insertPost() async {
    final FormState form = formkey.currentState;
    if (form.validate()) {
      form.save();
      post.date = DateTime.now().millisecondsSinceEpoch;
      post.uid = _user.uid;
      post.thumb = _user.photoUrl;
      post.author = _user.displayName;
      if (imageFile != null) {
        post.imgUrl = await uploadFile('post', await imageFile);
      }
      widget._postMgr.addCall(post);
      //  Navigator.pop(context);
    }
  }
}
