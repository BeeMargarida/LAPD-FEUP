import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/news_item.dart';

class NewsView extends StatelessWidget {

  NewsView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final NewsItem newsItem = ModalRoute.of(context).settings.arguments;

    return Scaffold(
        appBar: AppBar(
            title: Text(
              "News",
              textAlign: TextAlign.center,
            )
        ),
        body: ListView(
          children: [
            newsItem.build(),
          ]
        )
    );
  }
}
