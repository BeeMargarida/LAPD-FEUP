import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class HistoryItem {
  bool isExpanded;
  String event;
  DateTime date;
  String imagePath; //TODO: add later

  HistoryItem({this.event, this.date, this.isExpanded});

  HistoryItem.fromJson(Map<String, dynamic> json)
      : event = json['type'],
        date = json['createdAt'],
        imagePath = json['imagePath'],
        isExpanded = false;

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text(this.event), Text(this.getDateFormat())],
          ));
    };
  }

  String getDateFormat() {
    return (this.date.day < 0 ? '10' + this.date.day.toString() : this.date.day.toString()) + "/" +
     (this.date.month < 0 ? '10' + this.date.month.toString() : this.date.month.toString()) + "/" + 
     this.date.year.toString() + " " + (this.date.hour < 0 ? '10' + this.date.hour.toString() : this.date.hour.toString()) + ":" + 
     (this.date.minute < 0 ? '10' + this.date.minute.toString() : this.date.minute.toString()) + ":" + 
     (this.date.second < 0 ? '10' + this.date.second.toString() : this.date.second.toString());
  }

  close() {
    this.isExpanded = false;
  }

  Widget build() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[Image.network(this.imagePath)]
    );
  }
}