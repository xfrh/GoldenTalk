import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class DetailScreen extends StatelessWidget {
  static const routeName = '/selectedImage';

  @override
  Widget build(BuildContext context) {
    String url = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: 'imageHero',
            child: CachedNetworkImage(
              imageUrl: url,
              placeholder: (context, builder) =>
                  new CircularProgressIndicator(),
              errorWidget: (context, string, dynamic) => new Icon(Icons.error),
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
