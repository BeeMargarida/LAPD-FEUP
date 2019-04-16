import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'history.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MainView(),
    );
  }
}
/*
class MyHomePage extends StatelessWidget {
  MyHomePage({Key key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Home Security',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Home Security'),
        ),
        body: Center(
          child: new MainView(),
        ),
      ),
    );
  }
}*/

class MainView extends StatefulWidget {
  @override
  _MainViewState createState() => new _MainViewState();
}

class _MainViewState extends State<MainView> with TickerProviderStateMixin{

  TabController tabController;

  @override
  Widget build(BuildContext context) {
    tabController = new TabController(length: 2, vsync: this);

    var tabBarItem = new TabBar(
      tabs: [
        Tab(text: "Main"),
        Tab(text: "Live Feed"),
      ],
      labelColor: Colors.blue,
      unselectedLabelColor: Colors.black,
      controller: tabController,
      indicatorColor: Colors.white,
    );

    var listItem = new ListView.builder(
      itemCount: 20,
      itemBuilder: (BuildContext context, int index) {

        if(index == 0){
          // Button to turn ON/OFF alarm
          return new ListTile(
              title: new Card(
                elevation: 0,
                child: new Container(
                  alignment: Alignment.center,
                  //margin: new EdgeInsets.only(top: 10.0, bottom: 10.0),
                  child: new MaterialButton(
                    color: Colors.blue,
                    child: new Text("Alarm ON"),
                    onPressed: () => {
                      print("On/Off Alarm")
                    },
                  ),
                  height: 90.0,

                ),
              )
          );
        }


        return new ListTile(
          title: new Card(
            elevation: 5.0,
            child: new Container(
              alignment: Alignment.center,
              margin: new EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: new Text("ListItem $index"),
            ),
          ),
          onTap: () {
            showDialog(
                barrierDismissible: false,
                context: context,
                child: new CupertinoAlertDialog(
                  title: new Column(
                    children: <Widget>[
                      new Text("ListView"),
                      new Icon(
                        Icons.favorite,
                        color: Colors.red,
                      ),
                    ],
                  ),
                  content: new Text("Selected Item $index"),
                  actions: <Widget>[
                    new FlatButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: new Text("OK"))
                  ],
                ));
          },
        );
      },
    );

    return new DefaultTabController(
      length: 2,
      child: new Scaffold(
        appBar: new AppBar(
          title: new Text("Flutter TabBar"),
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

    /*
    return new MaterialApp(
      home: DefaultTabController(
        length: 2,
        child: new Scaffold(

          appBar: TabBar(
            tabs: [
              Tab(text: "Main"),
              Tab(text: "Live Feed"),
            ],
            labelColor: Colors.blue,
            unselectedLabelColor: Colors.black,
          ),

          body: TabBarView(
              children: [
                Container(color: Colors.green),
                Container(color: Colors.orange),
              ]
          ),
        ),
      ),
    );*/
  }


}
