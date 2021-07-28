// import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
// import 'package:flutter/material.dart';
// import 'package:house_input/data/property.dart';
// import 'package:house_input/screens/search_page.dart';
// import 'package:house_input/services/search_query.dart';
// import 'package:house_input/widgets/filter.dart';
// // import 'package:geocoder/geocoder.dart';
// // import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:grouped_buttons/grouped_buttons.dart';
// // import 'package:house_input/data/constants.dart';
// import 'package:house_input/providers/location.dart';

// class SearchDrawer extends StatefulWidget {
//   const SearchDrawer({Key key}) : super(key: key);

//   @override
//   _SearchDrawerState createState() => _SearchDrawerState();
// }

// class _SearchDrawerState extends State<SearchDrawer> {
//   List<Property> _properties = [];
//   bool _isListLoading = false;
//   String count = "100";
//   String _picked = "100";
//   var selectedRange = RangeValues(0, 10);
//   SearchQuery query;
//   void addressSplit(a, List c) {
//     List x = a.split(" > ");
//     //region
//     if (x[0].contains('Thành phố')) {
//       c.add(x[0].split("Thành phố ")[1]);
//     } else if (x[0].contains('Tỉnh')) {
//       c.add(x[0].split("Tỉnh ")[1]);
//     } else {
//       c.add(x[0]);
//     }
//     //district
//     if (x[1].contains('Quận')) {
//       c.add("d " + x[1].split("Quận ")[1]);
//     } else if (x[1].contains('Huyện')) {
//       c.add("d " + x[1].split("Huyện ")[1]);
//     } else if (x[1].contains('Thành phố')) {
//       c.add("d " + x[1].split("Thành phố ")[1]);
//     } else if (x[1].contains('Thị xã')) {
//       c.add("d " + x[1].split("Thị xã ")[1]);
//     } else {
//       c.add("d " + x[1]);
//     }
//   }

