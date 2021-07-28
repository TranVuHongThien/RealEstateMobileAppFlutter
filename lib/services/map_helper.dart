import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:context_holder/context_holder.dart';
import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
// import 'package:flutter_google_maps_clusters/helpers/map_marker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:house_input/data/property.dart';
import 'package:house_input/screens/details.dart';
import 'package:house_input/services/map_marker.dart';

/// In here we are encapsulating all the logic required to get marker icons from url images
/// and to show clusters using the [Fluster] package.
class MapHelper {
  /// If there is a cached file and it's not old returns the cached marker image file
  /// else it will download the image and save it on the temp dir and return that file.
  ///
  /// This mechanism is possible using the [DefaultCacheManager] package and is useful
  /// to improve load times on the next map loads, the first time will always take more
  /// time to download the file and set the marker image.
  ///
  /// You can resize the marker image by providing a [targetWidth].
  static Future<BitmapDescriptor> getMarkerImageFromUrl(
    String url, {
    int targetWidth,
  }) async {
    final File markerImageFile = await DefaultCacheManager().getSingleFile(url);

    Uint8List markerImageBytes = await markerImageFile.readAsBytes();

    if (targetWidth != null) {
      markerImageBytes = await _resizeImageBytes(
        markerImageBytes,
        targetWidth,
      );
    }

    return BitmapDescriptor.fromBytes(markerImageBytes);
  }

  /// Draw a [clusterColor] circle with the [clusterSize] text inside that is [width] wide.
  ///
  /// Then it will convert the canvas to an image and generate the [BitmapDescriptor]
  /// to be used on the cluster marker icons.
  static Future<BitmapDescriptor> _getClusterMarker(
    int clusterSize,
    Color clusterColor,
    Color textColor,
    int width,
  ) async {
    final PictureRecorder pictureRecorder = PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color = clusterColor;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    final double radius = width / 2;

    canvas.drawCircle(
      Offset(radius, radius),
      radius,
      paint,
    );

    textPainter.text = TextSpan(
      text: clusterSize.toString(),
      style: TextStyle(
        fontSize: radius - 5,
        fontWeight: FontWeight.bold,
        color: textColor,
      ),
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(radius - textPainter.width / 2, radius - textPainter.height / 2),
    );

    final image = await pictureRecorder.endRecording().toImage(
          radius.toInt() * 2,
          radius.toInt() * 2,
        );
    final data = await (image.toByteData(
      format: ImageByteFormat.png,
    ) as FutureOr<ByteData>);

    return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
  }

  /// Resizes the given [imageBytes] with the [targetWidth].
  ///
  /// We don't want the marker image to be too big so we might need to resize the image.
  static Future<Uint8List> _resizeImageBytes(
    Uint8List imageBytes,
    int targetWidth,
  ) async {
    final Codec imageCodec = await instantiateImageCodec(
      imageBytes,
      targetWidth: targetWidth,
    );

    final FrameInfo frameInfo = await imageCodec.getNextFrame();

    final ByteData byteData = await (frameInfo.image.toByteData(
      format: ImageByteFormat.png,
    ) as FutureOr<ByteData>);

    return byteData.buffer.asUint8List();
  }

  /// Inits the cluster manager with all the [MapMarker] to be displayed on the map.
  /// Here we're also setting up the cluster marker itself, also with an [clusterImageUrl].
  ///
  /// For more info about customizing your clustering logic check the [Fluster] constructor.
  static Future<Fluster<MapMarker>> initClusterManager(
    List<MapMarker> markers,
    int minZoom,
    int maxZoom,
  ) async {
    return Fluster<MapMarker>(
      minZoom: minZoom,
      maxZoom: maxZoom,
      radius: 150,
      extent: 2048,
      nodeSize: 64,
      points: markers,
      createCluster: (
        BaseCluster cluster,
        double lng,
        double lat,
      ) =>
          MapMarker(
        id: cluster.id.toString(),
        position: LatLng(lat, lng),
        isCluster: cluster.isCluster,
        clusterId: cluster.id,
        pointsSize: cluster.pointsSize,
        childMarkerId: cluster.childMarkerId,
      ),
    );
  }

