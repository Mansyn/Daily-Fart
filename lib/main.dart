import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:audioplayers/audio_cache.dart';

const String testing_device = 'emulator-5554';
const String ad_unit_id = 'ca-app-pub-4892089932850014/7444446144';
const String app_id = 'ca-app-pub-4892089932850014~3425310088';

const fartAudioPath = "Silly_Farts-Joe.mp3";

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Daily Fart',
      theme: ThemeData(
        primarySwatch: Colors.brown,
      ),
      home: MyHomePage(title: 'The Daily Fart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final AudioCache player = new AudioCache();
  final AssetImage assetImage = new AssetImage("assets/butt-icon.png");
  final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      testDevices: testing_device != null ? <String>[testing_device] : null,
      keywords: <String>['daily', 'funny', 'fart']);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  BannerAd _bannerAd;
  bool _adShown;

  BannerAd createBannerAd() {
    return new BannerAd(
        adUnitId: ad_unit_id,
        targetingInfo: widget.targetingInfo,
        size: AdSize.banner,
        listener: (MobileAdEvent event) {
          if (event == MobileAdEvent.loaded) {
            _adShown = true;
            setState(() {});
          } else if (event == MobileAdEvent.failedToLoad) {
            _adShown = false;
            setState(() {});
          }
        });
  }

  @override
  void initState() {
    super.initState();

    FirebaseAdMob.instance.initialize(appId: app_id);
    _adShown = false;
    _bannerAd = createBannerAd()
      ..load()
      ..show();
  }

  @override
  Widget build(BuildContext context) {
    void _onClicked() {
      setState(() {
        widget.player.play(fartAudioPath);
      });
    }

    List<Widget> fakeBottomButtons = new List<Widget>();
    fakeBottomButtons.add(new Container(
      height: 50.0,
    ));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          new IconButton(
            icon: new Icon(Icons.close),
            onPressed: () => exit(0),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new SizedBox(
                height: 250.0,
                width: 300.0,
                child: new IconButton(
                  icon: new Image(
                      image: widget.assetImage, height: 250.0, width: 300.0),
                  onPressed: _onClicked,
                ))
          ],
        ),
      ),
      persistentFooterButtons: _adShown ? fakeBottomButtons : null,
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
