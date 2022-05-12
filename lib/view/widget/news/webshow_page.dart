import 'package:GoldenTalk/service/models/post_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;

class WebShowPage extends StatefulWidget {
  WebShowPage({@required this.selectedUrl});
  final selectedUrl;
  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebShowPage> {
  final String _pre_site = 'https://www.kitco.com';
  Future<Post> getNewsContent() async {
    String _url = "";
    if (widget.selectedUrl.startsWith('/'))
      _url = _pre_site + widget.selectedUrl;
    else
      _url = widget.selectedUrl;
    http.Response response = await http.get(_url);
    dom.Document document = parser.parse(response.body);
    var title = document.getElementById('article-info-title').text;
    var thumb_elements = document.getElementsByClassName('article-info-author');
    var thumb = thumb_elements
        .map((e) => e.getElementsByTagName("img")[0].attributes['src'])
        .toList()[0];
    var author_elements = document.getElementsByClassName('author-description');
    var author = author_elements
        .map((e) => e.getElementsByTagName("a")[0].attributes['href'])
        .toList()[0];
    var body_elements = document.getElementsByClassName("article-content");
    var body = body_elements
        .map((e) => e.getElementsByTagName("articleBody")[0].attributes['p'])
        .toList()[0];
    Post _post = Post();
    _post.author = author;
    _post.thumb = thumb;
    _post.body = body;
    return _post;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        titleSpacing: -1.0,
        leading: new BackButton(color: Colors.white),
      ),
      body: FutureBuilder<Post>(
        future: getNewsContent(),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return Center(child: CircularProgressIndicator());
          return ListView.builder(
            itemCount: 1,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(snapshot.data.title),
                subtitle: Text(snapshot.data.body),
              );
            },
          );
        },
      ),
    );
  }
}