//   String _category = "nhà";
//   List<Map> _categoryJson = [
//     {"id": "House", "name": "nhà"},
//     {"id": "Flat", "name": "chung cư"},
//     {"id": "Agricultural land", "name": "đất nông nghiệp"},
//     {"id": "Industrial land", "name": "đất công nghiệp"},
//     {"id": "Residential land", "name": "đất thổ cư"},
//     {"id": "Construction land", "name": "đất nền dự án"},
//   ];
//   String _homepage = "all";
//   List<Map> _homepageJson = [
//     {"id": "All", "name": "all"},
//     {"id": "Chotot.com", "name": "chotot.com"},
//     {"id": "Nhadat247.com.vn", "name": "nhadat247.com.vn"},
//     {"id": "Batdongsan.com.vn", "name": "batdongsan.com.vn"},
//   ];
//   @override
//   Widget build(BuildContext context) {
//     return Drawer(
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Padding(
//         padding: EdgeInsets.only(top: 48, left: 0, right: 0, bottom: 16),
//         child: Column(
//           children: [
//             Container(
//               padding: EdgeInsets.only(top: 0, left: 24, right: 0, bottom: 10),
//               child: Row(
//                 children: [
//                   Text(
//                     "Location",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Level1(),
//                 SizedBox(
//                   height: 10,
//                 ),
//                 Level2(),
//               ],
//               // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             ),
//             Container(
//               padding: EdgeInsets.only(top: 20, left: 24, right: 0, bottom: 10),
//               child: Row(
//                 children: [
//                   Text(
//                     "Category",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 DropdownButton<String>(
//                   isDense: true,
//                   underline: Container(
//                     height: 2,
//                     color: Colors.black,
//                   ),
//                   dropdownColor: Colors.white,
//                   icon: Icon(
//                     Icons.arrow_drop_down,
//                     color: Colors.black,
//                   ),
//                   iconSize: 30,
//                   value: _category,
//                   onChanged: (String newValue) {
//                     setState(() {
//                       _category = newValue;
//                     });

//                     // print(_category);
//                   },
//                   items: _categoryJson.map((Map map) {
//                     return DropdownMenuItem<String>(
//                       value: map["name"].toString(),
//                       child: Text(map["id"],
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                           )),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//             Container(
//               padding: EdgeInsets.only(top: 20, left: 24, right: 0, bottom: 10),
//               child: Row(
//                 children: [
//                   Text(
//                     "Website",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Column(
//               children: [
//                 DropdownButton<String>(
//                   isDense: true,
//                   underline: Container(
//                     height: 2,
//                     color: Colors.black,
//                   ),
//                   dropdownColor: Colors.white,
//                   icon: Icon(
//                     Icons.arrow_drop_down,
//                     color: Colors.black,
//                   ),
//                   iconSize: 30,
//                   value: _homepage,
//                   onChanged: (String newValue) {
//                     WidgetsBinding.instance
//                         .addPostFrameCallback((_) => setState(() {
//                               _homepage = newValue;
//                             }));
//                   },
//                   items: _homepageJson.map((Map map) {
//                     return DropdownMenuItem<String>(
//                       value: map["name"].toString(),
//                       child: Text(map["id"],
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontSize: 18,
//                             fontWeight: FontWeight.w600,
//                             color: Colors.black,
//                           )),
//                     );
//                   }).toList(),
//                 ),
//               ],
//             ),
//             Container(
//               padding: EdgeInsets.only(top: 20, left: 24, right: 0, bottom: 10),
//               child: Row(
//                 children: [
//                   Text(
//                     "Price range (VNĐ)",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             RangeSlider(
//               values: selectedRange,
//               onChanged: (RangeValues newRange) {
//                 setState(() => selectedRange = newRange);
//               },
//               labels: RangeLabels(
//                   selectedRange.start.roundToDouble().toString(),
//                   selectedRange.end.roundToDouble().toString()),
//               min: 0,
//               max: 100,
//               divisions: 20,
//               activeColor: Colors.black,
//               inactiveColor: Colors.grey[300],
//             ),
//             Container(
//               padding: EdgeInsets.only(top: 0, left: 16, right: 4, bottom: 0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     "0B",
//                     style: TextStyle(
//                       fontSize: 14,
//                     ),
//                   ),
//                   Text(
//                     "50B",
//                     style: TextStyle(
//                       fontSize: 14,
//                     ),
//                   ),
//                   Text(
//                     "100B",
//                     style: TextStyle(
//                       fontSize: 14,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Container(
//               padding: EdgeInsets.only(top: 10, left: 24, right: 0, bottom: 0),
//               child: Row(
//                 children: [
//                   Text(
//                     "Maximum results",
//                     style: TextStyle(
//                       fontSize: 24,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             RadioButtonGroup(
//               padding: const EdgeInsets.symmetric(horizontal: 50),
//               orientation: GroupedButtonsOrientation.HORIZONTAL,
//               activeColor: Colors.black,
//               labels: ["100", "500", "1000", "All"],
//               picked: _picked,
//               // disabled: ["Option 1"],
//               onChange: (String label, int index) {
//                 if (index == 0) {
//                   count = "100";
//                 }
//                 if (index == 1) {
//                   count = "500";
//                 }
//                 if (index == 2) {
//                   count = "1000";
//                 }
//                 if (index == 3) {
//                   count = "-1";
//                 }
//               },
//               onSelected: (String selected) => setState(() {
//                 _picked = selected;
//               }),
//             ),
//             Padding(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   SizedBox(
//                       width: MediaQuery.of(context).size.width * 0.4,
//                       child: ButtonReset()),
//                   SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.4,
//                     child: ElevatedButton(
//                         style: ElevatedButton.styleFrom(
//                             primary: Colors.black.withOpacity(0.7)),
//                         child: Text('Done'),
//                         onPressed: () async {
//                           // print(count);
//                           List location = [];
//                           final data =
//                               LocationProvider.of(context, listen: false);
//                           dvhcvn.Entity entity = data.level3;
//                           entity ??= data.level2;
//                           entity ??= data.level1;
//                           if (data.level1 == null || data.level2 == null) {
//                             return showDialog(
//                                 context: context,
//                                 builder: (_) {
//                                   return Dialog(
//                                     child: Padding(
//                                       child: Text('Missing location'),
//                                       padding: const EdgeInsets.all(8.0),
//                                     ),
//                                   );
//                                 });
//                           } else {
//                             addressSplit(entity.toString(), location);
//                             query = SearchQuery(
//                                 region: location[0],
//                                 district: location[1],
//                                 priceFrom: selectedRange.start.round(),
//                                 priceTo: selectedRange.end.round(),
//                                 category: _category,
//                                 homepage: _homepage,
//                                 count: count);
//                           }

//                           if (_homepage == "all") {
//                             setState(() {
//                               _isListLoading = true;
//                             });
//                             try {
//                               var properties = await query.queryNoHomePage();
//                               // await query.initQuery();
//                               setState(() {
//                                 _properties = properties;
//                               });
//                             } catch (e) {
//                               print("Error occured: $e");
//                             } finally {
//                               setState(() {
//                                 _isListLoading = false;
//                               });
//                             }
//                           } else {
//                             setState(() {
//                               _isListLoading = true;
//                             });
//                             try {
//                               var properties = await query.queryWithHomePage();

//                               setState(() {
//                                 _properties = properties;
//                               });
//                             } catch (e) {
//                               print("Error occured: $e");
//                             } finally {
//                               setState(() {
//                                 _isListLoading = false;
//                               });
//                             }
//                           }
//                           await Navigator.push(
//                               context,
//                               MaterialPageRoute(
//                                   builder: (context) => Search(
//                                         properties: _properties,
//                                         isListLoading: _isListLoading,
//                                       )));
//                           Navigator.pop(context);
//                         }),
//                   ),
//                 ],
//               ),
//               padding: const EdgeInsets.all(8.0),
//             ),
//           ],
//         ),
//       ),
//     ]));
//   }
// }
