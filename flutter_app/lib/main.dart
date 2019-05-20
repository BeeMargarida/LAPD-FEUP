import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/configs.dart';
import 'package:flutter_app/history_item.dart';
import 'package:flutter_app/livestream.dart';
import 'package:flutter_app/news.dart';
import 'package:flutter_app/user_info.dart';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';

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

class LogInView extends StatefulWidget {
  @override
  _LogInViewState createState() => new _LogInViewState();
}

class _LogInViewState extends State<LogInView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  String firebaseToken = "";
  String errorMessage = "";

  Future<bool> _login() async {
    firebaseCloudMessaging_Listeners();

    var res = await http.post(Uri.http(Configs.API_HOST, '/login'), headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded"
    }, body: {
      "email": _userLoginData.email,
      "password": _userLoginData.password,
      "firebaseToken": firebaseToken
    });

    if (res.statusCode != 200){
      errorMessage = res.body;
      return Future<bool>.value(false);
    }
    else {
      Map<String, dynamic> decodedBody = jsonDecode(res.body);
      _loggedUserData.loginData = _userLoginData;
      _loggedUserData.token = decodedBody['token'];

      return Future<bool>.value(true);

    }
  }

  void firebaseCloudMessaging_Listeners() {

    _firebaseMessaging.getToken().then((token){
      firebaseToken = token;
      print(token);
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print('on message $message');
      },
      onResume: (Map<String, dynamic> message) async {
        print('on resume $message');
      },
      onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
      },
    );
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

                                _login().then((bool res) {
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
                                        content: Text(errorMessage)));
                                    print(errorMessage);
                                  }
                                });/*.catchError((err) {
                                  Scaffold.of(context).showSnackBar(SnackBar(
                                      content: Text(err.toString())));
                                });
                                */
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
    var res = await http.get(Uri.http(Configs.API_HOST, '/alarm/status'),
        headers: {
          "Authorization": "Bearer " + _loggedUserData.token,
          "Accept": "application/json"
        });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      Map alarmState = jsonDecode(res.body);
      if(mounted) {
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
      "Authorization": "Bearer " + _loggedUserData.token,
      "Accept": "application/json"
    });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      print(res.body);
      Map historyItem = jsonDecode(res.body);
      print(historyItem["createdAt"]["\$date"]);
      if(mounted){
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

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _getHistoryEntries() async {
    if(mounted) {
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
          "Authorization": "Bearer " + _loggedUserData.token,
          "Accept": "application/json"
        });

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      List historyItems = jsonDecode(res.body);
      if (historyItems.length < _itemsPerPage) _canLoadMore = false;
      if(mounted) {
        setState(() {
          historyItems.forEach((item) =>
          {
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
    if(mounted) {
      setState(() {
        _currHistoryPage = 1;
        _itemsPerPage = 10;
        _historyItems.clear();
        _loadingMore = true;
      });
    }
    await _getHistoryEntries();
    if(mounted) {
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
                        title: _historyItems[i]
                            .headerBuilder(context, _historyItems[i].isExpanded),
                        children: <Widget>[
                          _historyItems[i].build(),
                        ],
                      ));
                }
              }),
        ),)
    ];

    if (_loadingMore)
      listItems.add(CircularProgressIndicator(
        value: null,
      ));

    return listItems;
  }

  @override
  Widget build(BuildContext context) {
    tabController = new TabController(length: 3, vsync: this);

    var tabBarItem = new TabBar(
      tabs: [
        Tab(text: "Main"),
        Tab(text: "Live Feed"),
        Tab(text: "News"),
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
      length: 3,
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
            Livestream(loggedUserData: _loggedUserData),
            News(loggedUserData: _loggedUserData)],
        ),
      ),
    );
  }
}
