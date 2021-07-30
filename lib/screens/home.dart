import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:house_input/data/constants.dart';
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
import 'package:house_input/providers/floor.dart';
import 'package:house_input/providers/location.dart';
import 'package:house_input/providers/rooms.dart';
import 'package:house_input/screens/predict_result.dart';
import 'package:house_input/widgets/filter.dart';
import 'package:house_input/widgets/floor.dart';
import 'package:house_input/widgets/rooms.dart';
import 'package:house_input/providers/bathrooms.dart';
import 'package:house_input/widgets/bathrooms.dart';
import 'package:provider/provider.dart';
import 'package:house_input/providers/property.dart';
import 'package:house_input/services/style.dart';
import 'package:house_input/widgets/custom_text.dart';
import 'package:house_input/widgets/property_type.dart';
import 'package:cosmosdb/cosmosdb.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int numOfBedRooms;
  int numOfBathRooms;
  int numOfFloor = 1;
  int bedDialog;
  int bedText;
  int bathDialog;
  int bathText;
  int floorDialog;
  int floorText;
  double widthText;
  double lengthText;
  double surfaceText;
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _bathFieldController = TextEditingController();
  // TextEditingController _floorFieldController = TextEditingController();
  TextEditingController _widthController = TextEditingController();
  TextEditingController _lengthController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  // bool isWidth = true;
  // bool isLength = true;
  // bool isArea = true;
  Future<void> _displayTextInputDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Input number of bed rooms',
              style: TextStyle(fontSize: 22),
            ),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                try {
                  setState(() {
                    bedText = int.parse(value);
                  });
                } catch (e) {
                  print(e);
                }
              },
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "E.g. 6"),
            ),
            actions: <Widget>[
              // TextButton(
              //   child: Text(
              //     'CANCEL',
              //     style: TextStyle(color: black),
              //   ),
              //   onPressed: () {
              //     setState(() {
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  if (bedText != null)
                    setState(() {
                      bedDialog = bedText;

                      Navigator.pop(context);
                    });
                },
              ),
            ],
          );
        });
  }

  Future<void> _displayBathInputDialog(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(
              'Input number of bath rooms',
              style: TextStyle(fontSize: 22),
            ),
            content: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                try {
                  setState(() {
                    bathText = int.parse(value);
                  });
                } catch (e) {
                  print(e);
                }
              },
              controller: _bathFieldController,
              decoration: InputDecoration(hintText: "E.g. 6"),
            ),
            actions: <Widget>[
              // TextButton(
              //   child: Text(
              //     'CANCEL',
              //     style: TextStyle(color: black),
              //   ),
              //   onPressed: () {
              //     setState(() {
              //       Navigator.pop(context);
              //     });
              //   },
              // ),
              TextButton(
                child: Text(
                  'OK',
                  style: TextStyle(color: white),
                ),
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.black),
                ),
                onPressed: () {
                  if (bathText != null)
                    setState(() {
                      bathDialog = bathText;

                      Navigator.pop(context);
                    });
                },
              ),
            ],
          );
        });
  }

  // Future<void> _displayFloorInputDialog(BuildContext context) async {
  //   return showDialog(
  //       context: context,
  //       builder: (context) {
  //         return AlertDialog(
  //           title: Text(
  //             'Input number of floor',
  //             style: TextStyle(fontSize: 22),
  //           ),
  //           content: TextField(
  //             keyboardType: TextInputType.number,
  //             onChanged: (value) {
  //               setState(() {
  //                 floorText = int.parse(value);
  //               });
  //             },
  //             controller: _floorFieldController,
  //             decoration: InputDecoration(hintText: "E.g. 6"),
  //           ),
  //           actions: <Widget>[
  //             TextButton(
  //               child: Text(
  //                 'CANCEL',
  //                 style: TextStyle(color: black),
  //               ),
  //               onPressed: () {
  //                 setState(() {
  //                   Navigator.pop(context);
  //                 });
  //               },
  //             ),
  //             TextButton(
  //               child: Text(
  //                 'OK',
  //                 style: TextStyle(color: white),
  //               ),
  //               style: ButtonStyle(
  //                 backgroundColor: MaterialStateProperty.all(Colors.black),
  //               ),
  //               onPressed: () {
  //                 if (floorText != null)
  //                   setState(() {
  //                     floorDialog = floorText;
  //                     numOfFloor = floorDialog;
  //                     Navigator.pop(context);
  //                   });
  //               },
  //             ),
  //           ],
  //         );
  //       });
  // }

  void addressSplit(a, List c) {
    List x = a.split(" > ");
    //region
    if (x[0].contains('Thành phố')) {
      c.add(x[0].split("Thành phố ")[1]);
    } else if (x[0].contains('Tỉnh')) {
      c.add(x[0].split("Tỉnh ")[1]);
    } else {
      c.add(x[0]);
    }
    //district
    if (x[1].contains('Quận')) {
      c.add("d " + x[1].split("Quận ")[1]);
    } else if (x[1].contains('Huyện')) {
      c.add("d " + x[1].split("Huyện ")[1]);
    } else if (x[1].contains('Thành phố')) {
      c.add("d " + x[1].split("Thành phố ")[1]);
    } else if (x[1].contains('Thị xã')) {
      c.add("d " + x[1].split("Thị xã ")[1]);
    } else {
      c.add("d " + x[1]);
    }
  }

  // @override
  // void initState() {
  //   super.initState();
  //   RoomsProvider bedroom = RoomsProvider();
  //   bedDialog = bedroom.roomNumber;
  // }

  @override
  Widget build(BuildContext context) {
    PropertyProvider property = Provider.of<PropertyProvider>(context);
    RoomsProvider rooms = Provider.of<RoomsProvider>(context);
    BathRoomsProvider bathrooms = Provider.of<BathRoomsProvider>(context);
    // bathrooms.changeNumberOfBathRooms(NumberOfBathRooms.ONE);
    // FloorProvider floor = Provider.of<FloorProvider>(context);
    // double _lowerValue;
    // double _upperValue;
    return
        // Container(
        //   decoration: BoxDecoration(
        //       gradient: LinearGradient(
        //           colors: [navigationColor, gradientColor, gradientEndColor],
        //           begin: Alignment.topCenter,
        //           end: Alignment.bottomCenter,
        //           stops: [0.3, 0.6, 1.0])),
        //   child:
        Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
        title: Text(
          "Price Prediction",
          style: TextStyle(fontSize: 25),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      // backgroundColor: Colors.transparent,
      body: SafeArea(
          child: ListView(
        children: <Widget>[
          SizedBox(
            height: 10,
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Property Type",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CustomText(
                  msg: "Select the type of property",
                  size: 18,
                  color: Colors.black.withOpacity(0.5),
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 15,
          ),
          Container(
              height: 260,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                        onTap: () {
                          property.changePropertyType(Property.HOUSE, "nhà");
                        },
                        child: PropertyType(
                          image: "tc3.jpg",
                          title: "House",
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                        onTap: () {
                          property.changePropertyType(
                              Property.FLAT, "chung cư");
                        },
                        child: PropertyType(
                          image: "flat.png",
                          title: "Flat",
                        )),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: GestureDetector(
                        onTap: () {
                          property.changePropertyType(Property.LAND, "đất");
                        },
                        child: PropertyType(
                          image: "land.png",
                          title: "Land",
                        )),
                  ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10),
                  //   child: GestureDetector(
                  //       onTap: () {
                  //         property.changePropertyType(Property.HOUSELAND);
                  //         propertyType = "đất thổ cư";
                  //       },
                  //       child: PropertyType(
                  //         image: "tc4.jpg",
                  //         title: "Residential land",
                  //       )),
                  // ),
                  // Padding(
                  //   padding: const EdgeInsets.all(10),
                  //   child: GestureDetector(
                  //       onTap: () {
                  //         property.changePropertyType(Property.CONSLAND);
                  //         propertyType = "đất nền dự án";
                  //       },
                  //       child: PropertyType(
                  //         image: "construction.jpg",
                  //         title: "Construction land",
                  //       )),
                  // ),
                ],
              )),
          SizedBox(
            height: 15,
          ),
          if (property.typeOfProperty == "nhà" ||
              property.typeOfProperty == "chung cư")
            Column(
              children: [
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Rooms",
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.w500)),
                    ),
                  ],
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CustomText(
                        msg: "Select the number of bed rooms",
                        size: 18,
                        color: Colors.black.withOpacity(0.5),
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                rooms.changeNumberOfRooms(NumberOfRooms.ONE, 1);
                              },
                              child: Rooms(1, 1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                rooms.changeNumberOfRooms(NumberOfRooms.TWO, 2);
                              },
                              child: Rooms(2, 2)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                rooms.changeNumberOfRooms(
                                    NumberOfRooms.THREE, 3);
                              },
                              child: Rooms(3, 3)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                rooms.changeNumberOfRooms(
                                    NumberOfRooms.FOUR, 4);
                              },
                              child: Rooms(4, 4)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                rooms.changeNumberOfRooms(
                                    NumberOfRooms.FIVE, 5);
                              },
                              child: Rooms(5, 5)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () async {
                                await _displayTextInputDialog(context);
                                rooms.changeNumberOfRooms(
                                    NumberOfRooms.MORE, bedDialog);
                              },
                              child: Rooms(bedDialog, 6)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0),
                      child: CustomText(
                        msg: "Select the number of bathrooms",
                        size: 18,
                        color: Colors.black.withOpacity(0.5),
                        weight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 60,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                bathrooms.changeNumberOfBathRooms(
                                    NumberOfBathRooms.ONE, 1);
                              },
                              child: BathRooms(1, 1)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                bathrooms.changeNumberOfBathRooms(
                                    NumberOfBathRooms.TWO, 2);
                              },
                              child: BathRooms(2, 2)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                bathrooms.changeNumberOfBathRooms(
                                    NumberOfBathRooms.THREE, 3);
                              },
                              child: BathRooms(3, 3)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                bathrooms.changeNumberOfBathRooms(
                                    NumberOfBathRooms.FOUR, 4);
                              },
                              child: BathRooms(4, 4)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () {
                                bathrooms.changeNumberOfBathRooms(
                                    NumberOfBathRooms.FIVE, 5);
                              },
                              child: BathRooms(5, 5)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                              onTap: () async {
                                await _displayBathInputDialog(context);
                                bathrooms.changeNumberOfBathRooms(
                                    NumberOfBathRooms.MORE, bathDialog);
                              },
                              child: BathRooms(bathDialog, 6)),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                // Column(
                //   children: [
                //     Row(
                //       children: <Widget>[
                //         Padding(
                //           padding: const EdgeInsets.all(8.0),
                //           child:
                //               Text("Floors", style: TextStyle(fontSize: 18)),
                //         ),
                //       ],
                //     ),
                //     Row(
                //       children: <Widget>[
                //         Padding(
                //           padding: const EdgeInsets.only(left: 8.0),
                //           child: (propertyType == "Nhà")
                //               ? Text(
                //                   "Select the number of floor (including ground floor)",
                //                   style: TextStyle(color: grey, fontSize: 16))
                //               : (propertyType == "Chung cư")
                //                   ? Text(
                //                       "Select the floor of your house ",
                //                       style: TextStyle(
                //                           color: grey, fontSize: 16),
                //                     )
                //                   : null,
                //         ),
                //       ],
                //     ),
                //     SizedBox(
                //       height: 10,
                //     ),
                //     Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Container(
                //         height: 60,
                //         child: ListView(
                //           scrollDirection: Axis.horizontal,
                //           children: <Widget>[
                //             Padding(
                //               padding: const EdgeInsets.all(4.0),
                //               child: GestureDetector(
                //                   onTap: () {
                //                     floor.changeNumberOfFloor(
                //                         NumberOfFloor.ONE);
                //                     setState(() {
                //                       numOfFloor = 1;
                //                     });
                //                   },
                //                   child: Floor(1, 1)),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.all(4.0),
                //               child: GestureDetector(
                //                   onTap: () {
                //                     floor.changeNumberOfFloor(
                //                         NumberOfFloor.TWO);
                //                     setState(() {
                //                       numOfFloor = 2;
                //                     });
                //                   },
                //                   child: Floor(2, 2)),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.all(4.0),
                //               child: GestureDetector(
                //                   onTap: () {
                //                     floor.changeNumberOfFloor(
                //                         NumberOfFloor.THREE);
                //                     setState(() {
                //                       numOfFloor = 3;
                //                     });
                //                   },
                //                   child: Floor(3, 3)),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.all(4.0),
                //               child: GestureDetector(
                //                   onTap: () {
                //                     floor.changeNumberOfFloor(
                //                         NumberOfFloor.FOUR);
                //                     setState(() {
                //                       numOfFloor = 4;
                //                     });
                //                   },
                //                   child: Floor(4, 4)),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.all(4.0),
                //               child: GestureDetector(
                //                   onTap: () {
                //                     floor.changeNumberOfFloor(
                //                         NumberOfFloor.FIVE);
                //                     setState(() {
                //                       numOfFloor = 5;
                //                     });
                //                   },
                //                   child: Floor(5, 5)),
                //             ),
                //             Padding(
                //               padding: const EdgeInsets.all(4.0),
                //               child: GestureDetector(
                //                   onTap: () {
                //                     floor.changeNumberOfFloor(
                //                         NumberOfFloor.MORE);
                //                     _displayFloorInputDialog(context);
                //                     setState(() {
                //                       numOfFloor = floorDialog;
                //                     });
                //                   },
                //                   child: Floor(floorDialog, 6)),
                //             ),
                //           ],
                //         ),
                //       ),
                //     ),
                //   ],
                // ),
              ],
            ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Width",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CustomText(
                  msg: "Input the width (in meter)",
                  size: 18,
                  color: Colors.black.withOpacity(0.5),
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextFormField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                try {
                  setState(() {
                    widthText = double.parse(value);
                    //isWidth = true;
                  });
                } catch (e) {
                  // setState(() {
                  //   isWidth = false;
                  // });
                }
              },
              controller: _widthController,
              decoration: InputDecoration(hintText: "E.g. 20"),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Length",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CustomText(
                  msg: "Input the length (in meter)",
                  size: 18,
                  color: Colors.black.withOpacity(0.5),
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                try {
                  setState(() {
                    lengthText = double.parse(value);
                  });
                } catch (e) {
                  //isLength = false;
                }
              },
              controller: _lengthController,
              decoration: InputDecoration(hintText: "E.g. 20"),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Area",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: CustomText(
                  msg: "Input the area (in square meter)",
                  size: 18,
                  color: Colors.black.withOpacity(0.5),
                  weight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            child: TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                try {
                  setState(() {
                    surfaceText = double.parse(value);
                  });
                } catch (e) {
                  //isArea = false;
                }
              },
              controller: _areaController,
              decoration: InputDecoration(hintText: "E.g. 20"),
            ),
          ),
          SizedBox(
            height: 15,
          ),
          Row(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("Location",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          SizedBox(
            height: 10,
          ),
          Column(
            children: [
              Level1(),
              SizedBox(
                height: 10,
              ),
              Level2(),
            ],
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          ),
          SizedBox(
            height: 15,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(50, 15, 50, 15),
            child: SizedBox(
                height: 50.0,
                child: OutlinedButton(
                    child: Text(
                      'Predict',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: white,
                      ),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0))),
                      backgroundColor: MaterialStateProperty.all(Colors.black),
                    ),
                    onPressed: () {
                      List location = [];
                      final data = LocationProvider.of(context, listen: false);
                      dvhcvn.Entity entity = data.level3;
                      entity ??= data.level2;
                      entity ??= data.level1;

                      if (data.level1 == null || data.level2 == null) {
                        return showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                child: Padding(
                                  child: Text('Missing location'),
                                  padding: const EdgeInsets.all(8.0),
                                ),
                              );
                            });
                      } else {
                        addressSplit(entity.toString(), location);
                      }
                      if ((widthText != null && (widthText > 0)) &&
                          (lengthText != null && (lengthText > 0)) &&
                          (surfaceText != null && (surfaceText > 0)) &&
                          (bathrooms.bathNumber != null &&
                              (bathrooms.bathNumber > 0)) &&
                          (rooms.roomNumber != null &&
                              (rooms.roomNumber > 0))) {
                        //    print(
                        //     property.typeOfProperty +
                        //     " " +
                        //     rooms.roomNumber.toString() +
                        //     " " +
                        //     bathrooms.bathNumber.toString() +
                        //     " " +
                        //     widthText.toString() +
                        //     " " +
                        //     lengthText.toString() +
                        //     " " +
                        //     surfaceText.toString() +
                        //     " " +
                        //     location[0] +
                        //     " " +
                        //     location[1])
                        if (property.typeOfProperty == "nhà" ||
                            property.typeOfProperty == "chung cư")
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PredictResult(
                                        category: property.typeOfProperty,
                                        bedroom: rooms.roomNumber,
                                        bathroom: bathrooms.bathNumber,
                                        width: widthText,
                                        length: lengthText,
                                        surface: surfaceText,
                                        district: location[0],
                                        region: location[1],
                                      )));
                        else {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => PredictResult(
                                        category: property.typeOfProperty,
                                        bedroom: 0,
                                        bathroom: 0,
                                        width: widthText,
                                        length: lengthText,
                                        surface: surfaceText,
                                        district: location[0],
                                        region: location[1],
                                      )));
                        }
                      } else {
                        showDialog(
                            context: context,
                            builder: (_) {
                              return Dialog(
                                child: Padding(
                                  child:
                                      Text('Input information is not correct'),
                                  padding: const EdgeInsets.all(8.0),
                                ),
                              );
                            });
                      }
                    })),
          ),
        ],
      )),
      // ),
    );
  }
}
