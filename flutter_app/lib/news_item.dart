import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/configs.dart';
import 'package:html/parser.dart' as parser;
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart' as xml;


class NewsItem {
  String title;
  String date;
  List<String> links;
  String body;
  String image;

  NewsItem(xml.XmlElement article){
    this.links = [];

    this.title = article.findElements('title').first.text;
    var description = article.findElements('description').first.text;
    var doc = parser.parse(description);
    var docBody = doc.querySelector('body');

    //Date
    var dateElem = docBody.children[0];
    this.date = dateElem.text;

    //Body
    this.body = docBody.children[1].text;
    this.body = body.replaceAll(RegExp(r'/Corpo: *\n?'), '');

    //Links
    var docLinks = docBody.children[1].querySelectorAll('a');
    for(var docLink in docLinks){
      print('Link: ');
      print("http://www.psp.pt${docLink.attributes['href']}");
      this.links.add("http://www.psp.pt${docLink.attributes['href']}");
    }

    //Img
    print('Doc Length: ${docBody.children.length}');
    if(docBody.children.length > 2){
      var imgElem = docBody.children[2];
      this.image = imgElem.querySelector('a').attributes['href'];
    }

    print('Title: ');
    print(title);
    print('News Date: ');
    print(date);
    print('News Body: ');
    print(body);
    print('Img: ');
    print(image);
  }

  /*
  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return Container(
          padding: EdgeInsets.all(10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(this.event,
                  style: this.event == "Alert!"
                      ? TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15.0)
                      : TextStyle(color: Colors.black, fontSize: 15.0)),
              Text(this.getDateFormat(),
                  style: this.event == "Alert!"
                      ? TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15.0)
                      : TextStyle(color: Colors.black, fontSize: 15.0))
            ],
          ));
    };
  }
  */

  _launchUrl(String url) async{
    if (await canLaunch(url)) {
    await launch(url);
    } else {
    throw 'Could not launch $url';
    }
  }

  List<Widget> getItems(){
    var items = [
      Text(title),
      Text(date),
      Text(body),
    ];

    /*
    for(var link in links){
      items.add(RaisedButton(
        onPressed: _launchUrl(link),
      ));
    }
    */
    return items;
  }

  Widget build() {
    return Wrap(
        children: getItems(),
    );
  }
}
