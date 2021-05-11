import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:boxet/PageActivity.dart';
import 'package:boxet/classes/MarkersEntity.dart';
import 'package:location/location.dart';
import 'package:connectivity/connectivity.dart';

class MapsPage extends StatefulWidget {
  final String pageId, pageName, pageImg, pageAddress;
  final GeoPoint mapLoc;

  MapsPage(
      {this.pageId,
      this.pageName,
      this.pageImg,
      this.pageAddress,
      this.mapLoc});
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage>
    with SingleTickerProviderStateMixin {
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController controllerr;
  double height, width;
  Location location = new Location();
  bool _serviceEnabled;
  PermissionStatus _permissionGranted;
  LocationData _locationData;
  bool showProgress = true;
  LatLng currentPosition = LatLng(31.205753, 29.924526);
  List<Marker> markers = [];
  BitmapDescriptor myIcon;
  List<MarkersEntity> dataList = [];
  String markerImage = '';
  String markerTitle = '';
  String markerPageId = '';
  String markerPageAddress = '';
  bool showMaps = false;
  bool showInfoWindow = false;
  bool showLocError = false;
  bool internetError = false;
  Animation<double> infoWindowAnimation;
  AnimationController infoAnimCont;
  String pageProfile = "";
  double profileLat;
  double profileLng;
  bool showMap = false;
  bool retrying = false;
  bool showIosError=false;
  GeoPoint mapLoc;

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    Codec codec = await instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  Future<BitmapDescriptor> getBitmapDescriptorFromAssetBytes(
      String path, int width) async {
    final Uint8List imageData = await getBytesFromAsset(path, width);
    return BitmapDescriptor.fromBytes(imageData);
  }

  _getMarkers() async {
    await FirebaseFirestore.instance
        .collection('pages')
        .where('online', isEqualTo: false)
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        value.docs.forEach((element) {
          if (pageProfile != "" && element.id == pageProfile) {
          } else {
            GeoPoint geoPoint = element.data()['maploc'];
            markers.add(Marker(
                icon: myIcon,
                markerId: MarkerId(element.id),
                position: LatLng(geoPoint.latitude, geoPoint.longitude),
                onTap: () {
                  markerImage = element.data()['pageimg'];
                  markerTitle = element.data()['pagename'];
                  markerPageAddress = element.data()['location'];
                  markerPageId = element.id;
                  setState(() {
                    showInfoWindow = true;
                  });
                  infoAnimCont.forward();
                }));
          }
        });
      }
    }).then((value) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(31.205753, 29.924526),
    zoom: 15,
  );

  Future _checkLocation() async {
    // Future.delayed(Duration(milliseconds: 1000));
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {
        setState(() {
          showLocError = true;
        });
        return;
      }
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      if (Platform.isIOS) {
        setState(() {
            showIosError = true;
          });
          return;
      } else {
        _permissionGranted = await location.requestPermission();
        if (_permissionGranted != PermissionStatus.granted) {
          setState(() {
            showLocError = true;
          });
          return;
        } else {
          showLocError = false;
        }
      }
    } else {
      if (showLocError == true) {
        showLocError = false;
      }
    }

    Future.delayed(Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          showMap = true;
        });
      }
    });

    // controllerr = await _controller.future;
  }

  animateCam() async {
    _locationData = await location.getLocation();
    controllerr = await _controller.future;
    _getMarkerIcon();
  }

  Future _checkLocationEnabled() async {
    _locationData = await location.getLocation();

    controllerr.animateCamera(CameraUpdate.newLatLngZoom(
        LatLng(_locationData.latitude, _locationData.longitude), 16));
  }

  void _onCameraMove(CameraPosition position) {
    currentPosition = position.target;
  }

  // Future _goToCurrentLocation() async {
  //   _locationData = await location.getLocation();

  //   final GoogleMapController controller = await _controller.future;
  //   controller.animateCamera(CameraUpdate.newLatLngZoom(
  //       LatLng(_locationData.latitude, _locationData.longitude), 17));
  // }

  void _setMapStyle(GoogleMapController controller) async {
    String style = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style.json');
    controller.setMapStyle(style);
  }

  @override
  void initState() {
    super.initState();
    if (widget.pageId != null) {
      pageProfile = widget.pageId;
    }
    infoAnimCont =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));

    _checkConnection();
  }

  _checkConnection() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      if (internetError) internetError = false;
      if (retrying) retrying = false;
      _checkLocation();
    } else {
      setState(() {
        if (retrying) retrying = false;
        showProgress = false;
        internetError = true;
      });
    }
  }

  _getMarkerIcon() async {
    myIcon =
        await getBitmapDescriptorFromAssetBytes("assets/images/zzz.png", 150);

    if (pageProfile == "") {
      controllerr.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(_locationData.latitude, _locationData.longitude), 16));
    } else {
      controllerr.animateCamera(CameraUpdate.newLatLngZoom(
          LatLng(widget.mapLoc.latitude, widget.mapLoc.longitude), 16));
      markerImage = widget.pageImg;
      markerTitle = widget.pageName;
      markerPageAddress = widget.pageAddress;
      markerPageId = widget.pageId;

      Future.delayed(Duration(milliseconds: 1000), () {
        showInfoWindow = true;
        infoAnimCont.forward();
      });
      markers.add(Marker(
          icon: myIcon,
          markerId: MarkerId(widget.pageId),
          position: LatLng(widget.mapLoc.latitude, widget.mapLoc.longitude),
          onTap: () {
            markerImage = widget.pageImg;
            markerTitle = widget.pageName;
            markerPageAddress = widget.pageAddress;
            markerPageId = widget.pageId;
            setState(() {
              showInfoWindow = true;
            });
            infoAnimCont.forward();
          }));
    }

    _getMarkers();
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return SafeArea(
      bottom: false,
      child: Scaffold(
          body: internetError
              ? Container(
                  height: height - 50,
                  alignment: Alignment.center,
                  child:
                      Column(mainAxisSize: MainAxisSize.min, children: <Widget>[
                    Container(
                        child: Text(
                      'No Internet Connection',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                      ),
                    )),
                    Container(
                      margin: EdgeInsets.only(top: 20),
                      width: width / 3,
                      height: 30,
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(4),
                          gradient: LinearGradient(
                            colors: [
                              Color.fromRGBO(18, 42, 76, 1),
                              Color.fromRGBO(5, 150, 197, 1),
                              Color.fromRGBO(18, 42, 76, 1),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )),
                      child: Material(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                        clipBehavior: Clip.antiAlias,
                        child: InkWell(
                          onTap: () {
                            setState(() {
                              retrying = true;
                            });
                            Future.delayed(Duration(milliseconds: 500),
                                () async {
                              _checkConnection();
                            });
                          },
                          child: Center(
                              child: retrying
                                  ? Container(
                                      height: 15,
                                      width: 15,
                                      child: CircularProgressIndicator(
                                        valueColor: AlwaysStoppedAnimation(
                                            Colors.white),
                                        strokeWidth: 1,
                                      ),
                                    )
                                  : Text(
                                      'RETRY',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 16),
                                    )),
                        ),
                      ),
                    ),
                  ]))
              : !showLocError
                  ? Container(
                      width: width,
                      height: height,
                      child: Stack(
                        children: <Widget>[
                          GestureDetector(
                              onVerticalDragStart: showInfoWindow
                                  ? (a) {
                                      setState(() {
                                        showInfoWindow = false;
                                      });
                                      infoAnimCont.reverse();
                                    }
                                  : null,
                              onHorizontalDragStart: showInfoWindow
                                  ? (a) {
                                      setState(() {
                                        showInfoWindow = false;
                                      });
                                      infoAnimCont.reverse();
                                    }
                                  : null,
                              child: showMap
                                  ? GoogleMap(
                                      myLocationButtonEnabled: false,
                                      myLocationEnabled: true,
                                      zoomControlsEnabled: false,
                                      mapToolbarEnabled: false,
                                      initialCameraPosition: _kGooglePlex,
                                      padding: EdgeInsets.only(
                                          bottom: pageProfile != "" ? 5 : 45,
                                          top: 50,
                                          left: 5),
                                      markers: markers.toSet(),
                                      onMapCreated:
                                          (GoogleMapController controller) {
                                        _controller.complete(controller);
                                        controllerr = controller;
                                        _setMapStyle(controllerr);

                                        setState(() {
                                          showProgress = false;
                                        });
                                        animateCam();
                                      },
                                      onCameraMove: _onCameraMove,
                                      onTap: (latlng) {
                                        if (showInfoWindow) {
                                          setState(() {
                                            showInfoWindow = false;
                                          });
                                          infoAnimCont.reverse();
                                        }
                                      },
                                    )
                                  : Container(height: 0, width: 0)),
                          Positioned(
                            bottom: (height / 2) + 15,
                            width: width,
                            child: ScaleTransition(
                              scale: Tween(begin: 0.0, end: 1.0).animate(
                                  CurvedAnimation(
                                      parent: infoAnimCont,
                                      curve: Curves.bounceInOut)),
                              child: Center(
                                child: Container(
                                  // margin: EdgeInsets.only(bottom: height * 0.22),
                                  decoration: BoxDecoration(
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.8),
                                        spreadRadius: 0,
                                        blurRadius: 4,
                                        offset: Offset(
                                            0, 0), // changes position of shadow
                                      ),
                                    ],
                                    // borderRadius: BorderRadius.circular(5),
                                    // border: Border.all(
                                    //     color: Colors.white54, width: 0.5)
                                  ),
                                  child: Card(
                                    elevation: 6,
                                    color: Color.fromRGBO(55, 57, 56, 1.0),
                                    child: Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0,
                                          top: 8,
                                          left: 8,
                                          right: 8),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: <Widget>[
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              Card(
                                                margin: EdgeInsets.all(0),
                                                clipBehavior: Clip.antiAlias,
                                                child: Container(
                                                    child: markerImage == ""
                                                        ? null
                                                        : CachedNetworkImage(
                                                            imageUrl:
                                                                markerImage,
                                                            fit: BoxFit.fill),
                                                    width: width * 0.25,
                                                    height: width * 0.25),
                                              ),
                                              Container(
                                                margin:
                                                    EdgeInsets.only(left: 8),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  children: <Widget>[
                                                    Container(
                                                        child: Text(markerTitle,
                                                            style: TextStyle(
                                                                fontSize: 16,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontFamily:
                                                                    "Lobster",
                                                                letterSpacing:
                                                                    2))),
                                                    Container(
                                                      margin: EdgeInsets.only(
                                                          top: 5),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: <Widget>[
                                                          Icon(
                                                              Icons.location_on,
                                                              color:
                                                                  Colors.green,
                                                              size: 15),
                                                          Container(
                                                              constraints:
                                                                  BoxConstraints(
                                                                      maxWidth:
                                                                          width *
                                                                              0.5),
                                                              margin: EdgeInsets
                                                                  .only(
                                                                      left: 3),
                                                              child: Text(
                                                                  markerPageAddress,
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize:
                                                                        12,
                                                                    color: Colors
                                                                        .white70,
                                                                  ))),
                                                        ],
                                                      ),
                                                    ),
                                                    pageProfile != ""
                                                        ? Container()
                                                        : Container(
                                                            margin:
                                                                EdgeInsets.only(
                                                                    top: 10),
                                                            clipBehavior:
                                                                Clip.antiAlias,
                                                            decoration:
                                                                BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                                4),
                                                                    gradient:
                                                                        LinearGradient(
                                                                      colors: [
                                                                        Color.fromRGBO(
                                                                            18,
                                                                            42,
                                                                            76,
                                                                            1),
                                                                        Color.fromRGBO(
                                                                            5,
                                                                            150,
                                                                            197,
                                                                            1),
                                                                        Color.fromRGBO(
                                                                            18,
                                                                            42,
                                                                            76,
                                                                            1),
                                                                      ],
                                                                      begin: Alignment
                                                                          .topLeft,
                                                                      end: Alignment
                                                                          .bottomRight,
                                                                    )),
                                                            child: Material(
                                                              color: Colors
                                                                  .transparent,
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          4),
                                                              clipBehavior: Clip
                                                                  .antiAlias,
                                                              child: InkWell(
                                                                onTap: () {
                                                                  Navigator.push(
                                                                      context,
                                                                      MaterialPageRoute(
                                                                          builder: (context) => PageActivity(
                                                                              markerPageId,
                                                                              'maps')));
                                                                },
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                              .all(
                                                                          8.0),
                                                                  child: Center(
                                                                    child: Text(
                                                                        'Visit Page',
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize: 12)),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                  ],
                                                ),
                                              )
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                              top: 20,
                              right: 5,
                              child: FloatingActionButton(
                                heroTag: 'locationBtn',
                                mini: true,
                                onPressed: () {
                                  _checkLocationEnabled();
                                  if (showInfoWindow) {
                                    setState(() {
                                      showInfoWindow = false;
                                    });
                                    infoAnimCont.reverse();
                                  }
                                },
                                backgroundColor: Color(0xFF282828),
                                child: Icon(Icons.my_location,
                                    color: Colors.white),
                              )),
                          Positioned(
                              bottom: pageProfile != "" ? 20 : 70,
                              right: 5,
                              child: Column(
                                children: <Widget>[
                                  FloatingActionButton(
                                      heroTag: 'zoomBtn',
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      mini: true,
                                      onPressed: () async {
                                        double zoomLevel =
                                            await controllerr.getZoomLevel();
                                        zoomLevel += 1;
                                        controllerr.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                    target: currentPosition,
                                                    zoom: zoomLevel)));
                                      },
                                      backgroundColor: Color(0xFF282828),
                                      child:
                                          Icon(Icons.add, color: Colors.white)),
                                  FloatingActionButton(
                                      heroTag: 'zoomOutBtn',
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      mini: true,
                                      onPressed: () async {
                                        double zoomLevel =
                                            await controllerr.getZoomLevel();
                                        zoomLevel -= 1;
                                        controllerr.animateCamera(
                                            CameraUpdate.newCameraPosition(
                                                CameraPosition(
                                                    target: currentPosition,
                                                    zoom: zoomLevel)));
                                      },
                                      backgroundColor: Color(0xFF282828),
                                      child: Icon(Icons.remove,
                                          color: Colors.white)),
                                ],
                              )),
                          Positioned(
                              top: 0,
                              left: 0,
                              child: showProgress
                                  ? Container(
                                      color: Colors.black,
                                      height: height - 50,
                                      width: width,
                                      child: Center(
                                          child: Container(
                                              width: 50,
                                              height: 50,
                                              child: FlareActor(
                                                'assets/loading.flr',
                                                animation: 'Loading',
                                              ))))
                                  : Container(height: 0, width: 0))
                        ],
                      ),
                    )
                  : Container(
                      height: height - 50,
                      alignment: Alignment.center,
                      child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Text('Location Service is disabled',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                )),
                            showIosError?Container(margin:EdgeInsets.only(top:15),
                              child: Text('Please enable location from your mobile settings',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 18,
                                  )),
                            ):Row(
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Container(
                                  margin: EdgeInsets.only(top: 20),
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(4),
                                      gradient: LinearGradient(
                                        colors: [
                                          Color.fromRGBO(18, 42, 76, 1),
                                          Color.fromRGBO(5, 150, 197, 1),
                                          Color.fromRGBO(18, 42, 76, 1),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      )),
                                  child: Material(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(4),
                                    clipBehavior: Clip.antiAlias,
                                    child: InkWell(
                                      onTap: () {
                                        _checkLocation();
                                      },
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                            left: 12,
                                            right: 12,
                                            top: 8,
                                            bottom: 8),
                                        child: Center(
                                          child: Text('Enable',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ]))),
    );
  }
}
