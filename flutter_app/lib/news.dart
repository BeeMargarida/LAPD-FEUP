import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:xml/xml.dart' as xml;
import 'package:flutter/services.dart' show rootBundle;
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

  @override
  void initState() {
    super.initState();
    print('init news');
    this._getNews().catchError((err) {
      print(err.toString());
      showInSnackBar(err.toString());
    });
  }

  void showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(SnackBar(
        content: Text(value)
    ));
  }

  Future<String> _getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  Future<void> _getNews() async {
    /*var res = await http.get(Configs.PSP_RSS);
    if (res.statusCode != 200)
      throw 'Unsuccessful fetch';
    var decodedRss = utf8.decode(res.body.codeUnits);
    print(decodedRss);
    */

    var decodedRss = await _getFileData('assets/psp.xml');

    var split = decodedRss.split('\n');
    var spitClean = split.sublist(1, split.length);
    var rss = spitClean.join('\n');

    var feed = xml.parse(rss);

    List<NewsItem> items = [];
    var news = feed.findAllElements("item");
    for (var article in news) {
      items.add(NewsItem(article));
    }

    print('Items length: ${items.length}');
    if (mounted) {
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
    return Column (
        children: [
          this._newsReady ?
            Flexible(
              child:
                RefreshIndicator(
                onRefresh: _refreshFeed,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _newsItems.length,
                  itemBuilder: (context, i) {
                    return Card(
                      color: Colors.white,
                      child: GestureDetector(
                        onTap: (){
                          Navigator.pushNamed(
                            context,
                            '/news',
                            arguments: _newsItems[i]
                          );
                        },
                        child: _newsItems[i].buildPreview(context),
                      )
                    );
                  }),
              )
          )
          : Center(
              child:
                CircularProgressIndicator(
                  value: null,
              ),
          ),
        ]
    );
  }
}
