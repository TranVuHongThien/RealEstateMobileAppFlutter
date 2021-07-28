import 'package:google_maps_flutter/google_maps_flutter.dart';

class Property {
  String category;
  String region;
  var price;
  String district;
  var surface;
  var beds;
  var toilets;
  String user;
  String homepage;
  String description;
  String address;
  String date;
  String phoneNumber;
  String imgLink;
  String url;
  String ward;
  var width;
  var length;
  String street;
  LatLng coordinate;
  Property(
      {this.category,
      this.region,
      this.price,
      this.district,
      this.surface,
      this.beds,
      this.toilets,
      this.user,
      this.homepage,
      this.description,
      this.address,
      this.date,
      this.phoneNumber,
      this.imgLink,
      this.url,
      this.ward,
      this.width,
      this.length,
      this.street,
      this.coordinate});
  // Map<String, dynamic> toMap() {
  //   return {
  //     'id': category,
  //     'title': region,
  //     'description': price,
  //     'dateTime': district,
  //   };
  // }
}
// List<Property> getPropertyList() {
//   return <Property>[
//     Property(
//       "HOUSE",
//       "Hồ Chí Minh",
//       "3,500.00",
//       "Quận Gò Vấp",
//       "2,456",
//       "4",
//     ),
//   ];
