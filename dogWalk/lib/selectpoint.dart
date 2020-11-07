import 'dart:math';

List selectState(double d, double clat, double clng){
  // 描く円の半径(km)
  var radius = 1;

  // 赤道半径(m) (WGS-84)
  var EquatorialRadius = 6378137;

  // 扁平率の逆数 : 1/f (WGS-84)
  var F = 298.257223;            

  // 離心率の２乗
  var E = ((2 * F) -1) / pow(F, 2);

  // 赤道半径 × π
  var PI_ER = pi * EquatorialRadius;

  // 1 - e^2 sin^2 (θ)
  var TMP = 1 - E * pow(sin(clat * pi / 180.0), 2);

  // 経度１度あたりの長さ(m)
  var arc_lat = (PI_ER * (1 - E)) / (180 * pow(TMP, 3/2));

  // 緯度１度あたりの長さ(m)
  var arc_lng = (PI_ER * cos(clat * pi / 180)) / (180 * pow(TMP, 1/2));

  // 半径をｍ単位に
  var R = radius * 1000;
  var random = new Random();
  int i = random.nextInt(361);
  var rad = i / 180 * pi;
  var lat = (R / arc_lat) * sin(rad) + clat;
  var lng = (R / arc_lng) * cos(rad) + clng;

  return [lat, lng];
}