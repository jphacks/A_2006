import 'package:flutter/material.dart';
import './map.dart';
import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import './login.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: HomeView(storage: CounterStorage()),
    );
  }
}



class HomeView extends StatefulWidget {
  final CounterStorage storage;

  HomeView({Key key, @required this.storage}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<HomeView> {
  int _counter;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_counter == 0){

      return MaterialApp(
      title: '初期設定',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginView(dstorage: DognameStorage(), cstorage: CounterStorage(),pstorage: PicStorage(), wstorage: WeightsStorage(),),
    );

    } else {

      return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home:LoginView(dstorage: DognameStorage(), cstorage: CounterStorage(),pstorage: PicStorage(), wstorage: WeightsStorage(),), 
      // MapView(),
    );
    
    }
  }
}












class CounterStorage {
  Future<String> get _localPath async {//fileへのpath取得
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {//ファイルの内容を返す
    final path = await _localPath;
    return File('$path/counter.txt');
  }

  Future<int> readCounter() async {//fileを読めたかどうか
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return int.parse(contents);
    } catch (e) {
      // If encountering an error, return 0
      return 0;
    }
  }

  Future<File> writeCounter(int counter) async {//fileへの書き込み
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$counter');
  }
}


class DognameStorage {
  Future<String> get _localPath async {//fileへのpath取得
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {//ファイルの内容を返す
    final path = await _localPath;
    return File('$path/dogname.txt');
  }

  Future<String> readName() async {//fileを読めたかどうか
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> writeName(String name) async {//fileへの書き込み
    final file = await _localFile;

    // Write the file
    return file.writeAsString('$name');
  }
}


class PicStorage {
  Future<String> get _localPath async {//fileへのpath取得
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {//ファイルの内容を返す
    final path = await _localPath;
    return File('$path/dog.png');
  }

  Future<File> readPic() async {//fileを読めたかどうか
      final file = await _localFile;

      // Read the file
      return file;
  }

  Future<File> writePic(File image) async {//fileへの書き込み
    final file = await _localFile;
    // Write the file
    return file.writeAsBytes(await image.readAsBytes());
  }
}


class WeightsStorage {
  Future<String> get _localPath async {//fileへのpath取得
    final directory = await getApplicationDocumentsDirectory();

    return directory.path;
  }

  Future<File> get _localFile async {//ファイルの内容を返す
    final path = await _localPath;
    return File('$path/weightstore.txt');
  }

  Future<String> readWeights() async {//fileを読めたかどうか
    try {
      final file = await _localFile;

      // Read the file
      String contents = await file.readAsString();

      return contents;
    } catch (e) {
      // If encountering an error, return 0
      return "";
    }
  }

  Future<File> writeWeights(String name) async {//fileへの書き込み
    final file = await _localFile;
    print("書き込む内容 $name");
    // Write the file
    return file.writeAsString('$name');
  }
}












class FlutterDemo extends StatefulWidget {
  final CounterStorage storage;

  FlutterDemo({Key key, @required this.storage}) : super(key: key);

  @override
  _FlutterDemoState createState() => _FlutterDemoState();
}

class _FlutterDemoState extends State<FlutterDemo> {
  int _counter;

  @override
  void initState() {
    super.initState();
    widget.storage.readCounter().then((int value) {
      setState(() {
        _counter = value;
      });
    });
  }

  Future<File> _incrementCounter() {
    setState(() {
      _counter++;
    });

    // Write the variable as a string to the file.
    return widget.storage.writeCounter(_counter);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding:false,
      appBar: AppBar(title: Text('Reading and Writing Files')),
      body: Center(
        child: Text(
          'Button tapped $_counter time${_counter == 1 ? '' : 's'}.',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 1,
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ),
    );
  }
}












class MyHome extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding:false,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 2,
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}


















