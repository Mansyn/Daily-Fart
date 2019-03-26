import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_storage/firebase_storage.dart';

const String testing_device = 'emulator-5554';
const String ad_unit_id = 'ca-app-pub-4892089932850014/7444446144';
const String app_id = 'ca-app-pub-4892089932850014~3425310088';

const String storagePath =
    'https://firebasestorage.googleapis.com/v0/b/daily-fart.appspot.com/o/fart{0}.mp3?alt=media';

enum PlayerState { stopped, playing, paused }

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'The Daily Fart',
      theme: ThemeData(primarySwatch: Colors.brown),
      home: MyHomePage(title: 'The Daily Fart'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;
  final TimeOfDay now = TimeOfDay.now();
  final String notPlaying = "assets/headshark.jpg";
  final String playing = "assets/headshark.gif";

  final MobileAdTargetingInfo targetingInfo = MobileAdTargetingInfo(
      testDevices: testing_device != null ? <String>[testing_device] : null,
      keywords: <String>['daily', 'funny', 'fart']);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // ad
  BannerAd _bannerAd;
  bool _adShown;

  // audio player
  AudioPlayer _audioPlayer;
  PlayerState _playerState = PlayerState.stopped;
  StreamSubscription _playerCompleteSubscription;
  get _isPlaying => _playerState == PlayerState.playing;

  // files
  String currentImage;
  File _cachedFile;

  Future<Null> downloadSound() async {
    final TimeOfDay now = TimeOfDay.now();
    final int hour = now.hour;
    final String path = storagePath.replaceAll('{0}', hour.toString());

    final RegExp regExp = RegExp('([^?/]*\.(mp3))');
    final String fileName = regExp.stringMatch(path);
    final Directory tempDir = Directory.systemTemp;
    final File file = File('${tempDir.path}/$fileName');

    final StorageReference ref = FirebaseStorage.instance.ref().child(fileName);
    final StorageFileDownloadTask downloadTask = ref.writeToFile(file);

    final int byteNumber = (await downloadTask.future).totalByteCount;

    print(byteNumber);

    setState(() => _cachedFile = file);
  }

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
    currentImage = widget.notPlaying;
    downloadSound();

    FirebaseAdMob.instance.initialize(appId: app_id);
    _adShown = false;
    _bannerAd = createBannerAd()
      ..load()
      ..show();

    _initAudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> fakeBottomButtons = new List<Widget>();
    fakeBottomButtons.add(new Container(
      height: 50.0,
    ));

    return Scaffold(
      backgroundColor: Colors.white,
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
                height: 225.0,
                width: 400.0,
                child: new IconButton(
                  icon: new Image(
                      image: new AssetImage(currentImage),
                      height: 225.0,
                      width: 400.0),
                  onPressed: _isPlaying ? null : () => _play(),
                ))
          ],
        ),
      ),
      persistentFooterButtons: _adShown ? fakeBottomButtons : null,
    );
  }

  void _initAudioPlayer() {
    _audioPlayer = new AudioPlayer(mode: PlayerMode.MEDIA_PLAYER);

    _playerCompleteSubscription =
        _audioPlayer.onPlayerCompletion.listen((event) {
      _onComplete();
    });
  }

  Future<int> _play() async {
    final result = await _audioPlayer.play(_cachedFile.path);
    if (result == 1)
      setState(() {
        _playerState = PlayerState.playing;
        currentImage = widget.playing;
      });
    return result;
  }

  void _onComplete() {
    setState(() {
      _playerState = PlayerState.stopped;
      currentImage = widget.notPlaying;
    });
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _playerCompleteSubscription?.cancel();
    super.dispose();
  }
}
