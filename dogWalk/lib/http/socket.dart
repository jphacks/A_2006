import 'dart:html';
import 'package:http/http.dart' as http;
import 'dart:convert';

//Request用のデータクラス
class Request {
  final double weight;
  final File image;

  Request({
    this.weight,
    this.image,
  });
  Map<String, dynamic> toJson() => {
    'weight': weight,
    'image': image
  };
}

//Responseを受け取るデータクラス
class Response {
  final double distance;

  Response({
    this.distance,
  });
  factory Response.fromJson(Map<String, dynamic> json) {
    return Response(
      distance: json['distance'],
    );
  }
}

//POSTして結果を受け取る関数
Future<Response> fetchResponse() async {
  var url ="localhost";
  var request = new Request(weight: 33.3);
  final response = await http.post(url,
        body: json.encode(request.toJson()),
        headers: {"Content-Type":"application/json"});
  if (response.statusCode == 200) {
    return Response.fromJson(json.decode(response.body));
  }else {
    throw Exception("Failed");
  }
}