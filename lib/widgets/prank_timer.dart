import 'dart:async';
import 'dart:io';
import 'package:daily_fart/app.dart';
import 'package:daily_fart/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:countdown/countdown.dart';
import 'package:screen/screen.dart';
import 'package:vibration/vibration.dart';

class PrankTimer extends StatefulWidget {
  PrankTimer({Key key, this.cachedFile, this.canVibrate}) : super(key: key);

  final File cachedFile;
  final bool canVibrate;

  @override
  State createState() => new PrankTimerState();
}

class PrankTimerState extends State<PrankTimer> {
  // audio player
  AudioPlayer _audioPlayer;
  StreamSubscription _playerCompleteSubscription;
  PlayerState _playerState = PlayerState.stopped;

  get _isStartEnabled => _playerState == PlayerState.playing ? false : true;

  Duration _duration;
  CountDown _cd;
  StreamSubscription<Duration> _sub;
  int _timer = 5;
  int _timerReset = 5;

  @override
  void initState() {
    super.initState();

    _duration = new Duration(seconds: _timer);
    _initAudioPlayer();
  }

  _countdown() {
    Screen.keepOn(true);
    _cd = new CountDown(_duration);
    _sub = _cd.stream.listen(null);

    _sub.onData((Duration d) {
      if (_timer == d.inSeconds) return;
      print("countdown: ${d.inSeconds}");
      setState(() {
        _timer = d.inSeconds;
      });
    });

    _sub.onDone(() {
      _play();
    });

    setState(() {
      _playerState = PlayerState.playing;
    });
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
    }
    return result;
  }

  Future<Null> _stop() async {
    await _audioPlayer.stop();
    _sub?.cancel();
    _onComplete();
  }

  void _onComplete() {
    Vibration.cancel();
    Screen.keepOn(false);
    setState(() {
      _timer = _timerReset;
      _playerState = PlayerState.stopped;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          new Text("$_timer",
              style: DefaultTextStyle.of(context)
                  .style
                  .apply(fontSizeFactor: 10.0)),
          new Text(" sec",
              style:
                  DefaultTextStyle.of(context).style.apply(fontSizeFactor: 2.0))
        ]),
        new SizedBox(height: 40),
        new Row(mainAxisAlignment: MainAxisAlignment.center, children: <Widget>[
          new Ink(
            decoration: ShapeDecoration(
              color: _isStartEnabled ? kFartGreen300 : kFartDisabledBg,
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: Icon(Icons.play_arrow),
              color: Colors.white,
              tooltip: 'Start Timer',
              onPressed: () => _isStartEnabled ? _countdown() : null,
            ),
          ),
          new SizedBox(width: 10),
          new Ink(
            decoration: ShapeDecoration(
              color: kFartErrorRed,
              shape: CircleBorder(),
            ),
            child: IconButton(
              icon: Icon(Icons.stop),
              color: Colors.white,
              tooltip: 'Stop Timer',
              onPressed: () {
                _stop();
              },
            ),
          ),
        ]),
        new SizedBox(height: 40),
        new MaterialButton(
          child: Text(
            "Set Timer",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext builder) {
                  return Container(
                      margin: const EdgeInsets.only(bottom: 50.0),
                      height: MediaQuery.of(context).copyWith().size.height / 3,
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        minuteInterval: 1,
                        secondInterval: 1,
                        initialTimerDuration: _duration,
                        onTimerDurationChanged: (Duration changedtimer) {
                          setState(() {
                            _duration = changedtimer;
                            _timer = changedtimer.inSeconds;
                            _timerReset = changedtimer.inSeconds;
                          });
                        },
                      ));
                });
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    Vibration.cancel();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }
}
