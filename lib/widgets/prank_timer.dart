import 'dart:io';
import 'package:daily_fart/theme/colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:countdown/countdown.dart';

class PrankTimer extends StatefulWidget {
  PrankTimer({Key key, this.audioPlayer, this.cachedFile}) : super(key: key);

  final AudioPlayer audioPlayer;
  final File cachedFile;

  @override
  State createState() => new PrankTimerState();
}

class PrankTimerState extends State<PrankTimer> {
  Duration _duration;
  CountDown _cd;
  int _timer = 5;
  int _timerReset = 5;

  @override
  void initState() {
    super.initState();
    _duration = new Duration(seconds: _timer);
  }

  void countdown() {
    _cd = new CountDown(_duration);
    var sub = _cd.stream.listen(null);

    sub.onData((Duration d) {
      if (_timer == d.inSeconds) return;
      print("countdown: ${d.inSeconds}");
      setState(() {
        _timer = d.inSeconds;
      });
    });

    sub.onDone(() {
      play();
      reset();
    });
  }

  reset() {
    _timer = _timerReset;
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
        Text("$_timer",
            style:
                DefaultTextStyle.of(context).style.apply(fontSizeFactor: 5.0)),
        SizedBox(height: 40),
        Ink(
          decoration: ShapeDecoration(
            color: kFartGreen400,
            shape: CircleBorder(),
          ),
          child: IconButton(
            icon: Icon(Icons.play_arrow),
            color: Colors.white,
            tooltip: 'Start Timer',
            onPressed: () {
              countdown();
            },
          ),
        ),
        SizedBox(height: 20),
        MaterialButton(
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
    super.dispose();
  }
}
