import 'package:context_holder/context_holder.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:fluster/fluster.dart';
import 'package:geocoder/geocoder.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:house_input/data/property.dart';
import 'package:house_input/services/map_helper.dart';
import 'package:house_input/services/map_marker.dart';

class Similar extends StatefulWidget {
  final List<Property> properties;

  const Similar({Key key, this.properties}) : super(key: key);
  @override
  _SimilarState createState() => _SimilarState();
}

class _SimilarState extends State<Similar> {
  final Completer<GoogleMapController> _mapController = Completer();

  /// Set of displayed markers and cluster markers on the map
  final Set<Marker> _markers = Set();

  /// Minimum zoom at which the markers will cluster
  final int _minClusterZoom = 0;

  /// Maximum zoom at which the markers will cluster
  final int _maxClusterZoom = 19;

  /// [Fluster] instance used to manage the clusters
  Fluster<MapMarker> _clusterManager;

  /// Current map zoom. Initial zoom will be 15, street level
  double _currentZoom = 15;

  /// Map loading flag
  bool _isMapLoading = true;

  /// Markers loading flag
  bool _areMarkersLoading = true;

  /// Url image used on normal markers
  final String _markerImageUrl =
      'https://img.icons8.com/office/80/000000/marker.png';

  /// Color of the cluster circle
  final Color _clusterColor = Colors.blue;
  static LatLng _locationOnMap;