  /// Gets a list of markers and clusters that reside within the visible bounding box for
  /// the given [currentZoom]. For more info check [Fluster.clusters].
  static Future<List<Marker>> getClusterMarkers(
    Fluster<MapMarker> clusterManager,
    double currentZoom,
    Color clusterColor,
    Color clusterTextColor,
    int clusterWidth,
    List<Property> propertylst,
    // GoogleMapController controller,
  ) {
    if (clusterManager == null) return Future.value([]);
    // void _closeModal(void value) {}
    return Future.wait(clusterManager.clusters(
      [-180, -85, 180, 85],
      currentZoom.toInt(),
    ).map((mapMarker) async {
      mapMarker.onMarkerTap = () {
        bool _isLoading = true;
        List<Property> properties = [];
        for (Property i in propertylst) {
          if (i.coordinate.latitude <=
                  mapMarker.position.latitude + 0.00045 / 1.5 &&
              i.coordinate.latitude >=
                  mapMarker.position.latitude - 0.00045 / 1.5 &&
              i.coordinate.longitude >=
                  mapMarker.position.longitude - 0.004120 / 1.5 &&
              i.coordinate.longitude <=
                  mapMarker.position.longitude + 0.004120 / 1.5) {
            properties.add(i);
          }
        }
        Widget buildProperty(Property property) {
          return Padding(
            padding: const EdgeInsets.all(10.0),
            child: GestureDetector(
              onTap: () async {
                Navigator.push(
                  ContextHolder.currentContext,
                  MaterialPageRoute(
                      builder: (context) => property.address != null
                          ? Details(
                              property: property,
                              address: property.address,
                            )
                          : Details(
                              property: property,
                              address:
                                  property.district + ' ' + property.region,
                            )),
                );
              },
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
                                      property.district
                                          .split("d ")[1]
                                          .toString(),
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

        // showModalBottomSheet(
        //   context: ContextHolder.currentContext,
        //   isScrollControlled: true, // set this to true
        //   builder: (_) {
        //     return DraggableScrollableSheet(
        //       expand: false,
        //       builder: (_, controller) {
        //         return Container(
        //           color: Colors.blue[500],
        //           child: ListView.builder(
        //             controller: controller, // set this too
        //             itemBuilder: (_, i) => ListTile(title: Text('Item $i')),
        //           ),
        //         );
        //       },
        //     );
        //   },
        // );
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
                    Expanded(
                        // child: Text(mapMarker.position.toString()),
                        child:
                            // _buildListView(properties, controller)
                            properties.length != 0
                                ? ListView.builder(
                                    controller: controller,
                                    itemBuilder: (_, idx) {
                                      return buildProperty(properties[idx]);
                                    },
                                    itemCount: properties.length)
                                : ListView.builder(
                                    controller: controller,
                                    itemCount: 1,
                                    itemBuilder: (_, idx) {
                                      return Container(
                                        height: MediaQuery.of(
                                                ContextHolder.currentContext)
                                            .size
                                            .height,
                                        width: MediaQuery.of(
                                                ContextHolder.currentContext)
                                            .size
                                            .width,
                                        //padding: EdgeInsets.all(10.0),
                                        child: Center(
                                          // height: MediaQuery.of(context).size.height * 0.5,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(10.0),
                                                child: Image.asset(
                                                  "images/nodata2.png",
                                                  scale: 0.5,
                                                  // height: 200,
                                                  // width: MediaQuery.of(context).size.width,
                                                ),
                                              ),
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(0.0),
                                                child: Text(
                                                  "No data found",
                                                  style: TextStyle(
                                                      color: Colors.grey,
                                                      fontSize: 36),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  )),
                  ],
                );
              },
            );
          },
        );
      };

      if (mapMarker.isCluster) {
        mapMarker.icon = await _getClusterMarker(
          mapMarker.pointsSize,
          clusterColor,
          clusterTextColor,
          clusterWidth,
        );
      }
      return mapMarker.toMarker();
    }).toList());
  }
}
