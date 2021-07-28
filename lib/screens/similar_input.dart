import 'package:flutter/material.dart';
import 'package:house_input/data/property.dart';
import 'package:house_input/data/website.dart';
import 'package:house_input/providers/bathrooms.dart';
import 'package:house_input/providers/location.dart';
import 'package:house_input/providers/rooms.dart';
import 'package:house_input/providers/ulti.dart';
import 'package:house_input/screens/silimar.dart';
import 'package:house_input/screens/test.dart';
import 'package:house_input/services/similar_query.dart';
import 'package:house_input/services/style.dart';
import 'package:house_input/widgets/bathrooms.dart';
import 'package:house_input/widgets/custom_text.dart';
import 'package:house_input/widgets/filter.dart';
import 'package:house_input/widgets/rooms.dart';
import 'package:provider/provider.dart';
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;

class SimilarInput extends StatefulWidget {
  const SimilarInput({Key key}) : super(key: key);

  @override
  _SimilarInputState createState() => _SimilarInputState();
}

class _SimilarInputState extends State<SimilarInput> {
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
    //ward
    if (x[2].contains('Phường')) {
      c.add(x[2].split("Phường ")[1]);
    } else if (x[2].contains('Xã')) {
      c.add(x[2].split("Xã ")[1]);
    } else if (x[2].contains('Thị trấn')) {
      c.add(x[2].split("Thị trấn ")[1]);
    }
  }

  List<Map> _categoryJson = [
    {"id": "House", "name": "nhà"},
    {"id": "Flat", "name": "chung cư"},
    {"id": "Agricultural land", "name": "đất nông nghiệp"},
    {"id": "Industrial land", "name": "đất công nghiệp"},
    {"id": "Residential land", "name": "đất thổ cư"},
    {"id": "Construction land", "name": "đất nền dự án"},
  ];
  // String _homepage = "all";
  List<Map> _homepageJson = [
    {"id": "Chotot.com", "name": "chotot.com"},
    {"id": "Nhadat247.com.vn", "name": "nhadat247.com.vn"},
    {"id": "Batdongsan.com.vn", "name": "batdongsan.com.vn"},
  ];
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

  // List<Property> properties;
  SimilarQuery query;
  bool _isListLoading = false;
  int bedDialog;
  int bedText;
  int bathDialog;
  int bathText;
  TextEditingController _textFieldController = TextEditingController();
  TextEditingController _bathFieldController = TextEditingController();
  TextEditingController _widthController = TextEditingController();
  TextEditingController _lengthController = TextEditingController();
  TextEditingController _areaController = TextEditingController();
  TextEditingController _streetController = TextEditingController();
  double widthText;
  double lengthText;
  double surfaceText;
  String streetText;

  final allWebsite = WebsiteSetting(title: 'All');
  List websitelst = [];
  final websites = [
    WebsiteSetting(title: 'Chotot.com', id: 'chotot.com'),
    WebsiteSetting(title: 'Nhadat247.com.vn', id: 'nhadat247.com.vn'),
    WebsiteSetting(title: 'Batdongsan.com.vn', id: 'batdongsan.com.vn'),
  ];
  Widget buildWebsiteToggleCheckbox(WebsiteSetting website) =>
      buildWebsiteCheckbox(
          website: website,
          onClicked: () {
            final newValue = !website.value;

            setState(() {
              allWebsite.value = newValue;
              websites.forEach((website) {
                website.value = newValue;
              });
              if (newValue == true) {
                websitelst = [
                  "chotot.com",
                  "nhadat247.com.vn",
                  "batdongsan.com.vn",
                ];
              } else {
                websitelst.clear();
              }
            });
          });

  Widget buildWebsiteSingleCheckbox(WebsiteSetting website) =>
      buildWebsiteCheckbox(
        website: website,
        onClicked: () {
          setState(() {
            final newValue = !website.value;
            website.value = newValue;

            if (!newValue) {
              allWebsite.value = false;
            } else {
              final allow = websites.every((website) => website.value);
              allWebsite.value = allow;
            }
            if (newValue == true) {
              websitelst.add(website.id);
            } else {
              websitelst.remove(website.id);
            }
          });
        },
      );

  Widget buildWebsiteCheckbox({
    @required WebsiteSetting website,
    @required VoidCallback onClicked,
  }) =>
      Container(
        height: 45,
        child: ListTile(
          onTap: onClicked,
          leading: Checkbox(
            activeColor: Colors.black,
            value: website.value,
            onChanged: (value) => onClicked(),
          ),
          title: Text(
            website.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ),
        ),
      );
  @override
  Widget build(BuildContext context) {
    UltiProvider ulti = Provider.of<UltiProvider>(context);
    RoomsProvider rooms = Provider.of<RoomsProvider>(context);
    BathRoomsProvider bathrooms = Provider.of<BathRoomsProvider>(context);
    if (!_isListLoading) {
      return Scaffold(
        body: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: 16, left: 0, right: 0, bottom: 16),
            child: Column(children: [
              Container(
                padding:
                    EdgeInsets.only(top: 0, left: 24, right: 0, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Level1(),
                  SizedBox(
                    height: 10,
                  ),
                  Level2(),
                  SizedBox(
                    height: 10,
                  ),
                  Level3(),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 100, right: 100),
                    child: TextFormField(
                      onChanged: (value) {
                        try {
                          setState(() {
                            streetText = value;
                          });
                        } catch (e) {}
                      },
                      controller: _streetController,
                      decoration: InputDecoration(hintText: "Input street"),
                    ),
                  ),
                ],
                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 20, left: 24, right: 0, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      "Category",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  DropdownButton<String>(
                    isDense: true,
                    underline: Container(
                      height: 2,
                      color: Colors.black,
                    ),
                    dropdownColor: Colors.white,
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.black,
                    ),
                    iconSize: 30,
                    value: ulti.category,
                    onChanged: (String newValue) {
                      ulti.changeCategory(newValue);
                    },
                    items: _categoryJson.map((Map map) {
                      return DropdownMenuItem<String>(
                        value: map["name"].toString(),
                        child: Text(map["id"],
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            )),
                      );
                    }).toList(),
                  ),
                ],
              ),
              Container(
                padding:
                    EdgeInsets.only(top: 20, left: 24, right: 0, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      "Website",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Column(
              //   children: [
              //     DropdownButton<String>(
              //       isDense: true,
              //       underline: Container(
              //         height: 2,
              //         color: Colors.black,
              //       ),
              //       dropdownColor: Colors.white,
              //       icon: Icon(
              //         Icons.arrow_drop_down,
              //         color: Colors.black,
              //       ),
              //       iconSize: 30,
              //       value: ulti.similarHomepage,
              //       onChanged: (String newValue) async {
              //         await ulti.changeSimilarHomepage(newValue);
              //       },
              //       items: _homepageJson.map((Map map) {
              //         return DropdownMenuItem<String>(
              //           value: map["name"].toString(),
              //           child: Text(map["id"],
              //               textAlign: TextAlign.center,
              //               style: TextStyle(
              //                 fontSize: 18,
              //                 fontWeight: FontWeight.w600,
              //                 color: Colors.black,
              //               )),
              //         );
              //       }).toList(),
              //     ),
              //   ],
              // ),
              Padding(
                padding:
                    EdgeInsets.only(top: 0, left: 24, right: 0, bottom: 10),
                child: Column(
                  children: [
                    buildWebsiteToggleCheckbox(allWebsite),
                    // Divider(),
                    ...websites.map(buildWebsiteSingleCheckbox).toList(),
                  ],
                ),
              ),
              if (ulti.category == "nhà" || ulti.category == "chung cư")
                Padding(
                  padding:
                      EdgeInsets.only(top: 20, left: 24, right: 0, bottom: 10),
                  child: Column(children: [
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
                                    rooms.changeNumberOfRooms(
                                        NumberOfRooms.ONE, 1);
                                  },
                                  child: Rooms(1, 1)),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(4.0),
                              child: GestureDetector(
                                  onTap: () {
                                    rooms.changeNumberOfRooms(
                                        NumberOfRooms.TWO, 2);
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
                            msg: "Select the number of bath rooms",
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
                  ]),
                ),
              SizedBox(
                height: 15,
              ),
              Padding(
                padding:
                    EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 10),
                child: Column(
                  children: [
                    Row(
                      children: <Widget>[
                        Text(
                          "Width",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        CustomText(
                          msg: "Input the width (in meter)",
                          size: 18,
                          color: Colors.black.withOpacity(0.5),
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    TextFormField(
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
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "Length",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        CustomText(
                          msg: "Input the length (in meter)",
                          size: 18,
                          color: Colors.black.withOpacity(0.5),
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    TextField(
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
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      children: <Widget>[
                        Text(
                          "Area",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: <Widget>[
                        CustomText(
                          msg: "Input the area (in square meter)",
                          size: 18,
                          color: Colors.black.withOpacity(0.5),
                          weight: FontWeight.w500,
                        ),
                      ],
                    ),
                    TextField(
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
                  ],
                ),
              ),
              Padding(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    SizedBox(
                        width: MediaQuery.of(context).size.width * 0.4,
                        child: ButtonReset()),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.4,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              primary: Colors.black.withOpacity(0.7)),
                          child: Text('Done'),
                          onPressed: () async {
                            // print(count);
                            List location = [];
                            final data =
                                LocationProvider.of(context, listen: false);
                            dvhcvn.Entity entity = data.level3;
                            entity ??= data.level2;
                            entity ??= data.level1;
                            if (data.level1 == null ||
                                data.level2 == null ||
                                data.level3 == null) {
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
                              if ((widthText != null && (widthText > 0)) &&
                                  (lengthText != null && (lengthText > 0)) &&
                                  (surfaceText != null && (surfaceText > 0)) &&
                                  (bathrooms.bathNumber != null &&
                                      (bathrooms.bathNumber > 0)) &&
                                  (rooms.roomNumber != null &&
                                      (rooms.roomNumber > 0)) && websitelst.isNotEmpty && streetText != null) {
                                addressSplit(entity.toString(), location);
                                // print(location[0] +
                                //     " " +
                                //     location[1] +
                                //     " " +
                                //     location[2] +
                                //     " " +
                                //     streetText +
                                //     " " +
                                //     ulti.category +
                                //     " " +
                                //     websitelst.toString() +
                                //     " " +
                                //     rooms.roomNumber.toString() +
                                //     " " +
                                //     bathrooms.bathNumber.toString() +
                                //     " " +
                                //     widthText.toString() +
                                //     " " +
                                //     lengthText.toString() +
                                //     " " +
                                //     surfaceText.toString());
                                if (ulti.category == "nhà" ||
                                    ulti.category == "chung cư") {
                                  query = SimilarQuery(
                                    region: location[0],
                                    district: location[1],
                                    ward: location[2],
                                    street: streetText,
                                    category: ulti.category,
                                    homepage: websitelst,
                                    bedrooms: rooms.roomNumber,
                                    toilets: bathrooms.bathNumber,
                                    width: widthText,
                                    length: lengthText,
                                    surface: surfaceText,
                                    price: -1,
                                  );
                                } else {
                                  query = SimilarQuery(
                                    region: location[0],
                                    district: location[1],
                                    ward: location[2],
                                    street: streetText,
                                    category: ulti.category,
                                    homepage: websitelst,
                                    bedrooms: 0,
                                    toilets: 0,
                                    width: widthText,
                                    length: lengthText,
                                    surface: surfaceText,
                                    price: -1,
                                  );
                                }
                                setState(() {
                                  _isListLoading = true;
                                });
                                var similarProperty = await query.findComps();
                                // print(property);
                                // setState(() {
                                //   properties = property;
                                // });
                                // print(properties[1][0]['address'] +
                                //     properties[1][1]['address']);
                                // properties = await property;
                                // await Future.delayed(Duration(seconds: 5));
                                // print(similarProperty);
                                // print(similarProperty[0]
                                //     .values
                                //     .toList()[0]
                                //     .length);
                                //cach lay list ra theo tung duong
                                // print(similarProperty[0].values.toList()[0]);
                                //cach lay tung record ra trong list ra theo tung duong
                                // print(similarProperty[0].values.toList()[0][0]);
                                if (similarProperty.length == 0) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              _buildNoDataScreen()));
                                }
                                if (similarProperty.isNotEmpty) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => Similar(
                                                properties: similarProperty,
                                              )));
                                }
                                // if (similarProperty.isNotEmpty) {
                                //   Navigator.push(
                                //       context,
                                //       MaterialPageRoute(
                                //           builder: (context) => Test(
                                //                 data: similarProperty,
                                //               )));
                                // }
                                setState(() {
                                  _isListLoading = false;
                                });
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (_) {
                                      return Dialog(
                                        child: Padding(
                                          child: Text(
                                              'Input information is not correct'),
                                          padding: const EdgeInsets.all(8.0),
                                        ),
                                      );
                                    });
                              }
                            }
                          }),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(8.0),
              ),
            ]),
          ),
        ])),
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Find Similar Property",
            style: TextStyle(fontSize: 25),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          // actions: [
          //   Builder(
          //       builder: (context) => IconButton(
          //             iconSize: 28,
          //             icon: Icon(
          //               Icons.search_outlined,
          //               color: Colors.white,
          //             ),
          //             onPressed: () => Scaffold.of(context).openEndDrawer(),
          //           ))
          // ]
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
            valueColor:
                AlwaysStoppedAnimation<Color>(Colors.black.withOpacity(0.7)),
          ),
        ),
      ),
    );
  }

  Widget _buildNoDataScreen() {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Search",
          style: TextStyle(fontSize: 25),
        ),
        backgroundColor: Colors.black.withOpacity(0.7),
        leading: BackButton(
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
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
      ),
    );
  }
}
