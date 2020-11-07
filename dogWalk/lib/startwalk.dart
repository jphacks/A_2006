import 'dart:wasm';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;
import 'dart:async';

import './map.dart';
import './main.dart';
import './http/socket.dart';
import 'dart:io';



class StartWalk extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home:WalkView(dstorage: DognameStorage(), cstorage: CounterStorage(),pstorage: PicStorage(), wstorage: WeightsStorage(),),
    );
  }
}

class WalkView extends StatefulWidget {
  final CounterStorage cstorage; //初期設定が終わっているか
  final DognameStorage dstorage; //犬の名前を扱う
  final PicStorage pstorage; //写真を扱う
  final WeightsStorage wstorage; //体重を保管する

  WalkView({Key key, @required this.cstorage, @required this.dstorage, @required this.pstorage, @required this.wstorage}) : super(key: key);

  @override
  _WalkViewState createState() => _WalkViewState();
}

class _WalkViewState extends State<WalkView> {

  final nameTextController = TextEditingController();
  final calTextController = TextEditingController();
  String dogWeight = "";
  String _allWeight;
  String _name;
  File _file;
  double distance;
  String dryfood;
  double cal = 0.0;

  @override
  void initState() {
    super.initState();
    widget.dstorage.readName().then((String x){
       setState((){
          _name = x;
       });
    });
    widget.wstorage.readWeights().then((String x){
      setState((){
        _allWeight = x;
      });
    });
    widget.pstorage.readPic().then((File i){
      setState((){
        _file = i;
        });
   });
  }


  Widget _textField({
    TextEditingController controller,
    String label,
    String hint,
    double width,
    Icon prefixIcon,
    Widget suffixIcon,
    Function(String) locationCallback,
  }) {
    return Container(
      width: width * 0.8,
      child: TextField(
        onChanged: (value) {
          locationCallback(value);
        },
        controller: controller,
        decoration: new InputDecoration(
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.grey[400],
              width: 2,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
            borderSide: BorderSide(
              color: Colors.blue[300],
              width: 2,
            ),
          ),
          contentPadding: EdgeInsets.all(15),
          hintText: hint,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context){

    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding:false,
       appBar: AppBar(
        title: Text('散歩しよう！',style: TextStyle(
                                                      fontSize: 30,
                                                      color: Colors.black87
                                                      ),),
      ),
      body: SafeArea(

              child: Column(
                children: <Widget>[
                  Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.deepOrange[50],
                      borderRadius: BorderRadius.all(
                        Radius.circular(10.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 25.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Text(
                            'こんにちは $_name さん',
                            style: TextStyle(fontSize: 25.0),
                          ),

                          SizedBox(height: 10),
                          Image.asset('images/dog.gif', height: 90,width: width*0.8,),
                          SizedBox(height: 10),

                          _textField(
                              label: '現在の体重(kg)',
                              hint: '50',
                              prefixIcon: Icon(Icons.looks_one_outlined),
                              controller: nameTextController,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  dogWeight = value;
                                });
                              }),
                          SizedBox(height: 10),
                            _textField(
                              label: 'ドライフードのカロリー(kcal/100g)',
                              hint: '50',
                              prefixIcon: Icon(Icons.looks_two_outlined),
                              controller: calTextController,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  dryfood = value;
                                });
                              }),
                          SizedBox(height: 10),

                          RaisedButton(
                            onPressed: (dogWeight != '' && dryfood != '')
                                ? () async {
                                    print(_allWeight);

                                    widget.wstorage.writeWeights("$_allWeight,$dogWeight");
                                    fetchResponse(dogWeight, _file).then((List l){
                                      setState((){
                                        distance = l[0]/2.3;
                                        cal = l[1];
                                    
                                      });
                                       Navigator.push(
                                           context,
                                           MaterialPageRoute(builder: (context) => MapView(d: distance, f: double.parse(dryfood),cc: cal),)
                                       );
                                    });

                                  }
                                : null,
                            color: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'ルート探索',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ),
              ),
              RaisedButton(
                            onPressed: ()  {
                              Navigator.push(
                                           context,
                                           MaterialPageRoute(builder: (context) => MapView(d:0.0, f:0.0, cc:0.0))
                                       );
                                  }
                                    ,

                            color: Colors.white,
                            shape: const CircleBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid,
                              ),),
                            child: Icon(Icons.clear_outlined),
                          ),
                ]
              )
            ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: Icon(Icons.add),
      // ),
    );
  }
}