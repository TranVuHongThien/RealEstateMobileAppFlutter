import 'dart:math';

import 'package:flutter/material.dart';

// import 'package:grouped_buttons/grouped_buttons.dart';
import 'package:house_input/data/category.dart';
import 'package:house_input/data/website.dart';

import 'package:house_input/providers/location.dart';

import 'package:house_input/services/search_query.dart';
import 'package:house_input/services/similar_query.dart';
import 'package:house_input/widgets/filter.dart';

import '../data/property.dart';
import 'detail.dart';
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;

class Search extends StatefulWidget {
  @override
  _SearchState createState() => _SearchState();
}

class _SearchState extends State<Search> {
  List<Property> _properties;
  SearchQuery query;
  SimilarQuery similarQuery;
  bool _isListLoading = false;
  bool _isSimilarLoading = false;
  RangeValues selectedRange = RangeValues(0, 10);
  List priceRange = [0, 10];
  // String imgLink = "ih2";
  // String count = "100";
  // String _picked = "100";
  // var selectedRange = RangeValues(0, 10);

  // void addressSplit(a, List c) {
  //   List x = a.split(" > ");
  //   if (x[0].contains('Thành phố')) {
  //     c.add(x[0].split("Thành phố ")[1]);
  //   } else {
  //     c.add(x[0].split("Tỉnh ")[1]);
  //   }
  //   c.add(x[1]);
  // }
  void addressSplit(a, List c) {
    List x = a.split(" > ");
    print(x);
    //region
    if (x[0].contains('Thành phố')) {
      c[0] = x[0].split("Thành phố ")[1];
    } else if (x[0].contains('Tỉnh')) {
      c[0] = x[0].split("Tỉnh ")[1];
    } else {
      c[0] = x[0];
    }
    //district
    if (x.length == 2) {
      if (x[1].contains('Quận')) {
        c[1] = "d " + x[1].split("Quận ")[1];
      } else if (x[1].contains('Huyện')) {
        c[1] = "d " + x[1].split("Huyện ")[1];
      } else if (x[1].contains('Thành phố')) {
        c[1] = "d " + x[1].split("Thành phố ")[1];
      } else if (x[1].contains('Thị xã')) {
        c[1] = "d " + x[1].split("Thị xã ")[1];
      } else {
        c[1] = "d " + x[1];
      }
    }
    if (x.length == 3) {
      if (x[2].contains('Phường')) {
        c[2] = x[2].split("Phường ")[1];
      } else if (x[2].contains('Xã')) {
        c[2] = x[2].split("Xã ")[1];
      } else if (x[2].contains('Thị trấn')) {
        c[2] = x[2].split("Thị trấn ")[1];
      }
    }
    //ward
  }

  // String _category = "nhà";
  // List<Map> _categoryJson = [
  //   {"id": "House", "name": "nhà"},
  //   {"id": "Flat", "name": "chung cư"},
  //   {"id": "Agricultural land", "name": "đất nông nghiệp"},
  //   {"id": "Industrial land", "name": "đất công nghiệp"},
  //   {"id": "Residential land", "name": "đất thổ cư"},
  //   {"id": "Construction land", "name": "đất nền dự án"},
  // ];
  // String _homepage = "all";
  // List<Map> _homepageJson = [
  //   {"id": "All", "name": "all"},
  //   {"id": "Chotot.com", "name": "chotot.com"},
  //   {"id": "Nhadat247.com.vn", "name": "nhadat247.com.vn"},
  //   {"id": "Batdongsan.com.vn", "name": "batdongsan.com.vn"},
  // ];
  Future<void> getInitList() async {
    try {
      SearchQuery init = SearchQuery();
      List<Property> property = await init.initQuery();
      setState(() {
        _properties = property;
      });
    } catch (e) {
      print(e);
    }
    // print(_properties);
  }

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

  final allCategory = CategorySetting(title: 'All');
  List categorylst = [];
  final categories = [
    CategorySetting(title: 'House', id: 'nhà'),
    CategorySetting(title: 'Flat', id: 'chung cư'),
    CategorySetting(title: 'Agricultural land', id: 'đất nông nghiệp'),
    CategorySetting(title: 'Industrial land', id: 'đất công nghiệp'),
    CategorySetting(title: 'Residential land', id: 'đất thổ cư'),
    CategorySetting(title: 'Construction land', id: 'đất nền dự án'),
  ];
  Widget buildToggleCheckbox(CategorySetting category) => buildCheckbox(
      category: category,
      onClicked: () {
        final newValue = !category.value;

        setState(() {
          allCategory.value = newValue;
          categories.forEach((category) {
            category.value = newValue;
          });
          if (newValue == true) {
            categorylst = [
              "nhà",
              "chung cư",
              "đất nông nghiệp",
              "đất công nghiệp",
              "đất thổ cư",
              "đất nền dự án"
            ];
          } else {
            categorylst.clear();
          }
        });
      });

