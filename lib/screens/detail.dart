import 'dart:async';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:house_input/services/map_helper.dart';
import 'package:house_input/services/map_marker.dart';
import '../data/property.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Detail extends StatefulWidget {
  final Property property;
  final String address;
  final List<Property> similarProperties;

  Detail(
      {@required this.property,
      @required this.address,
      this.similarProperties});

  @override
  _DetailState createState() => _DetailState();
}

class _DetailState extends State<Detail> {
  List<LatLng> _markerLocations = [];
  List<String> addresses = [];
  Future _future;

  final Completer<GoogleMapController> _mapController = Completer();
  final Set<Marker> _markers = Set();
  final int _minClusterZoom = 0;
  final int _maxClusterZoom = 19;
  Fluster<MapMarker> _clusterManager;
  double _currentZoom = 15;
  bool _isMapLoading = true;
  bool _areMarkersLoading = true;
  final String _markerImageUrl =
      'https://img.icons8.com/ios-filled/80/4a90e2/marker.png';
  // 'https://img.icons8.com/office/80/000000/marker.png';
  final Color _clusterColor = Colors.blue;
  final Color _clusterTextColor = Colors.white;
  // static LatLng _locationOnMap = LatLng(10.838677899999999, 106.66529039999999);
  // Future getCoordinates(String address) async {
  //   try {
  //     var results = await Geocoder.local.findAddressesFromQuery(address);
  //     var first = results.first;
  //     _locationOnMap =
  //         LatLng(first.coordinates.latitude, first.coordinates.longitude);
  //     print("${first.featureName} ${first.coordinates}");
  //   } catch (e) {
  //     print("Error occured: $e");
  //   }
  // }
  // static LatLng _locationOnMap = locationOnMap;
  // CameraPosition _kInitialPosition = CameraPosition(
  //     target: widget.locationOnMap, zoom: 15.0, tilt: 0, bearing: 0);
  Future<void> _copyToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.property.phoneNumber));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }

  Future<void> _copyUrlToClipboard() async {
    await Clipboard.setData(ClipboardData(text: widget.property.url));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('Copied to clipboard'),
    ));
  }

  Widget _displayUrlDialog() {
    return AlertDialog(
      title: Text(
        'Url of this post',
        style: TextStyle(fontSize: 22),
      ),
      content: (widget.property.url != null)
          ? Text(
              widget.property.url,
              textAlign: TextAlign.center,
            )
          : Text("No data"),
      actions: <Widget>[
        TextButton(
          child: Text(
            'CANCEL',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(
            'Copy',
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () {
            _copyUrlToClipboard();
          },
        ),
      ],
    );
  }

  Widget _displayDialog() {
    return AlertDialog(
      title: Text(
        'Seller\'s phone number',
        style: TextStyle(fontSize: 22),
      ),
      content: (widget.property.phoneNumber != null)
          ? Text(
              widget.property.phoneNumber,
              textAlign: TextAlign.center,
            )
          : Text("No data"),
      actions: <Widget>[
        TextButton(
          child: Text(
            'CANCEL',
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        TextButton(
          child: Text(
            'Copy',
            style: TextStyle(color: Colors.white),
          ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(Colors.black),
          ),
          onPressed: () {
            _copyToClipboard();
          },
        ),
      ],
    );
  }

  static CameraPosition kInitialPosition;
  static LatLng _locationOnMap = LatLng(10.838677899999999, 106.66529039999999);
  Future<void> getCoordinates(
      String address, List<Property> propertylst) async {
    try {
      var results = await Geocoder.local.findAddressesFromQuery(address);
      var first = results.first;
      _locationOnMap =
          LatLng(first.coordinates.latitude, first.coordinates.longitude);
      kInitialPosition = CameraPosition(
          target: _locationOnMap, zoom: 15.0, tilt: 0, bearing: 0);
      // print("${first.featureName} : ${first.coordinates}");
    } catch (e) {
      print("Error occured: $e");
    }
    for (Property i in propertylst) {
      try {
        var similarResults =
            await Geocoder.local.findAddressesFromQuery(i.address);
        if (mounted) {
          setState(() {
            i.coordinate = LatLng(similarResults.first.coordinates.latitude,
                similarResults.first.coordinates.longitude);
            _markerLocations.add(LatLng(
                similarResults.first.coordinates.latitude,
                similarResults.first.coordinates.longitude));
          });
          // setState(() {
          //   _locationOnMap = _markerLocations[0];
          // });
        } else
          continue;
      } catch (e) {
        print("Error occured: $e");
      }
    }
    // print(_locationOnMap);
    return _markerLocations;
  }

  // void getAddresses(List<Property> properties) {
  //   for (Property i in properties) {
  //     setState(() {
  //       addresses.add(i.address);
  //     });
  //   }
  // }

  Future<void> _updateMarkers([double updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(
        _clusterManager,
        _currentZoom,
        _clusterColor,
        _clusterTextColor,
        80,
        widget.similarProperties);

    _markers
      ..clear()
      ..add(
        Marker(markerId: MarkerId("marker_1"), position: _locationOnMap),
      )
      ..addAll(updatedMarkers);
    setState(() {
      _areMarkersLoading = false;
    });
  }

  void _initMarkers() async {
    // print(_markerLocations);
    // await getCoordinates(addresses);
    // await getOnMapLocation();
    // print(addresses);
    final List<MapMarker> markers = [];

    for (LatLng markerLocation in _markerLocations) {
      final BitmapDescriptor markerImage =
          await MapHelper.getMarkerImageFromUrl(_markerImageUrl);

      markers.add(
        MapMarker(
          id: _markerLocations.indexOf(markerLocation).toString(),
          position: markerLocation,
          icon: markerImage,
        ),
      );
    }

    _clusterManager = await MapHelper.initClusterManager(
        markers, _minClusterZoom, _maxClusterZoom);

    await _updateMarkers();
  }

  void _onMapCreated(GoogleMapController controller) async {
    _mapController.complete(controller);
    setState(() {
      _isMapLoading = false;
    });

    _initMarkers();
  }

  @override
  void initState() {
    super.initState();
    // getAddresses(widget.similarProperties);
    _future = getCoordinates(widget.address, widget.similarProperties);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        // print(snapshot);
        if (snapshot.connectionState == ConnectionState.done) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                // Hero(
                //   tag: "images/ih2.png",
                //   child: Container(
                //     height: size.height * 0.8,
                //     decoration: BoxDecoration(
                //       image: DecorationImage(
                //         image: AssetImage("images/ih2.png"),
                //         fit: BoxFit.cover,
                //       ),
                //     ),
                //     child: Container(
                //       decoration: BoxDecoration(
                //         gradient: LinearGradient(
                //           begin: Alignment.topCenter,
                //           end: Alignment.bottomCenter,
                //           colors: [
                //             Colors.transparent,
                //             Colors.black.withOpacity(1),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ),
                // ),
                Container(
                  // decoration: BoxDecoration(
                  //   gradient: LinearGradient(
                  //     begin: Alignment.topCenter,
                  //     end: Alignment.bottomCenter,
                  //     colors: [
                  //       Colors.transparent,
                  //       Colors.black.withOpacity(1),
                  //     ],
                  //   ),
                  // ),
                  height: size.height * 0.4,
                  child: GoogleMap(
                    initialCameraPosition: kInitialPosition,
                    markers: _markers,
                    // _createMarker(),
                    // padding: EdgeInsets.symmetric(20),
                    // liteModeEnabled: true,
                    // zoomGesturesEnabled: true,
                    zoomControlsEnabled: false,
                    onMapCreated: (controller) => _onMapCreated(controller),
                    onCameraMove: (position) => _updateMarkers(position.zoom),
                  ),
                ),
                if (_areMarkersLoading)
                  Container(
                    height: size.height * 0.4,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: Card(
                          elevation: 2,
                          color: Colors.grey.withOpacity(0.9),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Text(
                              'Loading',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 24),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                Container(
                  height: size.height * 0.35,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 48),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: Icon(
                                Icons.arrow_back_ios,
                                color: Colors.black,
                                size: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Container(),
                      ),
                      Padding(
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.yellow[700],
                            borderRadius: BorderRadius.all(
                              Radius.circular(5),
                            ),
                          ),
                          width: 80,
                          padding: EdgeInsets.symmetric(
                            vertical: 4,
                          ),
                          child: Center(
                            child: (widget.property.category != null)
                                ? Text(
                                    widget.property.category,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  )
                                : Text(
                                    "No data",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: EdgeInsets.symmetric(horizontal: 24),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Text(
                      //         widget.property.region,
                      //         style: TextStyle(
                      //           color: Colors.black,
                      //           fontSize: 32,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //       ),
                      //       // Container(
                      //       //   height: 50,
                      //       //   width: 50,
                      //       //   decoration: BoxDecoration(
                      //       //     color: Colors.white,
                      //       //     shape: BoxShape.circle,
                      //       //   ),
                      //       //   child: Center(
                      //       //     child: Icon(
                      //       //       Icons.favorite,
                      //       //       color: Colors.yellow[700],
                      //       //       size: 20,
                      //       //     ),
                      //       //   ),
                      //       // ),
                      //     ],
                      //   ),
                      // ),
                      // Padding(
                      //   padding: EdgeInsets.only(
                      //     left: 60,
                      //     right: 24,
                      //     top: 8,
                      //     bottom: 8,
                      //   ),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     children: [
                      //       Row(
                      //         children: [
                      //           Icon(
                      //             Icons.location_on,
                      //             color: Colors.black,
                      //             size: 16,
                      //           ),
                      //           SizedBox(
                      //             width: 4,
                      //           ),
                      //           Text(
                      //             widget.property.district,
                      //             style: TextStyle(
                      //               color: Colors.black,
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //           SizedBox(
                      //             width: 8,
                      //           ),
                      //           Icon(
                      //             Icons.zoom_out_map,
                      //             color: Colors.black,
                      //             size: 16,
                      //           ),
                      //           SizedBox(
                      //             width: 4,
                      //           ),
                      //           Text(
                      //             widget.property.surface + "m\u00B2",
                      //             style: TextStyle(
                      //               color: Colors.black,
                      //               fontSize: 16,
                      //               fontWeight: FontWeight.bold,
                      //             ),
                      //           ),
                      //         ],
                      //       ),
                      //       // Row(
                      //       //   children: [
                      //       //     Icon(
                      //       //       Icons.star,
                      //       //       color: Colors.yellow[700],
                      //       //       size: 16,
                      //       //     ),
                      //       //     SizedBox(
                      //       //       width: 4,
                      //       //     ),
                      //       //     Text(
                      //       //       " Floors",
                      //       //       style: TextStyle(
                      //       //         color: Colors.white,
                      //       //         fontSize: 16,
                      //       //         fontWeight: FontWeight.bold,
                      //       //       ),
                      //       //     ),
                      //       //   ],
                      //       // ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: size.height * 0.6,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(0),
                        topRight: Radius.circular(0),
                      ),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(
                                bottom: 24, left: 24, right: 24, top: 24),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    // Container(
                                    //   height: 65,
                                    //   width: 65,
                                    //   decoration: BoxDecoration(
                                    //     image: DecorationImage(
                                    //       image: AssetImage(property.ownerImage),
                                    //       fit: BoxFit.cover,
                                    //     ),
                                    //     shape: BoxShape.circle,
                                    //   ),
                                    // ),
                                    // SizedBox(
                                    //   width: 16,
                                    // ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        (widget.property.user != null)
                                            ? ConstrainedBox(
                                                constraints: BoxConstraints(
                                                    maxWidth: 200),
                                                child: SingleChildScrollView(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  child: Text(
                                                    widget.property.user,
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              )
                                            : Text(
                                                "No Data",
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                        SizedBox(
                                          height: 4,
                                        ),
                                        (widget.property.user != null)
                                            ? Text(
                                                widget.property.homepage,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey[500],
                                                ),
                                              )
                                            : Text(
                                                "No data",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: Colors.grey[500],
                                                ),
                                              ),
                                      ],
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.yellow[700].withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                          onPressed: () => showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  _displayDialog()),
                                          icon: Icon(
                                            Icons.phone,
                                            color: Colors.yellow[700],
                                            size: 20,
                                          )),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.yellow[700].withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        onPressed: () => showDialog(
                                            context: context,
                                            builder: (context) =>
                                                _displayUrlDialog()),
                                        icon: Icon(
                                          Icons.message,
                                          color: Colors.yellow[700],
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 24,
                              left: 24,
                              bottom: 24,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    buildFeature(
                                        Icons.monetization_on_sharp,
                                        widget.property.price.toString() +
                                            "B VNĐ"),
                                    buildFeature(Icons.location_on,
                                        widget.property.region),
                                    buildFeature(
                                        Icons.location_city_outlined,
                                        widget.property.district
                                            .split("d ")[1]),
                                    // buildFeature(Icons.hotel, widget.property.beds),
                                    // buildFeature(Icons.wc, widget.property.toilets),
                                    // buildFeature(Icons.kitchen, "1 Kitchen"),
                                    // buildFeature(Icons.local_parking, "2 Parking"),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 20),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      // buildFeature(Icons.monetization_on_sharp,
                                      //     widget.property.price.toString()),
                                      // buildFeature(
                                      //     Icons.location_on, widget.property.region),
                                      // buildFeature(Icons.location_city_outlined,
                                      //     widget.property.district.split("d ")[1]),
                                      buildFeature(
                                          Icons.hotel, widget.property.beds),
                                      buildFeature(
                                          Icons.wc, widget.property.toilets),
                                      buildFeature(
                                          Icons.zoom_out_map,
                                          widget.property.surface.toString() +
                                              "m\u00B2"),
                                      buildFeature(
                                          Icons.swap_vert_rounded,
                                          widget.property.length.toString() +
                                              "m"),
                                      buildFeature(
                                          Icons.swap_horiz_rounded,
                                          widget.property.width.toString() +
                                              "m"),

                                      // buildFeature(Icons.kitchen, "1 Kitchen"),
                                      // buildFeature(Icons.local_parking, "2 Parking"),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 24,
                              left: 24,
                              bottom: 16,
                            ),
                            child: Text(
                              "Description",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 24,
                              left: 24,
                              bottom: 24,
                            ),
                            child:
                                // "Description",
                                (widget.property.description != null)
                                    ? ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: 200, maxWidth: 350),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Text(
                                            widget.property.description,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "No Data",
                                        // widget.property.description,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 24,
                              left: 24,
                              bottom: 16,
                            ),
                            child: Text(
                              "Address",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: 24,
                              left: 24,
                              bottom: 24,
                            ),
                            child:
                                // "Description",
                                (widget.property.address != null)
                                    ? ConstrainedBox(
                                        constraints: BoxConstraints(
                                            maxHeight: 200, maxWidth: 350),
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Text(
                                            widget.property.address,
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.grey[500],
                                            ),
                                          ),
                                        ),
                                      )
                                    : Text(
                                        "No Data",
                                        // widget.property.description,
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                          ),
                          // Padding(
                          //   padding: EdgeInsets.only(
                          //     right: 24,
                          //     left: 24,
                          //     bottom: 16,
                          //   ),
                          //   child: Text(
                          //     "Photos",
                          //     style: TextStyle(
                          //       fontSize: 20,
                          //       fontWeight: FontWeight.bold,
                          //     ),
                          //   ),
                          // ),
                          // Expanded(
                          //   child: Padding(
                          //     padding: EdgeInsets.only(
                          //       bottom: 24,
                          //     ),
                          //     child: ListView(
                          //       physics: BouncingScrollPhysics(),
                          //       scrollDirection: Axis.horizontal,
                          //       shrinkWrap: true,
                          //       children: buildPhotos(property.images),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return Scaffold(
          body: Center(
            child: Container(
              width: 80,
              height: 80,
              child: CircularProgressIndicator(
                strokeWidth: 10,
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.black.withOpacity(0.7)),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget buildFeature(IconData iconData, String text) {
    return Column(
      children: [
        Icon(
          iconData,
          color: Colors.yellow[700],
          size: 28,
        ),
        SizedBox(
          height: 8,
        ),
        (text != null)
            ? Text(
                text,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                maxLines: 2,
              )
            : Text(
                '?',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 14,
                ),
              ),
      ],
    );
  }

  // Widget _buildMap() {
  //   Size size = MediaQuery.of(context).size;
  //   return
  // }

  Set<Marker> _createMarker() {
    return {
      Marker(markerId: MarkerId("marker_1"), position: _locationOnMap),
    };
  }
  // List<Widget> buildPhotos(List<String> images) {
  //   List<Widget> list = [];
  //   list.add(SizedBox(
  //     width: 24,
  //   ));
  //   for (var i = 0; i < images.length; i++) {
  //     list.add(buildPhoto(images[i]));
  //   }
  //   return list;
  // }

  // Widget buildPhoto(String url) {
  //   return AspectRatio(
  //     aspectRatio: 3 / 2,
  //     child: Container(
  //       margin: EdgeInsets.only(right: 24),
  //       decoration: BoxDecoration(
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(10),
  //         ),
  //         image: DecorationImage(
  //           image: AssetImage(url),
  //           fit: BoxFit.cover,
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
