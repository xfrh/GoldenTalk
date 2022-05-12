import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as parser;
import 'package:html/dom.dart' as dom;
import '../../../view/widget/blog/viewPost.dart';
import '../../../service/models/post_model.dart';
import 'webshow_page.dart';

class WebViewPage extends StatefulWidget {
  static const routeName = '/selectedNewsType';
  @override
  _WebviewPageState createState() => _WebviewPageState();
}

class _WebviewPageState extends State<WebViewPage> {
  String newType;

  Future<List<dom.Element>> getWebData() async {
    switch (newType) {
      case "Global News":
        http.Response response = await http
            .get('https://www.kitco.com/market/marketnews.html#gold-news');
        dom.Document document = parser.parse(response.body);
        return document.getElementsByClassName('gold');
      case "Market News":
        http.Response response = await http
            .get('https://www.kitco.com/market/marketnews.html#market-news');
        dom.Document document = parser.parse(response.body);
        return document.getElementsByClassName('market');
        break;
      case "Street Talks":
        http.Response response = await http.get(
            'https://www.kitco.com/market/marketnews.html#streettalk-news');
        dom.Document document = parser.parse(response.body);
        return document.getElementsByClassName('streettalk');
        break;
    }
  }

  Future<Post> getWebDetail(String _url) async {
    Post _post = Post();
    String _pre_site = 'https://www.kitco.com';
    if (_url.startsWith('/')) {
      _url = _pre_site + _url;
    }
    http.Response response = await http.get(_url);
    dom.Document document = parser.parse(response.body);
    dom.Element e_title = document.getElementById('article-info-title');
    if (e_title.children.length > 0) {
      _post.title = e_title.getElementsByTagName('h1')[0].text;
    }
    final authorInfos = document.getElementsByClassName('article-info-author');

    authorInfos.forEach((e) {
      _post.thumb = e.getElementsByTagName('img')[0].attributes['src'].trim();
      _post.author = e
          .getElementsByClassName('author-description ')[0]
          .getElementsByTagName('a')[0]
          .text;
    });
    final videoInfos = document.getElementsByClassName('embed-container');

    videoInfos.forEach((e) {
      _post.videoUrl =
          e.getElementsByTagName('iframe')[0].attributes['src'].trim();
    });
    final ebodies = document.getElementsByClassName('article-content');
    _post.body = '';
    ebodies.forEach((element) {
      final ps = element.getElementsByTagName('p');
      ps.forEach((e) {
        _post.body += e.text + "\n";
      });
    });

    _post.uid = _url.substring(_url.lastIndexOf('/') + 1, _url.length - 4);
    _post.date = DateTime.now().millisecondsSinceEpoch;
    return _post;
  }

  @override
  Widget build(BuildContext context) {
    newType = ModalRoute.of(context).settings.arguments;
    return Scaffold(
        appBar: new AppBar(
          title: new Text(
            newType,
            style: new TextStyle(color: const Color(0xFFFFFFFF)),
          ),
          titleSpacing: -1.0,
          leading: new BackButton(color: Colors.white),
        ),
        body: FutureBuilder<List<dom.Element>>(
            future: getWebData(),
            builder: (context, snapshot) {
              if (!snapshot.hasData)
                return Center(child: CircularProgressIndicator());
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  dom.Document document =
                      parser.parse(snapshot.data[index].outerHtml);
                  var source = document.getElementsByTagName('a')[0].outerHtml;
                  int startIndex = source.indexOf('href');
                  int endIndex = source.indexOf('id');
                  var url = document
                      .getElementsByTagName('a')[0]
                      .outerHtml
                      .substring(startIndex, endIndex)
                      .replaceAll('href=', '')
                      .replaceAll('\"', '')
                      .trim();
                  var title =
                      document.getElementsByClassName('article-title')[0].text;
                  var subtitle =
                      document.getElementsByClassName('post-date')[0].text;
                  return new ListTile(
                    onTap: () async {
                      // Navigator.pushNamed(
                      //   context,
                      //   WebShowPage.routeName,
                      //   arguments: url,
                      // )
                      var data = await getWebDetail(url);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PostView(data)));
                    },
                    title: new Text(title),
                    subtitle: new Text(subtitle),
                  );
                  // return Center(
                  //     child: Html(
                  //   data: snapshot.data[index].outerHtml,
                  //   onLinkTap: (url) {
                  //     Navigator.pushNamed(
                  //       context,
                  //       WebShowPage.routeName,
                  //       arguments: url,
                  //     );
                  //   },
                  //   onImageTap: (src) {},
                  //   style: {
                  //     'span': Style(
                  //         fontWeight: FontWeight.normal,
                  //         color: Colors.grey,
                  //         fontSize: FontSize.percent(50)),
                  //     'a': Style(
                  //         textDecoration: TextDecoration.none,
                  //         fontSize: FontSize.percent(70))
                  //   },
                  // ));
                },
              );
            }));
  }
}