  Widget buildSingleCheckbox(CategorySetting category) => buildCheckbox(
        category: category,
        onClicked: () {
          setState(() {
            final newValue = !category.value;
            category.value = newValue;

            if (!newValue) {
              allCategory.value = false;
            } else {
              final allow = categories.every((category) => category.value);
              allCategory.value = allow;
            }
            if (newValue == true) {
              categorylst.add(category.id);
            } else {
              categorylst.remove(category.id);
            }
          });
        },
      );

  Widget buildCheckbox({
    @required CategorySetting category,
    @required VoidCallback onClicked,
  }) =>
      Container(
        height: 45,
        child: ListTile(
          onTap: onClicked,
          leading: Checkbox(
            activeColor: Colors.black,
            value: category.value,
            onChanged: (value) => onClicked(),
          ),
          title: Text(
            category.title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
          ),
        ),
      );
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    getInitList();
    // WidgetsBinding.instance.addPostFrameCallback((_) => imgLink = img());
  }

  @override
  Widget build(BuildContext context) {
    // UltiProvider ulti = Provider.of<UltiProvider>(context);
    // return FutureBuilder(
    //     future: getInitList(),
    //     builder: (context, snapshot) {
    //       if (snapshot.connectionState == ConnectionState.done) {
    return Scaffold(
      endDrawer: Drawer(
          child: Container(
        child: SingleChildScrollView(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Padding(
              padding: EdgeInsets.only(top: 48, left: 0, right: 0, bottom: 16),
              child: Column(
                children: [
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
                      Level3()
                    ],
                    // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  ),
                  Container(
                    padding: EdgeInsets.only(
                        top: 20, left: 24, right: 0, bottom: 10),
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
                  Padding(
                    padding:
                        EdgeInsets.only(top: 0, left: 24, right: 0, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        buildToggleCheckbox(allCategory),
                        // Divider(),
                        ...categories.map(buildSingleCheckbox).toList(),
                        // DropdownButton<String>(
                        //   isDense: true,
                        //   underline: Container(
                        //     height: 2,
                        //     color: Colors.black,
                        //   ),
                        //   dropdownColor: Colors.white,
                        //   icon: Icon(
                        //     Icons.arrow_drop_down,
                        //     color: Colors.black,
                        //   ),
                        //   iconSize: 30,
                        //   value: ulti.category,
                        //   onChanged: (String newValue) {
                        //     ulti.changeCategory(newValue);
                        //   },
                        //   items: _categoryJson.map((Map map) {
                        //     return DropdownMenuItem<String>(
                        //       value: map["name"].toString(),
                        //       child: Text(map["id"],
                        //           textAlign: TextAlign.center,
                        //           style: TextStyle(
                        //             fontSize: 18,
                        //             fontWeight: FontWeight.w600,
                        //             color: Colors.black,
                        //           )),
                        //     );
                        //   }).toList(),
                        // ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.only(top: 0, left: 24, right: 0, bottom: 10),
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
                  Container(
                    padding:
                        EdgeInsets.only(top: 0, left: 24, right: 0, bottom: 10),
                    child: Row(
                      children: [
                        Text(
                          "Price",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Text(
                          "range (Billion VNĐ)",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RangeSlider(
                    values: selectedRange,
                    onChanged: (RangeValues newRange) {
                      setState(() {
                        selectedRange = newRange;
                        if (selectedRange.start.roundToDouble() > 30.0)
                          priceRange[0] = "30.0+";
                        else
                          priceRange[0] = selectedRange.start.roundToDouble();
                        if (selectedRange.end.roundToDouble() > 30.0)
                          priceRange[1] = "30.0+";
                        else
                          priceRange[1] = selectedRange.end.roundToDouble();
                      });
                      // ulti.changeSelectedRange(newRange);
                    },
                    labels: RangeLabels(
                      priceRange[0].toString(),
                      priceRange[1].toString(),
                    ),
                    min: 0,
                    max: 35,
                    divisions: 7,
                    activeColor: Colors.black,
                    inactiveColor: Colors.grey[300],
                  ),
                  Container(
                      padding: EdgeInsets.only(
                          top: 0, left: 16, right: 4, bottom: 0),
                      child: RichText(
                        text: TextSpan(
                          text: 'From ',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            TextSpan(
                                text: priceRange[0].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            TextSpan(text: ' to '),
                            TextSpan(
                                text: priceRange[1].toString(),
                                style: TextStyle(fontWeight: FontWeight.bold)),
                          ],
                        ),
                      )
                      // Text(
                      //   "From " +
                      //       ulti.selectedRange.start
                      //           .roundToDouble()
                      //           .toString(),
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //   ),
                      // ),
                      // Text(
                      //   "to " +
                      //       ulti.selectedRange.end.roundToDouble().toString(),
                      //   style: TextStyle(
                      //     fontSize: 14,
                      //   ),
                      // ),

                      ),
                  // Container(
                  //   padding:
                  //       EdgeInsets.only(top: 10, left: 24, right: 0, bottom: 0),
                  //   child: Row(
                  //     children: [
                  //       Text(
                  //         "Maximum results",
                  //         style: TextStyle(
                  //           fontSize: 24,
                  //           fontWeight: FontWeight.bold,
                  //         ),
                  //       ),
                  //     ],
                  //   ),
                  // ),
                  // RadioButtonGroup(
                  //     padding: const EdgeInsets.symmetric(horizontal: 50),
                  //     orientation: GroupedButtonsOrientation.HORIZONTAL,
                  //     activeColor: Colors.black,
                  //     labels: ["100", "500", "1000", "All"],
                  //     picked: ulti.picked,
                  //     // disabled: ["Option 1"],
                  //     onChange: (String label, int index) {
                  //       if (index == 0) {
                  //         ulti.changeCount("100");
                  //       }
                  //       if (index == 1) {
                  //         ulti.changeCount("500");
                  //       }
                  //       if (index == 2) {
                  //         ulti.changeCount("1000");
                  //       }
                  //       if (index == 3) {
                  //         ulti.changeCount("-1");
                  //       }
                  //     },
                  //     onSelected: (String selected) =>
                  //         ulti.changePicked(selected)),
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
                                List location = ['null', 'null', 'null'];
                                final data =
                                    LocationProvider.of(context, listen: false);
                                dvhcvn.Entity entity = data.level3;
                                entity ??= data.level2;
                                entity ??= data.level1;
                                if (data.level1 == null|| categorylst.isEmpty|| websitelst.isEmpty) {
                                  return showDialog(
                                      context: context,
                                      builder: (_) {
                                        return Dialog(
                                          child: Padding(
                                            child: Text('Missing input information'),
                                            padding: const EdgeInsets.all(8.0),
                                          ),
                                        );
                                      });
                                }                  
                                else {
                                  addressSplit(entity.toString(), location);
                                  query = SearchQuery(
                                    region: location[0],
                                    district: location[1],
                                    ward: location[2],
                                    priceFrom: priceRange[0],
                                    priceTo: priceRange[1],
                                    category: categorylst,
                                    homepage: websitelst,
                                  );
                                  print(location[0] +
                                      " " +
                                      location[1] +
                                      " " +
                                      location[2] +
                                      " " +
                                      priceRange[0].toString() +
                                      " " +
                                      priceRange[1].toString() +
                                      " " +
                                      categorylst.toString() +
                                      " " +
                                      websitelst.toString() +
                                      " ");
                                }
                                Navigator.pop(context);
                                setState(() {
                                  _isListLoading = true;
                                });
                                try {
                                  var properties =
                                      await query.queryWithHomePage();

                                  setState(() {
                                    _properties = properties;
                                  });
                                } catch (e) {
                                  print("Error occured: $e");
                                } finally {
                                  setState(() {
                                    _isListLoading = false;
                                  });
                                }
                              }),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8.0),
                  ),
                ],
              ),
            ),
          ]),
        ),
      )),
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
          actions: [
            Builder(
                builder: (context) => IconButton(
                      iconSize: 28,
                      icon: Icon(
                        Icons.search_outlined,
                        color: Colors.white,
                      ),
                      onPressed: () => Scaffold.of(context).openEndDrawer(),
                    ))
          ]),
      body: (_isListLoading || _properties == null)
          ? _buildLoadingScreen()
          : Stack(children: [
              _buildListView(_properties),
              if (_isSimilarLoading)
                Container(
                  height: MediaQuery.of(context).size.height,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Card(
                        elevation: 10,
                        color: Colors.amberAccent,
                        child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Text(
                            'Loading...',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
            ]),
      // bottomNavigationBar: BottomNavigationBar(
      //   items: const <BottomNavigationBarItem>[
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.home),
      //       label: 'House',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.business),
      //       label: 'Flat',
      //     ),
      //     BottomNavigationBarItem(
      //       icon: Icon(Icons.landscape_rounded),
      //       label: 'Land',
      //     ),
      //   ],
      //   currentIndex: _selectedIndex,
      //   selectedItemColor:
      //       // Colors.amber[800],
      //       Colors.yellow[700],
      //   onTap: _onItemTapped,
      // ),
    );
  }
  //         return Scaffold(
  //           body: Center(
  //             child: Container(
  //               width: 80,
  //               height: 80,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 10,
  //                 valueColor: AlwaysStoppedAnimation<Color>(
  //                     Colors.black.withOpacity(0.7)),
  //               ),
  //             ),
  //           ),
  //         );
  //       });
  // }
  // Widget buildFilter() {
  //   return Container(
  //     padding: EdgeInsets.symmetric(horizontal: 12),
  //     margin: EdgeInsets.only(right: 12),
  //     decoration: BoxDecoration(
  //         borderRadius: BorderRadius.all(
  //           Radius.circular(5),
  //         ),
  //         border: Border.all(
  //           color: Colors.grey[300],
  //           width: 1,
  //         )),
  //     child: Center(
  //       child: Text(
  //         filterName,
  //         style: TextStyle(
  //           fontSize: 16,
  //           fontWeight: FontWeight.bold,
  //         ),
  //       ),
  //     ),
  //   );
  // }
  // Widget _buildDrawer(){

  // }
  Widget _buildListView(List<Property> properties) {
    return properties.length != 0
        ? ListView.builder(
            itemBuilder: (ctx, idx) {
              return buildProperty(properties[idx]);
            },
            itemCount: properties.length,
          )
        : _buildNoDataScreen();
    // : _buildLoadingScreen();
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

  Widget _buildLoadingScreen() {
    return Center(
      child: Container(
        width: 80,
        height: 80,
        child: CircularProgressIndicator(
          strokeWidth: 10,
          valueColor:
              AlwaysStoppedAnimation<Color>(Colors.black.withOpacity(0.7)),
        ),
      ),
    );
  }
  // // List<Widget> buildProperties() {
  // //   List<Widget> list = [];
  // //   for (var i = 0; i < properties.length; i++) {
  // //     list.add(Container(child: buildProperty(properties[i], i)));
  // //   }
  // //   return list;
  // // }

  Widget buildProperty(Property property) {
    return GestureDetector(
      onTap: () async {
        // print(property.address);
        // property.address != null
        //     ? await getCoordinates(property.address)
        //     : await getCoordinates(property.district + ' ' + property.region);
        // print(property.price.runtimeType);
        if (property.category == "nhà" || property.category == "chung cư") {
          similarQuery = SimilarQuery(
            region: property.region,
            district: property.district,
            ward: property.ward,
            street: property.street,
            category: property.category,
            homepage: [property.homepage],
            bedrooms: (property.beds != null) ? int.parse(property.beds) : 0,
            toilets:
                (property.toilets != null) ? int.parse(property.toilets) : 0,
            width: (property.width != null) ? double.parse(property.width) : 0,
            length:
                (property.length != null) ? double.parse(property.length) : 0,
            surface: double.parse(property.surface),
            price: property.price,
          );
        } else {
          similarQuery = SimilarQuery(
            region: property.region,
            district: property.district,
            ward: property.ward,
            street: property.street,
            category: property.category,
            homepage: [property.homepage],
            bedrooms: 0,
            toilets: 0,
            width: property.width,
            length: property.length,
            surface: property.surface,
            price: property.price,
          );
        }
        setState(() {
          _isSimilarLoading = true;
        });
        var similarProperty = await similarQuery.findComps();
        setState(() {
          _isSimilarLoading = false;
        });
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => property.address != null
                  ? Detail(
                      property: property,
                      address: property.address,
                      similarProperties: similarProperty,
                    )
                  : Detail(
                      property: property,
                      address: property.district +
                          ' ' +
                          property.region +
                          ' ' +
                          property.ward,
                      similarProperties: similarProperty,
                    )),
        );
      },
      child: Card(
        margin: EdgeInsets.only(top: 10, bottom: 14),
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15),
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        borderRadius: BorderRadius.all(
                          Radius.circular(5),
                        ),
                      ),
                      width: 90,
                      padding: EdgeInsets.all(
                        4,
                      ),
                      child: Center(
                        child: Text(
                          property.homepage,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
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
    );
  }
}
