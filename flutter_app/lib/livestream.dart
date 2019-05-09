import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:flutter_socket_io/flutter_socket_io.dart';
import 'package:flutter_socket_io/socket_io_manager.dart';
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
  SocketIO socketIO;
  Image image;
  bool readSocket = false;

  @override
  void initState() {
    super.initState();
    this._getStream();
  }

  _socketStatus(dynamic data) {
    print("Socket status: " + data);
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
        socketIO = SocketIOManager().createSocketIO("http://178.166.11.252:5555", "/", socketStatusCallback: _socketStatus);
        socketIO.init();
        socketIO.subscribe("image", dataHandler);
        socketIO.connect();

      } catch (e) {
        print("Unable to connect: $e");
      }
    }
  }


  void dataHandler(String data) {
    Uint8List bytes = base64.decode(data);
    setState(() {
      this.image = Image.memory(bytes, fit: BoxFit.contain);
    });
  }

  void errorHandler(error, StackTrace trace) {
    print(error);
  }

  void doneHandler() {
    SocketIOManager().destroySocket(socketIO); 
  }

  @override
  Widget build(BuildContext context) {
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

  @override
  void dispose() {
    super.dispose();
    socketIO.disconnect();
    SocketIOManager().destroySocket(socketIO);
  }
}
