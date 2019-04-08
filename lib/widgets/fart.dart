import 'dart:async';
import 'dart:io';
import 'package:daily_fart/app.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

const String notPlaying = "assets/guy.png";
const String playing = "assets/guy.gif";

class Fart extends StatefulWidget {
  Fart({Key key, this.cachedFile, this.ref, this.canVibrate}) : super(key: key);

  final File cachedFile;
  final StorageReference ref;
  final bool canVibrate;

  @override
  State createState() => new FartState();
}

class FartState extends State<Fart> {
  // audio player
  AudioPlayer _audioPlayer;
  StreamSubscription _playerCompleteSubscription;
  PlayerState _playerState = PlayerState.stopped;

  String _fartName;
  get _currentImage =>
      _playerState == PlayerState.playing ? playing : notPlaying;

  @override
  void initState() {
    super.initState();
    _fartName = 'ready to pass gas';
    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          new Text("$_fartName",
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(fontSizeFactor: 2.0)),
          new SizedBox(height: 10),
          SizedBox(
              width: 400,
              height: 400,
              child: new IconButton(
                  icon: new Image(image: new AssetImage(_currentImage)),
                  onPressed: () => _play()))
        ]);
  }

  void _initAudioPlayer() {
    _audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
    });
  }

  Future<int> _play() async {
    final metaData = await widget.ref.getMetadata();
    final name = metaData.customMetadata["name"];

    final result =
        await _audioPlayer.play(widget.cachedFile.path, isLocal: true);
    if (result == 1) {
      if (widget.canVibrate) {
        Vibration.vibrate(duration: 20000);
      }
      setState(() {
        _fartName = name;
        _playerState = PlayerState.playing;
      });
    }
    return result;
  }

  void _onComplete() {
    Vibration.cancel();
    setState(() {
      _playerState = PlayerState.stopped;
    });
  }

  @override
  void dispose() {
    _playerCompleteSubscription?.cancel();
    Vibration.cancel();
    super.dispose();
  }
}
