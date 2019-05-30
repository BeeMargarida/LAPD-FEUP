import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:flutter_vlc_player/vlc_player.dart';
import 'package:flutter_vlc_player/vlc_player_controller.dart';
import 'package:flutter_app/configs.dart';
import 'package:flutter_app/user_info.dart';

class Livestream extends StatefulWidget {
  UserData loggedUserData;
  Livestream({Key key, this.loggedUserData}) : super(key: key);

  @override
  _LivestreamState createState() => new _LivestreamState();
}

class _LivestreamState extends State<Livestream> {
  String urlToStreamVideo = "";
  VlcPlayerController controller = null;
  final int playerWidth = 640;
  final int playerHeight = 360;
  bool video = false;
  bool readSocket = false;

  @override
  void initState() {
    print("LIVESTREAM");
    super.initState();
    this._getStream();
  }

  Future<void> _getStream() async {
    var res = await http
        .post(Uri.http(Configs.API_HOST, '/livestream/start'), headers: {
      "Authorization": "Bearer " + widget.loggedUserData.token,
      "Accept": "application/json"
    });
    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      if (mounted) {
        setState(() {
          this.video = true;
          this.urlToStreamVideo = Configs.LIVESTREAM_HOST;
          this.controller = VlcPlayerController();
        });
      }
    }
  }

  Future<void> _stopStream() async {
    var res = await http
        .post(Uri.http(Configs.API_HOST, '/livestream/stop'), headers: {
      "Authorization": "Bearer " + widget.loggedUserData.token,
      "Accept": "application/json"
    });
    if (res.statusCode != 200)
      return Future<bool>.value(false);
    else {
      return Future<bool>.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      runAlignment: WrapAlignment.center,
      children: <Widget>[
        this.video == true
            ? VlcPlayer(
                defaultWidth: playerWidth,
                defaultHeight: playerHeight,
                url: urlToStreamVideo,
                controller: controller,
                placeholder: Center(child: CircularProgressIndicator()),
              )
            : CircularProgressIndicator(
                value: null,
              )
      ],
    );
  }

  @override
  void dispose() {
    super.dispose();
    this._stopStream();
  }
}
