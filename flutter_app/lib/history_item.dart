import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/configs.dart';

class HistoryItem {
  bool isExpanded;
  String event;
  DateTime date;
  String imagePath;

  HistoryItem({this.event, this.date, this.imagePath, this.isExpanded});

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

  String getDateFormat() {
    return (this.date.day < 10
            ? '0' + this.date.day.toString()
            : this.date.day.toString()) +
        "/" +
        (this.date.month < 10
            ? '0' + this.date.month.toString()
            : this.date.month.toString()) +
        "/" +
        this.date.year.toString() +
        " " +
        (this.date.hour < 10
            ? '0' + this.date.hour.toString()
            : this.date.hour.toString()) +
        ":" +
        (this.date.minute < 10
            ? '0' + this.date.minute.toString()
            : this.date.minute.toString()) +
        ":" +
        (this.date.second < 10
            ? '0' + this.date.second.toString()
            : this.date.second.toString());
  }

  close() {
    this.isExpanded = false;
  }

  Widget build() {
    var path = "http://" + Configs.API_HOST + "/" + this.imagePath.trim();
    return Wrap(
        children: <Widget>[Image.network(path)]);
  }
}
