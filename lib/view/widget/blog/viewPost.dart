import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import '../../../manager/postmanager.dart';
import '../../../service/auth_service.dart';
import '../../../service/locator.dart';
import '../../../service/models/post_model.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../detailimage_screen.dart';

class PostView extends StatefulWidget {
  PostView(this.post);
  final Post post;
  final _auth = locator<AuthService>();
  final _postMgr = locator<PostManager>();
  @override
  _PostViewState createState() => _PostViewState();
}

class _PostViewState extends State<PostView> {
  YoutubePlayerController _controller;
  List<Widget> imageSliders;
  @override
  void initState() {
    if (widget.post.videoUrl != null && widget.post.videoUrl != '') {
      setState(() {
        _controller = YoutubePlayerController(
          initialVideoId: YoutubePlayer.convertUrlToId(widget.post.videoUrl),
          flags: YoutubePlayerFlags(
            autoPlay: true,
            mute: false,
          ),
        );
      });
    }
    if (widget.post.charts != null && widget.post.charts.length > 0) {
      setupImageSliders();
    }
    // TODO: implement initState
    super.initState();
  }

  void setupImageSliders() {
    imageSliders = List<Widget>();
    widget.post.charts.forEach((key, value) {
      setState(() {
        imageSliders.add(GestureDetector(
            onTap: () => {
                  Navigator.pushNamed(context, DetailScreen.routeName,
                      arguments: value)
                },
            child: Container(
              margin: EdgeInsets.all(5.0),
              child: ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  child: Stack(
                    children: <Widget>[
                      Image.network(value, fit: BoxFit.cover, width: 1000.0),
                      Positioned(
                        bottom: 0.0,
                        left: 0.0,
                        right: 0.0,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color.fromARGB(200, 0, 0, 0),
                                Color.fromARGB(0, 0, 0, 0)
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 20.0),
                          child: Text(
                            key,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )),
            )));
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
          title: Text("Feed"),
          titleSpacing: -1.0,
          leading: BackButton(
            color: Colors.white,
          )),
      body: ListView.builder(
        itemCount: 1,
        itemBuilder: (context, position) {
          return Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: new Hero(
                        tag: widget.post.uid,
                        child: new CircleAvatar(
                          backgroundImage:
                              CachedNetworkImageProvider(widget.post.thumb),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                      child: RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                        text: widget.post.author,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 18.0,
                                            color: Colors.black),
                                      ),
                                      TextSpan(
                                          text: timeago.format(DateTime
                                              .fromMillisecondsSinceEpoch(
                                                  widget.post.date)),
                                          style: TextStyle(
                                              fontSize: 16.0,
                                              color: Colors.grey))
                                    ]),
                                    overflow: TextOverflow.ellipsis,
                                  )),
                                  flex: 5,
                                ),
                                widget._auth.activeUser.uid == widget.post.uid
                                    ? GestureDetector(
                                        onTap: () {
                                          widget._postMgr
                                              .removeCall(widget.post.postId);
                                          Navigator.pop(context);
                                        },
                                        child: Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.only(
                                                right: 4.0),
                                            child: Icon(
                                              Icons.restore_from_trash,
                                              color: Colors.grey,
                                            ),
                                          ),
                                          flex: 1,
                                        ))
                                    : Container(),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              widget.post.title,
                              style: TextStyle(
                                  fontSize: 18.0, fontWeight: FontWeight.bold),
                            ),
                          ),
                          widget.post.subtitle != null &&
                                  widget.post.subtitle != ''
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Text(
                                    widget.post.subtitle,
                                    style: TextStyle(fontSize: 9.0),
                                  ),
                                )
                              : Container(),
                          widget.post.imgUrl != null && widget.post.imgUrl != ''
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, DetailScreen.routeName,
                                            arguments: widget.post.imgUrl);
                                      },
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image(
                                            image:
                                                new CachedNetworkImageProvider(
                                                    widget.post.imgUrl),
                                          )),
                                    ),
                                  ),
                                )
                              : Container(),
                          _controller != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: YoutubePlayer(
                                    controller: _controller,
                                    liveUIColor: Colors.amber,
                                  ),
                                )
                              : Container(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4.0),
                            child: Text(
                              widget.post.body,
                              style: TextStyle(fontSize: 18.0),
                            ),
                          ),
                          widget.post.chart != null
                              ? Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Card(
                                    clipBehavior: Clip.antiAlias,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.pushNamed(
                                            context, DetailScreen.routeName,
                                            arguments: widget.post.chart);
                                      },
                                      child: ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                          child: Image(
                                            image:
                                                new CachedNetworkImageProvider(
                                                    widget.post.chart),
                                          )),
                                    ),
                                  ),
                                )
                              : Container(),
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Divider(),
              widget.post.charts != null
                  ? Container(
                      child: Column(
                      children: <Widget>[
                        CarouselSlider(
                          options: CarouselOptions(
                            autoPlay: true,
                            aspectRatio: 2.0,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                          ),
                          items: imageSliders,
                        ),
                      ],
                    ))
                  : Container(),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}
