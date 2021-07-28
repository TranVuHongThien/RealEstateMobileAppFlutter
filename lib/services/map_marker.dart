import 'package:fluster/fluster.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// [Fluster] can only handle markers that conform to the [Clusterable] abstract class.
///
/// You can customize this class by adding more parameters that might be needed for
/// your use case. For instance, you can pass an onTap callback or add an
/// [InfoWindow] to your marker here, then you can use the [toMarker] method to convert
/// this to a proper [Marker] that the [GoogleMap] can read.
class MapMarker extends Clusterable {
  final String id;
  final LatLng position;
  BitmapDescriptor icon;
  Function onMarkerTap;

  // List url;
  final GlobalKey scaffoldKey = GlobalKey();
  MapMarker({
    this.id,
    this.position,
    this.icon,
    isCluster = false,
    clusterId,
    pointsSize,
    childMarkerId,
    this.onMarkerTap,
  }) : super(
          markerId: id,
          latitude: position.latitude,
          longitude: position.longitude,
          isCluster: isCluster,
          clusterId: clusterId,
          pointsSize: pointsSize,
          childMarkerId: childMarkerId,
        );

  Marker toMarker() => Marker(
        markerId: MarkerId(isCluster ? 'cl_$id' : id),
        position: LatLng(
          position.latitude,
          position.longitude,
        ),
        icon: icon,
        infoWindow: InfoWindow(
          title: "More Information",
          // snippet: url.toString(),
          onTap: () {
            onMarkerTap();
            //   var bottomSheetController = Scaffold.of(scaffoldKey.currentContext)
            //       .showBottomSheet((context) => Container(
            //             child: getBottomSheet("17.4435, 78.3772"),
            //             height: 250,
            //             color: Colors.transparent,
            //           ));
            // }));
          },
        ),
      );
}

//   void _showModal() {
//     Future<void> future = showModalBottomSheet<void>(
//       context: context,
//       builder: (BuildContext context) {
//         return Container(
//                 child: Wrap(
//                    children: <Widget>[
//                         ListTile(
//                            leading: Icon(Icons.star),
//                            title: Text("Favorite"),
//                         ),
//                         ListTile(
//                            leading: Icon(Icons.close),
//                            title: Text("Cancel"),
//                         ),
//                   ],
//             ),
//         );
//       },
//     );
//   future.then((void value) => _closeModal(value));
// }

// void _closeModal(void value) {

// }
// Widget _displayDialog() {
//   return AlertDialog(
//     title: Text(
//       'Seller\'s phone number',
//       style: TextStyle(fontSize: 22),
//     ),
//     content: Text("No data"),
//     actions: <Widget>[
//       TextButton(
//         child: Text(
//           'CANCEL',
//           style: TextStyle(color: Colors.black),
//         ),
//         onPressed: () {},
//       ),
//       TextButton(
//         child: Text(
//           'Copy',
//           style: TextStyle(color: Colors.white),
//         ),
//         style: ButtonStyle(
//           backgroundColor: MaterialStateProperty.all(Colors.black),
//         ),
//         onPressed: () {},
//       ),
//     ],
//   );
// }

Widget getBottomSheet(String s) {
  return Stack(
    children: [
      Container(
        margin: EdgeInsets.only(top: 32),
        color: Colors.white,
        child: Column(
          children: [
            Container(
              color: Colors.blueAccent,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hytech City Public School \n CBSC",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      children: [
                        Text("4.5",
                            style:
                                TextStyle(color: Colors.white, fontSize: 12)),
                        Icon(
                          Icons.star,
                          color: Colors.yellow,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("970 Folowers",
                            style: TextStyle(color: Colors.white, fontSize: 14))
                      ],
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text("Memorial Park",
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.map,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("$s")
              ],
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              children: [
                SizedBox(
                  width: 20,
                ),
                Icon(
                  Icons.call,
                  color: Colors.blue,
                ),
                SizedBox(
                  width: 20,
                ),
                Text("040-123456")
              ],
            )
          ],
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(8.0),
        child: Align(
          alignment: Alignment.topRight,
          child: FloatingActionButton(
              child: Icon(Icons.navigation), onPressed: () {}),
        ),
      )
    ],
  );
}
