import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_app/configs.dart';
import 'package:flutter_app/livestream.dart';
import 'package:flutter_app/news.dart';
import 'package:flutter_app/news_view.dart';
import 'package:flutter_app/list.dart';
import 'package:flutter_app/user_info.dart';
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
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        initialRoute: '/login',
        routes: {
          '/': (context) => MainView(),
          '/login': (context) => LogInView(),
          '/news': (context) => NewsView(),
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
    await firebaseCloudMessaging_Listeners();

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

  Future<void> firebaseCloudMessaging_Listeners() async {

    await _firebaseMessaging.getToken().then((token){
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


  @override
  void initState() {
    super.initState();
  }@override
  
  void dispose() {
    super.dispose();
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
            ListItems(loggedUserData: _loggedUserData),
            Livestream(loggedUserData: _loggedUserData),
            News(loggedUserData: _loggedUserData)],
        ),
      ),
    );
  }
}
