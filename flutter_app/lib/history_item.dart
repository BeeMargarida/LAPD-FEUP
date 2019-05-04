import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_app/configs.dart';

class HistoryItem {
  bool isExpanded;
  String event;
  DateTime date;
  String imagePath; //TODO: add later

  HistoryItem({this.event, this.date, this.imagePath, this.isExpanded});

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
    return (this.date.day < 10 ? '0' + this.date.day.toString() : this.date.day.toString()) + "/" +
     (this.date.month < 10 ? '0' + this.date.month.toString() : this.date.month.toString()) + "/" + 
     this.date.year.toString() + " " + (this.date.hour < 10 ? '0' + this.date.hour.toString() : this.date.hour.toString()) + ":" + 
     (this.date.minute < 10 ? '0' + this.date.minute.toString() : this.date.minute.toString()) + ":" + 
     (this.date.second < 10 ? '0' + this.date.second.toString() : this.date.second.toString());
  }

  close() {
    this.isExpanded = false;
  }

  Widget build() {
    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[Image.network("http://" + Configs.API_HOST + "/" + this.imagePath.replaceAll("assets/", ""))]
    );
  }
}