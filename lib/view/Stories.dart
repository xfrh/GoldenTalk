import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../manager/postmanager.dart';
import '../service/auth_service.dart';
import '../service/locator.dart';
import '../service/models/post_model.dart';
import '../view/widget/blog/add_post.dart';
import '../view/widget/blog/viewPost.dart';

class StoriesPage extends StatefulWidget {
  StoriesPage(this.listType);
  final String listType;
  final _auth = locator<AuthService>();
  final _postmgr = locator<PostManager>();
  @override
  _StoriesPageState createState() => _StoriesPageState();
}

class _StoriesPageState extends State<StoriesPage> {
  bool _status = false;

  Widget _builditem(DocumentSnapshot document) {
    var data = Post.FromSnapShot(document);
    return ListTile(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => PostView(data)));
      },
      leading: CircleAvatar(
        backgroundImage: new CachedNetworkImageProvider(data.thumb),
      ),
      title: Text(
        data.title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
      subtitle: Column(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Text(
            data.body,
            overflow: TextOverflow.clip,
            maxLines: 3,
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.comment),
              Icon(Icons.repeat),
              Icon(Icons.favorite_border),
              Icon(Icons.share),
            ],
          )
        ],
      ),
    );
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
            leading: new IconButton(
                icon: const Icon(Icons.search), onPressed: () {}),
          ),
          body: StreamBuilder(
            stream: Firestore.instance
                .collection('Posts')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Container(
                  child: Text('no blog posted yet'),
                );
              return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (context, index) =>
                      _builditem(snapshot.data.documents[index]));
            },
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                  context, MaterialPageRoute(builder: (context) => AddPost()));
            },
            child: Icon(
              Icons.edit,
              //color=Colors.white,
            ),
            backgroundColor: Colors.deepPurple,
            tooltip: "Add a post",
          ),
        ));
  }
}
