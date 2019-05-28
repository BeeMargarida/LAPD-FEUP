import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:html/parser.dart' as parser;
import 'dart:convert' show utf8, base64;
import 'package:url_launcher/url_launcher.dart';
import 'package:xml/xml.dart' as xml;

class NewsItem {
  String title;
  String date;
  List<String> links;
  String body;
  String image;

  NewsItem(xml.XmlElement article){
    links = [];

    title = article.findElements('title').first.text;
    var description = article.findElements('description').first.text;
    var doc = parser.parse(description);
    var docBody = doc.querySelector('body');

    //Date
    var dateElem = docBody.children[0];
    date = dateElem.text;

    //Body
    body = docBody.children[1].text;
    body = body.replaceAll(RegExp(r'^Corpo: *\n?'), '');

    //Links
    var docLinks = docBody.children[1].querySelectorAll('a');
    for(var docLink in docLinks){
      var url = docLink.attributes['href'];

      if(url.contains('http'))
        links.add(url);
      else
        links.add("http://www.psp.pt${url}");
    }

    //Img
    if(docBody.children.length > 2){
      var imgElem = docBody.children[2];
      this.image = imgElem.querySelector('a').attributes['href'];
    }

    /*
    print('Title: ');
    print(title);
    print('News Date: ');
    print(date);
    print('News Body: ');
    print(body);
    print('Img: ');
    print(image);
    */
  }

  _launchUrl(String url) async{
    if (await canLaunch(url)) {
    await launch(url);
    } else {
    throw 'Could not launch $url';
    }
  }

  Widget _getImage(){
    if(image != null)
      return Image.network(image);
    else
      return Image(
        image: AssetImage('assets/psp_logo.jpg'),
      );
  }

  List<Widget> getItems(){
    var items = [
      Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
            )
          ),
      ),
      Text(
        date,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black45,
        )
      ),
      Padding(
        padding: EdgeInsets.all(15.0),
        child: _getImage(),
      ),
      Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          body,
          style: TextStyle(
            fontSize: 15,
          )
        ),
      ),
    ];

    if(links.length > 0) {
      items.add(
        Padding(
          padding: EdgeInsets.all(10.0),
          child: Text(
            'Related links: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20.0,
            )
          )
        )
      );

      for (var link in links) {
        items.add(

          GestureDetector(
            onTap: (){
              _launchUrl(link);
            },
            child: Padding(
                padding: EdgeInsets.only(
                  left: 15.0,
                  bottom: 10.0,
                ),
                child: Text(
                    link,
                    style: TextStyle(
                      color: Colors.blue,
                    )
                )
            )
          )
        );
      }
    }

    return items;
  }

  Widget build() {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: getItems(),
    );
  }

  Widget buildPreview(BuildContext context) {
    return Container(
        child: Row(
          children: <Widget>[
            Container(
              width: MediaQuery.of(context).size.width*0.35,
              padding: EdgeInsets.all(10.0),
              child: _getImage(),
              height: 100,
              //width: 120,
            ),
            Container(
              width: MediaQuery.of(context).size.width*0.6,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    )
                  ),
                  Text(date),
                ],
              )
            ),
          ]
        )
    );
  }
}
