import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';

void main() => runApp(MyApp());

final String _apiHost = "f4a61c6b.ngrok.io" /*'10.0.2.2:3000' -> this isn't working on my network for some reason...*/;
final String _apiPath = '/api/';

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
      //home: LogInView(),
      initialRoute: '/login',
      routes: {
        '/': (context) => MainView(),
        '/login': (context) => LogInView()
      }
    );
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

class HistoryItem {
  bool isExpanded;
  String event;
  String date;
  Image image; //TODO: add later

  HistoryItem({this.event, this.date, this.isExpanded});

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

class LogInView extends StatefulWidget {
  @override
  _LogInViewState createState() => new _LogInViewState();
}

class _LogInViewState extends State<LogInView> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  Future<bool> login() async {
    var res = await http.post(
        Uri.http(_apiHost, _apiPath + 'auth/signin'),
        body: {
          "email": _userLoginData.email,
          "password": _userLoginData.password
        }
    );

    Map<String, dynamic> decodedBody = jsonDecode(res.body);
    _loggedUserData.loginData = _userLoginData;
    _loggedUserData.token = decodedBody['token'];

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else
      return Future<bool>.value(true);
  }

  bool isEmail(String em) {

    String p = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';

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
                                FocusScope.of(context).requestFocus(new FocusNode());
                                _formKey.currentState.save();

                                login().then((bool res) {
                                  if (res) {
                                    /*Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => MainView()),
                                    );*/
                                    Navigator.pushReplacementNamed(context, "/");
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
  bool alarmOn;
  List<HistoryItem> _historyItems = [];
  final List<String> _dropDownOptions = ['Settings', 'Logout'];

  _MainViewState() {
    //TODO: Get state of alarm
    this.alarmOn = false;

    this._getHistoryEntries();
  }

  void _toggleAlarm(bool value) {
    this.alarmOn = value;
    //TODO: Make request to API
  }

  /*
  Future<void> _getHistoryEntries() async {
    //TODO: Get this from API
    var history = await http.get('locahost:3000/api/history');
    print(history);
    //var historyJson = json.decode(history);
  }
  */

  Future<bool> _getHistoryEntriesAsync() async {
    var res = await http.get(
        Uri.http(_apiHost, _apiPath + 'auth/signin'),
        headers: {
          "Authorization": 'Bearer '+_loggedUserData.token
        }
    );

    Map<String, dynamic> decodedBody = jsonDecode(res.body);
    _loggedUserData.loginData = _userLoginData;
    _loggedUserData.token = decodedBody['token'];

    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else
      return Future<bool>.value(true);
  }

  Widget _getHistoryEntries() {
    //TODO: Get this from API

    _historyItems = [
      HistoryItem(event: "Turn On Alarm", date: "1/10/2019", isExpanded: false),
      HistoryItem(
          event: "Turn Off Alarm", date: "2/10/2019", isExpanded: false),
      HistoryItem(event: "Alarm!", date: "3/10/2019", isExpanded: false)
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
                Text("Alarm",
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0)),
                Switch(
                    activeColor: Colors.green,
                    value: this.alarmOn,
                    onChanged: _toggleAlarm),
              ],
            )),
        new Container(
          color: Colors.white,
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
            }).toList())
      ],
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
