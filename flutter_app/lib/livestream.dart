import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_app/configs.dart';
import 'package:flutter_app/user_info.dart';

class Livestream extends StatefulWidget {
  UserData loggedUserData;
  Livestream({Key key, this.loggedUserData}) : super(key: key);

  @override
  _LivestreamState createState() => new _LivestreamState();
}

class _LivestreamState extends State<Livestream> {
  Socket socket;
  Image image;
  bool readSocket = false;

  @override
  void initState() {
    super.initState();
    this._getStream();
  }

  Future<void> _getStream() async {
    var res = await http.get(
        Uri.http(Configs.API_HOST, Configs.API_PATH + 'alarm/livestream'),
        headers: {
          "Authorization": "Bearer " + widget.loggedUserData.token,
          "Accept": "application/json"
        });
    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      try {

        Socket s = await Socket.connect(Configs.LIVESTREAM_HOST, Configs.LIVESTREAM_PORT);  
        setState(() {
          this.socket = s;
          this.readSocket = true;
        });
        this._listenSocket();

      }
      catch (e){
        print("Unable to connect: $e");
      }
    }
  }

  void _listenSocket() async {
    this.socket.listen(dataHandler,
          onError: errorHandler, onDone: doneHandler, cancelOnError: false);
  }

  void dataHandler(List<int> data) {
    print(data);
    String dataString = new String.fromCharCodes(data).trim();
    print(dataString);
    Uint8List bytes = base64.decode(dataString);
    //String stringData = new String.fromCharCodes(data);
    setState(() {
      this.image = Image.memory(bytes);
    });
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    print('here');
    socket.destroy();
  }

  @override
  Widget build(BuildContext context) {
    // if(this.readSocket) {
    //   this._listenSocket();
    // }

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      children: <Widget>[
        this.image != null
            ? this.image
            : CircularProgressIndicator(
                value: null,
              )
      ],
    );
  }

  // @override 
  // void dispose() {
    
  // }
}
