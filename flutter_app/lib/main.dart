import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/configs.dart';
import 'package:flutter_app/history_item.dart';

void main() => runApp(MyApp());

LoginData _userLoginData = new LoginData();
UserData _loggedUserData = new UserData();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/': (context) => MainView(),
          '/login': (context) => LogInView()
        });
  }
}

class LoginData {
  String email = '';
  String password = '';
}

class UserData {
  LoginData loginData;
  String token = '';
}

class LogInView extends StatefulWidget {
  @override
  _LogInViewState createState() => new _LogInViewState();
}

class _LogInViewState extends State<LogInView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  Future<bool> login() async {
    var res = await http.post(
        Uri.http(Configs.API_HOST, Configs.API_PATH + 'auth/signin'),
        body: {
          "email": _userLoginData.email,
          "password": _userLoginData.password
        });

    Map<String, dynamic> decodedBody = jsonDecode(res.body);
    _loggedUserData.loginData = _userLoginData;
    _loggedUserData.token = decodedBody['token'];

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else
      return Future<bool>.value(true);
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

    RegExp regExp = new RegExp(p);

    return regExp.hasMatch(em);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Text(
            'SecurityIO',
            textAlign: TextAlign.center,
          ),
          automaticallyImplyLeading: false,
        ),
        body: Builder(
            builder: (context) => Form(
                key: _formKey,
                child: SizedBox.expand(
                  child: FractionallySizedBox(
                    alignment: Alignment.topCenter,
                    widthFactor: 0.8,
                    heightFactor: 0.55,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        Text('Login',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            )),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "your@email.com",
                            icon: Icon(
                              Icons.email,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                          ),
                          validator: (value) {
                            if (value.isEmpty || !isEmail(value)) {
                              return 'Please enter a valid email';
                            }
                          },
                          onSaved: (String value) {
                            _userLoginData.email = value;
                          },
                        ),
                        TextFormField(
                          decoration: InputDecoration(
                            hintText: "Password",
                            icon: Icon(
                              Icons.vpn_key,
                            ),
                            border: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.black)),
                          ),
                          obscureText: true,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a password';
                            }
                          },
                          onSaved: (String value) {
                            _userLoginData.password = value;
                          },
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: RaisedButton(
                            onPressed: () {
                              // Validate form
                              if (_formKey.currentState.validate()) {
                                // Dismiss keyboard
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                _formKey.currentState.save();

                                login().then((bool res) {
                                  if (res) {
                                    /*Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainView()),
                                    );*/
                                    Navigator.pushReplacementNamed(
                                        context, "/");
                                  } else {
                                    Scaffold.of(context).showSnackBar(SnackBar(
                                        content: Text('Invalid credentials')));
                                  }
                                });
                              }
                            },
                            child: Text('Submit'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ))));
  }
}

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => new _MainViewState();
}

class _MainViewState extends State<MainView> with TickerProviderStateMixin {
  TabController tabController;
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
    var res = await http
        .get(Uri.http(Configs.API_HOST, Configs.API_PATH + 'alarm/'), headers: {
      "Authorization": "Bearer " + _loggedUserData.token,
      "Accept": "application/json"
    });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      Map alarmState = jsonDecode(res.body);
      print(alarmState.toString());
      setState(() {
        _alarmOn = alarmState["alarm"];
      });
    }
  }

  Future<void> _toggleAlarm(bool value) async {
    var pathAlarm = 'alarm/';

    if (!this._alarmOn) {
      pathAlarm += 'start';
    } else {
      pathAlarm += 'stop';
    }

    var res = await http.post(
        Uri.http(Configs.API_HOST, Configs.API_PATH + pathAlarm),
        headers: {
          "Authorization": "Bearer " + _loggedUserData.token,
          "Accept": "application/json"
        });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {

      Map historyItem = jsonDecode(res.body);
      setState(() {
        _alarmOn = value;
        // TODO: Not working!!
        // _historyItems.add(HistoryItem(
        //     event: historyItem["type"],
        //     date: DateTime.parse(historyItem["createdAt"]),
        //     isExpanded: false));
      });

    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getHistoryEntries() async {
    setState(() {
      _loadingMore = true;
    });

    var pageParams = {
      'page': _currHistoryPage.toString(),
      'per_page': _itemsPerPage.toString(),
    };

    var res = await http.get(
        Uri.http(Configs.API_HOST, Configs.API_PATH + 'history', pageParams),
        headers: {
          "Authorization": "Bearer " + _loggedUserData.token,
          "Accept": "application/json"
        });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      List historyItems = jsonDecode(res.body);
      if (historyItems.length < _itemsPerPage) _canLoadMore = false;
      setState(() {
        historyItems.forEach((item) => {
              _historyItems.add(HistoryItem(
                  event: item["type"],
                  date: DateTime.parse(item["createdAt"]),
                  isExpanded: false))
            });
        _loadingMore = false;
      });
      return Future<bool>.value(true);
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
        child: ListView.builder(
            controller: _scrollController,
            shrinkWrap: true,
            itemCount: _historyItems.length,
            itemBuilder: (context, i) {
              if (_historyItems[i].event == "Turn On Alarm" ||
                  _historyItems[i].event == "Turn Off Alarm") {
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
                      title: _historyItems[i]
                          .headerBuilder(context, _historyItems[i].isExpanded),
                      children: <Widget>[
                        _historyItems[i].build(),
                      ],
                    ));
              }
            }),
      ),
    ];

    if (_loadingMore)
      listItems.add(CircularProgressIndicator(
        value: null,
      ));

    return listItems;
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

    var listItem = new Column(
      children: getListItems(context),
    );

    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Home Security"),
          actions: <Widget>[
            IconButton(
              icon: Icon(FontAwesomeIcons.signOutAlt),
              onPressed: () {
                Navigator.pushReplacementNamed(context, "/login");
              },
            ),
          ],
          bottom: tabBarItem,
          automaticallyImplyLeading: false,
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
