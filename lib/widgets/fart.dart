import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';

const String notPlaying = "assets/guy.png";
const String playing = "assets/guy.gif";
enum PlayerState { stopped, playing, paused }

class Fart extends StatefulWidget {
  Fart({Key key, this.cachedFile, this.canVibrate}) : super(key: key);

  final File cachedFile;
  final bool canVibrate;

  @override
  State createState() => new FartState();
}

class FartState extends State<Fart> {
  // audio player
  AudioPlayer _audioPlayer;
  StreamSubscription _playerCompleteSubscription;
  PlayerState _playerState = PlayerState.stopped;

  get _currentImage =>
      _playerState == PlayerState.playing ? playing : notPlaying;

  @override
  void initState() {
    super.initState();

    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    return new SizedBox(
        child: new IconButton(
            icon: new Image(image: new AssetImage(_currentImage)),
            onPressed: () => _play()));
  }

  void _initAudioPlayer() {
    _audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
    });
  }

  Future<int> _play() async {
    final result =
        await _audioPlayer.play(widget.cachedFile.path, isLocal: true);
    if (result == 1) {
      if (widget.canVibrate) {
        Vibration.vibrate(duration: 20000);
      }
      setState(() {
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
