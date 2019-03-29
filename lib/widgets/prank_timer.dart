import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';

class PrankTimer extends StatefulWidget {
  PrankTimer({Key key, this.audioPlayer, this.cachedFile}) : super(key: key);

  final AudioPlayer audioPlayer;
  final File cachedFile;

  @override
  State createState() => new PrankTimerState();
}

class PrankTimerState extends State<PrankTimer> {
  Timer _timer;
  Duration _duration;
  int _counter;

  @override
  void initState() {
    _duration = const Duration(seconds: 10);
    _counter = 10;
    super.initState();
  }

  void startTimer() {
    _timer = new Timer.periodic(
        _duration,
        (Timer timer) => setState(() {
              if (_counter < 1) {
                timer.cancel();
                play();
              } else {
                _counter = _counter - 1;
              }
            }));
  }

  play() async {
    await widget.audioPlayer.play(widget.cachedFile.path, isLocal: true);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        MaterialButton(
          child: Text(
            "Cupertino date Picker",
            style: TextStyle(color: Colors.white),
          ),
          color: Theme.of(context).accentColor,
          onPressed: () {
            showModalBottomSheet(
                context: context,
                builder: (BuildContext builder) {
                  return Container(
                      height: MediaQuery.of(context).copyWith().size.height / 3,
                      child: CupertinoTimerPicker(
                        mode: CupertinoTimerPickerMode.ms,
                        minuteInterval: 1,
                        secondInterval: 1,
                        initialTimerDuration: _duration,
                        onTimerDurationChanged: (Duration changedtimer) {
                          setState(() {
                            _duration = changedtimer;
                            _counter = changedtimer.inSeconds;
                          });
                        },
                      ));
                });
          },
        ),
        RaisedButton(
          onPressed: () {
            startTimer();
          },
          child: Text("Begin Countdown"),
        ),
        Text("$_counter")
      ],
    );
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
