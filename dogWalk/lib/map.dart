import 'package:flutter/material.dart';
import './secrets.dart'; // Stores the Google Maps API Key 
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'dart:math' show cos, sqrt, asin;
import './main.dart';
import './startwalk.dart';
import './selectpoint.dart';


class MyMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Maps',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MapView(d: 0.0,f:0.0, cc:0.0),
    );
  }
}

class MapView extends StatefulWidget {
  final double d;
  final double f;
  final double cc;

  MapView({Key key, @required this.d, @required this.f, @required this.cc}) : super(key: key);
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {

  //widget.dで参照できる
  double distance;
  double dryfood;
  double cal;
  int gramfood;
  final startAddressController = TextEditingController();
  final destinationAddressController = TextEditingController();

  double tlat, tlng;
  
  CameraPosition _initialLocation = CameraPosition(target: LatLng(0.0, 0.0));
  GoogleMapController mapController;

  final Geolocator _geolocator = Geolocator();

  Position _currentPosition;
  String _currentAddress;

  int ispoly = 0;
  int showdis = 0;

  String _startAddress = '';
  String _destinationAddress = '';
  String _placeDistance;


  Set<Marker> markers = {};

  PolylinePoints polylinePoints;
  Map<PolylineId, Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];

  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Method for retrieving the current location
  _getCurrentLocation() async {
    await _geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.high)
        .then((Position position) async {
      setState(() {
        _currentPosition = position;
        print('CURRENT POS: $_currentPosition');
        mapController.animateCamera(
          CameraUpdate.newCameraPosition(
            CameraPosition(
              target: LatLng(position.latitude, position.longitude),
              zoom: 18.0,
            ),
          ),
        );
      });
      await _getAddress();
    }).catchError((e) {
      print(e);
    });
  }

  // Method for retrieving the address
  _getAddress() async {
    try {
      List<Placemark> p = await _geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      setState(() {
        _currentAddress =
            "${place.name}, ${place.locality}, ${place.postalCode}, ${place.country}";
        startAddressController.text = _currentAddress;
        _startAddress = _currentAddress;
      });
    } catch (e) {
      print(e);
    }
  }

  // Method for calculating the distance between two places
  Future<bool> _calculateDistance() async {
    try {
        // Use the retrieved coordinates of the current position,
        // instead of the address if the start position is user's
        // current position, as it results in better accuracy.
        Position startCoordinates = _currentPosition;
        Position destinationCoordinates = Position(latitude: tlat, longitude:tlng);

        // Start Location Marker
        Marker startMarker = Marker(
          markerId: MarkerId('$startCoordinates'),
          position: LatLng(
            startCoordinates.latitude,
            startCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Start',
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Destination Location Marker
        Marker destinationMarker = Marker(
          markerId: MarkerId('$destinationCoordinates'),
          position: LatLng(
            destinationCoordinates.latitude,
            destinationCoordinates.longitude,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
          ),
          icon: BitmapDescriptor.defaultMarker,
        );

        // Adding the markers to the list
        markers.add(startMarker);
        markers.add(destinationMarker);

        print('START COORDINATES: $startCoordinates');
        print('DESTINATION COORDINATES: $destinationCoordinates');


        // Calculating the distance between the start and the end positions
        // with a straight path, without considering any route
        // double distanceInMeters = await Geolocator().bearingBetween(
        //   startCoordinates.latitude,
        //   startCoordinates.longitude,
        //   destinationCoordinates.latitude,
        //   destinationCoordinates.longitude,
        // );

        await _createPolylines(startCoordinates, destinationCoordinates);

        double totalDistance = 0.0;

        // Calculating the total distance by adding the distance
        // between small segments
        for (int i = 0; i < polylineCoordinates.length - 1; i++) {
          totalDistance += _coordinateDistance(
            polylineCoordinates[i].latitude,
            polylineCoordinates[i].longitude,
            polylineCoordinates[i + 1].latitude,
            polylineCoordinates[i + 1].longitude,
          );
        }

        setState(() {
          _placeDistance = totalDistance.toStringAsFixed(2);
          print('DISTANCE: $_placeDistance km');
        });

        return true;
      
    } catch (e) {
      print(e);
    }
    return false;
  }

  // Formula for calculating distance between two coordinates
  // https://stackoverflow.com/a/54138876/11910277
  double _coordinateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  // Create the polylines for showing the route between two places
  _createPolylines(Position start, Position destination) async {
    polylinePoints = PolylinePoints();
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      Secrets.API_KEY, // Google Maps API Key 
      PointLatLng(start.latitude, start.longitude),
      PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.transit,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    PolylineId id = PolylineId('poly');
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.orange,
      points: polylineCoordinates,
      width: 5,
    );
    polylines[id] = polyline;
  }

  @override
  void initState() {
    super.initState();
    setState((){
      showdis = 0;
      ispoly = 0;
      distance = widget.d;
      dryfood = widget.f;
      cal = widget.cc;
    });
    Future(() async {
      await _getCurrentLocation();

      if (distance != 0.0){
      
      List ll = selectState(distance, _currentPosition.latitude, _currentPosition.longitude);
      setState((){
        showdis = 1;
        ispoly = 1;
        tlat = ll[0];
        tlng = ll[1];
        if (dryfood != 0.0){
        print("dryfoodの値は $dryfood");
        print("calの値は　${widget.cc}");
        gramfood = (cal/dryfood*100.0).round();
      }
      });

      Future(() async {
      await _calculateDistance();
    });

    }
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Container(
      height: height,
      width: width,
      child: Scaffold(
        resizeToAvoidBottomPadding:false,
        key: _scaffoldKey,
        body: Stack(
          children: <Widget>[

            // Map View
            GoogleMap(
              markers: markers != null ? Set<Marker>.from(markers) : null,
              initialCameraPosition: _initialLocation,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              mapType: MapType.normal,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
              polylines: Set<Polyline>.of(polylines.values),
              onMapCreated: (GoogleMapController controller) {
                mapController = controller;
              },
            ),


            // Show zoom buttons
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    ClipOval(
                      child: Material(
                        color: Colors.blue[100], // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.add),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomIn(),
                            );
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    ClipOval(
                      child: Material(
                        color: Colors.blue[100], // button color
                        child: InkWell(
                          splashColor: Colors.blue, // inkwell color
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: Icon(Icons.remove),
                          ),
                          onTap: () {
                            mapController.animateCamera(
                              CameraUpdate.zoomOut(),
                            );
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),




            // Show current location button
            SafeArea(
              child: Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 10.0, bottom: 10.0),
                  child: ClipOval(
                    child: Material(
                      color: Colors.orange[100], // button color
                      child: InkWell(
                        splashColor: Colors.orange, // inkwell color
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: Icon(Icons.my_location),
                        ),
                        onTap: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              CameraPosition(
                                target: LatLng(
                                  _currentPosition.latitude,
                                  _currentPosition.longitude,
                                ),
                                zoom: 18.0,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
            ),



        SafeArea(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  child: RaisedButton(
                            onPressed: ()  {
                              Navigator.push(
                                           context,
                                           MaterialPageRoute(builder: (context) => StartWalk(),)
                                       );
                                  },
                            color: Colors.orange,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ispoly != 1 ? Text(
                                'GO!!'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26.0,
                                )) : Text(
                                'ルートを再検索'.toUpperCase(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26.0,
                                )
                              
                              ),
                            ),
                          ),
                ),
              ),
            ),

            SafeArea(
              child: showdis != 0 ? Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.9,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '散歩開始！',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          Visibility(
                            visible: _placeDistance == null ? false : true,
                            child: Text(
                              '片道: $_placeDistance km',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          RaisedButton(
                            onPressed: () async {
                                    setState(() {
                                      showdis = 0;
                                    });},

                            color: Colors.white,
                            shape: const CircleBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid,
                              ),),
                            child: Icon(Icons.clear_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ): Text(""),
            ),

             //目標摂取量の表示
            SafeArea(
              child: (cal != 0.0 && dryfood != 0.0) ? Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(top: 50.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white70,
                      border: Border.all(color: Colors.red),
                      borderRadius: BorderRadius.all(
                        Radius.circular(20.0),
                      ),
                    ),
                    width: width * 0.8,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            '今日の摂取目標カロリーは',
                            style: TextStyle(fontSize: 20.0),
                          ),
                          SizedBox(height: 10),
                          Visibility(
                            visible: true,
                            child: Text(
                              '$gramfood gです',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          SizedBox(height: 5),
                          RaisedButton(
                            onPressed: () async {
                                    setState(() {
                                      dryfood = 0.0;
                                      cal = 0.0;
                                    });},

                            color: Colors.white,
                            shape: const CircleBorder(
                              side: BorderSide(
                                color: Colors.black,
                                width: 1,
                                style: BorderStyle.solid,
                              ),),
                            child: Icon(Icons.clear_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ): Text(""),
            ),







          ],
        ),
      ),
    );
  }
}



