import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:html/dom.dart' as dom;
import 'package:xml/xml.dart' as xml;
import 'package:flutter_app/configs.dart';
import 'package:flutter_app/user_info.dart';
import 'package:flutter_app/news_item.dart';

class News extends StatefulWidget {
  UserData loggedUserData;
  News({Key key, this.loggedUserData}) : super(key: key);

  @override
  _NewsState createState() => new _NewsState ();
}

class _NewsState  extends State<News> {
  bool _newsReady = false;
  List<NewsItem> _newsItems = [];
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    print('init news');
    this._getNews().catchError((err) {
      showInSnackBar(err.toString());
    });

    this._scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        print('WTF');
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(value)
    ));
  }

  Future<void> _getNews() async {
    var res = await http.get(Configs.PSP_RSS);
    if(res.statusCode != 200)
      throw 'Unsuccessful fetch';

    var split = res.body.split('\n');
    var spitClean = split.sublist(1,split.length);
    var rss = spitClean.join('\n');

    var feed = xml.parse(rss);

    List<NewsItem> items = [];
    var news = feed.findAllElements("item");
    for(var article in news){
      items.add(NewsItem(article));
    }

    print('Items length: ${items.length}');
    if(mounted) {
      setState(() {
        _newsItems = items;
        _newsReady = true;
      });
    }
  }

  Future<void> _refreshFeed() async {
    _getNews();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      children: <Widget>[
        this._newsReady
            ? RefreshIndicator(
            onRefresh: _refreshFeed,
            child: ListView.builder(
                controller: _scrollController,
                shrinkWrap: true,
                itemCount: _newsItems.length,
                itemBuilder: (context, i) {
                    return Container(
                        color: Colors.white,
                        padding: EdgeInsets.all(20.0),
                        child: Column(
                          children: <Widget>[
                            _newsItems[i].build(),
                          ],
                        ));
                }),
          )
            : CircularProgressIndicator(
          value: null,
        )
      ],
    );
  }
}
