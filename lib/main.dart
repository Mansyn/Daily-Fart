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
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Daily Fart',
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
        primarySwatch: Colors.brown,
      ),
      home: MyHomePage(title: 'The Daily Fart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;
  final AudioCache player = new AudioCache();
  final AssetImage assetImage = new AssetImage("assets/Jakesalad.png");
  final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      testDevices: testing_device != null ? <String>[testing_device] : null,
      keywords: <String>['daily', 'fart'],
      childDirected: true);

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
    _adShown = false;
    FirebaseAdMob.instance.initialize(appId: app_id);
    _bannerAd = createBannerAd()..load();
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
