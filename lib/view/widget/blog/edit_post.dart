import 'package:flutter/material.dart';
import '../../../manager/postmanager.dart';
import '../../../service/locator.dart';
import '../../../service/models/post_model.dart';

class EditPost extends StatefulWidget {
  final Post post;
  final _postMgr = locator<PostManager>();
  EditPost(this.post);

  @override
  _EditPostState createState() => _EditPostState();
}

class _EditPostState extends State<EditPost> {
  final GlobalKey<FormState> formkey = new GlobalKey();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Edit Post",
          style: TextStyle(fontFamily: 'Roboto Mono'),
        ),
        elevation: 0.0,
        backgroundColor: Colors.deepPurple,
      ),
      backgroundColor: Color(0xffc8d9ff),
      body: Form(
        key: formkey,
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0),
              child: TextFormField(
                initialValue: widget.post.title,
                style: TextStyle(fontFamily: 'Roboto Mono'),
                decoration: InputDecoration(
                    labelStyle: TextStyle(fontFamily: 'Roboto Mono'),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Post Title",
                    border: OutlineInputBorder()),
                onSaved: (val) => widget.post.title = val,
                validator: (val) {
                  if (val.isEmpty) {
                    return "Title filed can't be empty";
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0),
              child: TextFormField(
                initialValue: widget.post.videoUrl,
                style: TextStyle(fontFamily: 'Roboto Mono'),
                decoration: InputDecoration(
                    labelStyle: TextStyle(fontFamily: 'Roboto Mono'),
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "paste video mp4 url",
                    border: OutlineInputBorder()),
                onSaved: (val) => widget.post.videoUrl = val,
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 8.0, right: 8.0),
              child: TextFormField(
                keyboardType: TextInputType.multiline,
                maxLines: null,
                initialValue: widget.post.body,
                style: TextStyle(fontFamily: 'Roboto Mono'),
                decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Post Body",
                    labelStyle: TextStyle(fontFamily: 'Roboto Mono'),
                    border: OutlineInputBorder()),
                onSaved: (val) => widget.post.body = val,
                validator: (val) {
                  if (val.isEmpty) {
                    return "Body feild can't be empty";
                  }
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          insertPost();
          Navigator.pop(context);
        },
        child: Icon(
          Icons.save,
          //color=Colors.white,
        ),
        backgroundColor: Colors.deepPurple,
        tooltip: "Save post",
      ),
    );
  }

  void insertPost() {
    final FormState form = formkey.currentState;
    if (form.validate()) {
      form.save();
      form.reset();
      widget.post.date = DateTime.now().millisecondsSinceEpoch;
      widget._postMgr.updateCall(widget.post, widget.post.postId);
    }
  }
}
