import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'main.dart';
import './map.dart';

class LoginView extends StatefulWidget {
  final CounterStorage cstorage; //初期設定が終わっているか
  final DognameStorage dstorage; //犬の名前を扱う
  final PicStorage pstorage; //写真を扱う
  final WeightsStorage wstorage; //体重を保管する

  LoginView({Key key, @required this.cstorage, @required this.dstorage, @required this.pstorage, @required this.wstorage}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<LoginView> {

  final nameTextController = TextEditingController();
  final weightTextController = TextEditingController();

  String dogName = "";
  String dogWeight = "";

  File _image;
  final picker = ImagePicker();
  

  // @override
  // void initState() {
  //   super.initState();
  //   widget.storage.readCounter().then((int value) {
  //     setState(() {
  //       _counter = value;
  //     });
  //   });
  // }
  Future getImageFromCamera() async {
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    setState(() {
      _image = File(pickedFile.path);
    });
  }

  Future getImageFromGallery() async {
    final pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
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
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      resizeToAvoidBottomPadding:false,
       appBar: AppBar(
        title: Text('dogWalk',style: TextStyle(
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
                        Radius.circular(20.0),
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
                            '初期情報を入力',
                            style: TextStyle(fontSize: 25.0),
                          ),
                          Image.asset('images/walk.gif', height: 90.0,width: 90.0,),

                          SizedBox(height: 10),

                          Center(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Center(
                                        child: _image == null
                                            ? Text('犬の画像を選択してください',style: TextStyle(
                                                                                    fontSize: 20,
                                                                                    color: Theme.of(context).primaryColor,
                                                                                    ),)
                                            : Image.file(_image, height: 180.0, width: 180.0)
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                    Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      FloatingActionButton(
                                        heroTag: 3,
                                        onPressed: getImageFromCamera, //カメラから画像を取得
                                        tooltip: 'Pick Image From Camera',
                                        child: Icon(Icons.add_a_photo),
                                      ),
                                      FloatingActionButton(
                                        heroTag: 4,
                                        onPressed: getImageFromGallery, //ギャラリーから画像を取得
                                        tooltip: 'Pick Image From Gallery',
                                        child: Icon(Icons.photo_library),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                            SizedBox(height: 20),

                          _textField(
                              label: '犬の名前',
                              hint: '太郎',
                              prefixIcon: Icon(Icons.looks_one_outlined),
                              controller: nameTextController,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  dogName = value;
                                });
                              }),
                          SizedBox(height: 10),

                          _textField(
                              label: '犬の体重',
                              hint: '100',
                              prefixIcon: Icon(Icons.looks_two_outlined),
                              controller: weightTextController,
                              width: width,
                              locationCallback: (String value) {
                                setState(() {
                                  dogWeight = value;
                                });
                              }),
                          SizedBox(height: 10),

                          RaisedButton(
                            onPressed: (dogName != '' &&
                                    dogWeight != '' && _image != null)
                                ? ()  async {
                                    widget.cstorage.writeCounter(1);
                                    widget.dstorage.writeName(dogName);
                                    widget.pstorage.writePic(_image);
                                    widget.wstorage.writeWeights(dogWeight);
                                    Navigator.push(
                                          context,
                                          MaterialPageRoute(builder: (context) => MyMap(),)
                                          );
                                  }
                                : null,
                            color: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '登録',
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



