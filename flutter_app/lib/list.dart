import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/user_info.dart';
import 'package:flutter_app/history_item.dart';
import 'package:flutter_app/configs.dart';

class ListItems extends StatefulWidget {
  UserData loggedUserData;
  ListItems({Key key, this.loggedUserData}) : super(key: key);

  @override
  _ListState createState() => new _ListState();
}

class _ListState extends State<ListItems> {
  bool _alarmOn = false;
  List<HistoryItem> _historyItems = [];
  int _currHistoryPage = 1;
  int _itemsPerPage = 10;
  bool _loadingMore = false;
  bool _canLoadMore = true;
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    this._getAlarmState();
    this._getHistoryEntries();

    this._scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        if (_canLoadMore && !_loadingMore) {
          _currHistoryPage++;
          _getHistoryEntries();
        }
      }
    });
  }

  Future<void> _getAlarmState() async {
    var res = await http.get(Uri.http(Configs.API_HOST, '/alarm/status'),
        headers: {
          "Authorization": "Bearer " + widget.loggedUserData.token,
          "Accept": "application/json"
        });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      Map alarmState = jsonDecode(res.body);
      if (mounted) {
        setState(() {
          _alarmOn = alarmState["status"];
        });
      }
    }
  }

  Future<void> _toggleAlarm(bool value) async {
    var pathAlarm = '/alarm';

    if (this._alarmOn) {
      pathAlarm += '/stop';
    }

    var res = await http.post(Uri.http(Configs.API_HOST, pathAlarm), headers: {
      "Authorization": "Bearer " + widget.loggedUserData.token,
      "Accept": "application/json"
    });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      print(res.body);
      Map historyItem = jsonDecode(res.body);
      print(historyItem["createdAt"]["\$date"]);
      if (mounted) {
        setState(() {
          _alarmOn = value;

          _historyItems.insert(
              0,
              HistoryItem(
                  event: historyItem["type"],
                  imagePath: historyItem["imagePath"],
                  date: DateTime.fromMillisecondsSinceEpoch(
                      historyItem["createdAt"]["\$date"]),
                  isExpanded: false));
        });
      }
    }
  }

  Future<void> _getHistoryEntries() async {
    if (mounted) {
      setState(() {
        _loadingMore = true;
      });
    }

    var pageParams = {
      'page': _currHistoryPage.toString(),
      'per_page': _itemsPerPage.toString(),
    };

    var res = await http.get(Uri.http(Configs.API_HOST, '/history', pageParams),
        headers: {
          "Authorization": "Bearer " + widget.loggedUserData.token,
          "Accept": "application/json"
        });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      List historyItems = jsonDecode(res.body);
      if (historyItems.length < _itemsPerPage) _canLoadMore = false;
      if (mounted) {
        setState(() {
          historyItems.forEach((item) => {
                _historyItems.add(HistoryItem(
                    event: item["type"],
                    imagePath: item["imagePath"],
                    date: DateTime.fromMillisecondsSinceEpoch(
                        item["createdAt"]["\$date"]),
                    isExpanded: false))
              });
          _loadingMore = false;
        });
      }
      return Future<bool>.value(true);
    }
  }

  Future<void> _refreshHistory() async {
    if (mounted) {
      setState(() {
        _currHistoryPage = 1;
        _itemsPerPage = 10;
        _historyItems.clear();
        _loadingMore = true;
      });
    }
    await _getHistoryEntries();
    if (mounted) {
      setState(() {
        _canLoadMore = _historyItems.length < _itemsPerPage ? false : true;
      });
    }
  }

  List<Widget> getListItems(BuildContext context) {
    var listItems = [
      Container(
          color: Colors.lightBlueAccent,
          height: 100.0,
          alignment: Alignment.center,
          padding: EdgeInsets.only(left: 15.0, right: 15.0),
          child: SwitchListTile(
              title: Text("Alarm",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 30.0)),
              activeColor: Colors.green,
              value: _alarmOn,
              onChanged: _toggleAlarm)),
      Container(
        margin: EdgeInsets.only(top: 10.0, bottom: 15.0),
        height: 30.0,
        child: Center(
          child: Text("History",
              style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0)),
        ),
      ),
      Flexible(
        child: RefreshIndicator(
          onRefresh: _refreshHistory,
          child: ListView.builder(
              controller: _scrollController,
              shrinkWrap: true,
              itemCount: _historyItems.length,
              itemBuilder: (context, i) {
                if (_historyItems[i].event == "Alarm On" ||
                    _historyItems[i].event == "Alarm Off") {
                  return Container(
                      color: Colors.white,
                      padding: EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Text(_historyItems[i].event),
                          Text(_historyItems[i].getDateFormat())
                        ],
                      ));
                } else {
                  return Container(
                      color: Colors.white,
                      child: new ExpansionTile(
                        backgroundColor: Colors.white,
                        title: _historyItems[i].headerBuilder(
                            context, _historyItems[i].isExpanded),
                        children: <Widget>[
                          _historyItems[i].build(),
                        ],
                      ));
                }
              }),
        ),
      )
    ];

    if (_loadingMore)
      listItems.add(CircularProgressIndicator(
        value: null,
      ));

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
      children: getListItems(context),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
