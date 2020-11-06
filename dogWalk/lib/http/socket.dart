import 'dart:wasm';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

//POSTして結果(km)を受け取る関数
Future<double> fetchResponse(String weight, File image) async {
  var url ="https://jphacksdog.herokuapp.com/route";
  final response = await http.post(url,
        body: json.encode({"weight": weight,"image": base64Encode(await image.readAsBytes()) }),
        headers: {"Content-Type":"application/json"});
  if (response.statusCode == 200) {
    print("成功");
    return json.decode(response.body)["data"]["distance"];
  }else {
    print("失敗");
    throw Exception("Failed");
  }
}