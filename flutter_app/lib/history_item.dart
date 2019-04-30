import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HistoryItem {
  bool isExpanded;
  String event;
  String date;
  Image image; //TODO: add later

  HistoryItem({this.event, this.date, this.isExpanded});

  HistoryItem.fromJson(Map<String, dynamic> json)
      : event = json['type'],
        date = json['createdAt'],
        image = json['imagePath'],
        isExpanded = false;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return Container(
          padding: EdgeInsets.only(left: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text(this.event), Text(this.date)],
          ));
    };
  }

  close() {
    this.isExpanded = false;
  }

  Widget build() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[Text("Hello!!")]);
  }
}