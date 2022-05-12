import 'package:flutter/material.dart';


class ArticlesShowcase extends StatelessWidget {
  ArticlesShowcase(this.articles);
  final List<String> articles;
  @override
  Widget build(BuildContext context) {
  var textTheme = Theme.of(context).textTheme;
  return new ListView.builder
  (
    itemCount: articles.length,
    itemBuilder: (BuildContext ctxt, int index) {
     return new Text(
        articles[index],
        style: textTheme.title.copyWith(color: Colors.white),
      );
    }
  );
   
  }
}