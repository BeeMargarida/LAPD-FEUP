import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainView(),
    );
  }
}


class HistoryItem {

  bool isExpanded;
  String event;
  String date;
  Image image; //TODO: add later

  HistoryItem({
    this.event,
    this.date,
    this.isExpanded
  });

  ExpansionPanelHeaderBuilder get headerBuilder {
    return (BuildContext context, bool isExpanded) {
      return Container(
          padding: EdgeInsets.only(left: 20.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(this.event),
              Text(this.date)
            ],
          )
      );
    };
  }

  close() {
    this.isExpanded = false;
  }

  Widget build() {

    return Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Text("Hello!!")
        ]
    );

  }

}

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => new _MainViewState();
}

class _MainViewState extends State<MainView> with TickerProviderStateMixin{

  TabController tabController;
  bool alarmOn;
  List<HistoryItem> _historyItems = [];

  _MainViewState() {

    //TODO: Get state of alarm
    this.alarmOn = false;

    this._getHistoryEntries();
  }

  void _toggleAlarm(bool value) {

    this.alarmOn = value;
    //TODO: Make request to API
  }

  Widget _getHistoryEntries() {

    //TODO: Get this from API

    _historyItems = [
      HistoryItem(
          event: "Turn On Alarm",
          date: "1/10/2019",
          isExpanded: false
      ),
      HistoryItem(
          event: "Turn Off Alarm",
          date: "2/10/2019",
          isExpanded: false
      ),
      HistoryItem(
          event: "Alarm!",
          date: "3/10/2019",
          isExpanded: false
      )
    ];
  }

  @override
  Widget build(BuildContext context) {
    tabController = new TabController(length: 2, vsync: this);

    var tabBarItem = new TabBar(
      tabs: [
        Tab(text: "Main"),
        Tab(text: "Live Feed"),
      ],
      labelColor: Colors.white,
      unselectedLabelColor: Colors.black,
      controller: tabController,
      indicatorColor: Colors.white,
    );

    var listItem = new ListView(
      scrollDirection: Axis.vertical,
      children: <Widget>[
        new Container(
            color: Colors.lightBlueAccent,
            height: 100.0,
            margin: EdgeInsets.only(top: 15.0, bottom: 10.0),
            child: new Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Text("Alarm", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20.0)),
                Switch(
                    activeColor: Colors.green,
                    value: this.alarmOn,
                    onChanged: _toggleAlarm
                ),
              ],
            )
        ),
        new Container(
          color: Colors.white,
          margin: EdgeInsets.only(top: 10.0, bottom: 15.0),
          height: 30.0,
          child: Center(
            child: Text("History", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20.0)),
          ),
        ),
        new ExpansionPanelList(
            expansionCallback: (int index, bool isExpanded) {
              setState(() {
                _historyItems[index].isExpanded = !isExpanded;
              });
            },
            children: _historyItems.map<ExpansionPanel>((HistoryItem item) {
              return ExpansionPanel(
                isExpanded: item.isExpanded,
                headerBuilder: item.headerBuilder,
                body: item.build(),
              );
            }).toList()
        )
      ],
    );

    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Home Security"),
          bottom: tabBarItem,
        ),
        body: new TabBarView(
          controller: tabController,
          children: [
            listItem,
            Container(color: Colors.grey),
          ],
        ),
      ),
    );
  }

}