  /// Color of the cluster text
  final Color _clusterTextColor = Colors.white;
  List<LatLng> _markerLocations = [];
  var results;
  Future _future;
  void _showModal(var e) {
    Future<void> future = showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.warning),
                title: Text("Error occured: " + e.toString()),
              ),
              // ListTile(
              //   leading: Icon(Icons.close),
              //   title: Text("Cancel"),

              // ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getCoordinates(List<Property> propertylst) async {
    // print("a");
    for (Property i in propertylst) {
      try {
        results = await Geocoder.local.findAddressesFromQuery(i.address);
        // var test = await Geocoder.local.findAddressesFromQuery('275.Bis, Đường Lê Đức Thọ||7083, Phường 16, Quận Gò Vấp, Tp Hồ Chí Minh');
        // print(i.address);
        // if (mounted) {
        //   setState(() {
        //     _markerLocations.add(LatLng(results.first.coordinates.latitude,
        //         results.first.coordinates.longitude));
        //   });
        //   setState(() {
        //     _locationOnMap = _markerLocations[0];
        //   });
        // }

      }

      // first = results.first;
      // kInitialPosition = CameraPosition(
      //     target: _locationOnMap, zoom: 15.0, tilt: 0, bearing: 0);
      // print("${first.featureName} : ${first.coordinates}");
      catch (e) {
        _showModal(e);
        // print("Error occured: $e");
      }
      if (mounted) {
        setState(() {
          i.coordinate = LatLng(results.first.coordinates.latitude,
              results.first.coordinates.longitude);
          _markerLocations.add(LatLng(results.first.coordinates.latitude,
              results.first.coordinates.longitude));
        });
      } else
        continue;
    }
    setState(() {
      _locationOnMap = propertylst[0].coordinate;
    });
    return _markerLocations;
  }

  @override
  void initState() {
    super.initState();
    _future = getCoordinates(widget.properties);
  }

  Future<void> _updateMarkers([double updatedZoom]) async {
    if (_clusterManager == null || updatedZoom == _currentZoom) return;

    if (updatedZoom != null) {
      _currentZoom = updatedZoom;
    }

    setState(() {
      _areMarkersLoading = true;
    });

    final updatedMarkers = await MapHelper.getClusterMarkers(_clusterManager,
        _currentZoom, _clusterColor, _clusterTextColor, 80, widget.properties);

    _markers
      ..clear()
      ..addAll(updatedMarkers);

    setState(() {
      _areMarkersLoading = false;
    });
  }

  void _initMarkers() async {
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
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return Scaffold(
              floatingActionButton: FloatingActionButton(
                onPressed: () {
                  showMyBottomSheet(context);
                },
                child: const Icon(
                  Icons.navigation,
                  color: Colors.blue,
                ),
                backgroundColor: Colors.white,
              ),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
              appBar: AppBar(
                backgroundColor: Colors.black.withOpacity(0.7),
                title: Text('Similar House Nearby'),
              ),
              body: Stack(
                children: <Widget>[
                  // Google Map widget
                  Opacity(
                    opacity: _isMapLoading ? 0 : 1,
                    child: Container(
                      // height: MediaQuery.of(context).size.height,
                      child: Scaffold(
                        body: GoogleMap(
                          // minMaxZoomPreference: MinMaxZoomPreference(min),
                          mapToolbarEnabled: true,
                          zoomGesturesEnabled: true,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          // zoomControlsEnabled: true,
                          initialCameraPosition: CameraPosition(
                            target: _locationOnMap,
                            zoom: _currentZoom,
                          ),
                          markers: _markers,
                          onMapCreated: (controller) =>
                              _onMapCreated(controller),
                          onCameraMove: (position) =>
                              _updateMarkers(position.zoom),
                        ),
                      ),
                    ),
                  ),

                  // Map loading indicator
                  Opacity(
                    opacity: _isMapLoading ? 1 : 0,
                    child: Center(child: CircularProgressIndicator()),
                  ),

                  // Map markers loading indicator
                  if (_areMarkersLoading)
                    Padding(
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
        });
  }

  Widget _buildListView(
      List<Property> properties, ScrollController controller) {
    return properties.length != 0
        ? ListView.builder(
            controller: controller,
            itemBuilder: (_, idx) {
              return buildProperty(properties[idx]);
            },
            itemCount: properties.length,
          )
        : _buildNoDataScreen();
  }

  Widget _buildNoDataScreen() {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      //padding: EdgeInsets.all(10.0),
      child: Center(
        // height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset("images/nodata2.png",
                  // height: 200,
                  // width: MediaQuery.of(context).size.width,
                  fit: BoxFit.contain),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                "No data found",
                style: TextStyle(color: Colors.grey, fontSize: 36),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildProperty(Property property) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GestureDetector(
        // onTap: () async {
        // print(property.address);
        // property.address != null
        //     ? await getCoordinates(property.address)
        //     : await getCoordinates(property.district + ' ' + property.region);
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //         builder: (context) => property.address != null
        //             ? Detail(
        //                 property: property,
        //                 address: property.address,
        //               )
        //             : Detail(
        //                 property: property,
        //                 address: property.district + ' ' + property.region,
        //               )),
        //   );
        // },
        child: Card(
          margin: EdgeInsets.only(top: 0, bottom: 0),
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          child: Container(
            height: 210,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(property.imgLink),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.5),
                    Colors.transparent,
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
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
                      child: Text(
                        property.category,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(),
                  ),
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            property.region,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            property.price.toString() + "B VNĐ",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                color: Colors.white,
                                size: 14,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                property.district.split("d ")[1].toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Icon(
                                Icons.zoom_out_map,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                property.surface + "m\u00B2",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.star,
                                color: Colors.yellow[700],
                                size: 14,
                              ),
                              SizedBox(
                                width: 4,
                              ),
                              Text(
                                property.date.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void showMyBottomSheet(BuildContext context) {
    showModalBottomSheet<dynamic>(
      context: ContextHolder.currentContext,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      builder: (_) {
        return DraggableScrollableSheet(
          // maxChildSize: 0.8,
          minChildSize: 0.3,
          expand: false,
          builder: (_, controller) {
            return Column(
              children: [
                Container(
                  width: 100,
                  height: 8,
                  margin: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey,
                  ),
                ),
                Expanded(child: _buildListView(widget.properties, controller)),
              ],
            );
          },
        );
      },
    );
  }
}
