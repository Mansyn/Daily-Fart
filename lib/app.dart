import 'dart:async';
import 'dart:io';
import 'package:daily_fart/widgets/fart.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:vibration/vibration.dart';

// internal
import 'package:daily_fart/theme/build_theme.dart';
import 'package:daily_fart/widgets/prank_timer.dart' show PrankTimer;

// ad config
const String testing_device = '710KPYR0456922';
const String ad_unit_id = 'ca-app-pub-4892089932850014/7444446144';
const String app_id = 'ca-app-pub-4892089932850014~342531008';
const List<String> keywords = ['daily', 'funny', 'gas'];

// app config
const String title = 'The Daily Fart';
const String fartFileName = 'fart{0}.mp3';
enum PlayerState { stopped, playing, paused }

class FartApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Daily Fart',
      debugShowCheckedModeBanner: false,
      theme: _kFartTheme,
      home: FartHomePage(),
    );
  }
}

final ThemeData _kFartTheme = FartThemeBuilder.build();

class FartHomePage extends StatefulWidget {
  final TimeOfDay now = TimeOfDay.now();

  final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      testDevices: testing_device != null ? <String>[testing_device] : null,
      keywords: keywords);

  @override
  _FartAppState createState() => _FartAppState();
}

class _FartAppState extends State<FartHomePage> {
  // ad
  BannerAd _bannerAd;
  bool _adShown;

  // vibrate
  bool canVibrate;

  // files
  File _cachedFile;

  Future<Null> _downloadSound() async {
    final TimeOfDay now = TimeOfDay.now();
    final int hour = now.hour;
    final String fart = fartFileName.replaceAll('{0}', hour.toString());

    final Directory tempDir = await getTemporaryDirectory();
    final File tempFile = await new File('${tempDir.path}/$fart').create();

    final StorageReference ref = FirebaseStorage.instance.ref().child(fart);
    ref.writeToFile(tempFile);

    setState(() => _cachedFile = tempFile);
  }

  BannerAd _createBannerAd() {
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

  Future<Null> _checkVibrate() async {
    canVibrate = await Vibration.hasVibrator();
  }

  @override
  void initState() {
    super.initState();
    _downloadSound();

    FirebaseAdMob.instance.initialize(appId: app_id);
    _adShown = false;
    _bannerAd = _createBannerAd()
      ..load()
      ..show();

    _checkVibrate();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> fakeBottomButtons = new List<Widget>();
    fakeBottomButtons.add(new Container(
      height: 50.0,
    ));

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: TabBar(
            tabs: [
              Tab(icon: Icon(Icons.wb_cloudy)),
              Tab(icon: Icon(Icons.alarm))
            ],
          ),
          title: Text(title),
          actions: <Widget>[
            new IconButton(
              icon: new Icon(Icons.close),
              onPressed: () => exit(0),
            ),
          ],
        ),
        body: TabBarView(
          children: [
            Fart(cachedFile: _cachedFile, canVibrate: canVibrate),
            PrankTimer(cachedFile: _cachedFile, canVibrate: canVibrate),
          ],
        ),
        persistentFooterButtons: _adShown ? fakeBottomButtons : null,
      ),
    );
  }

  @override
  void dispose() {
    Vibration.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }
}
