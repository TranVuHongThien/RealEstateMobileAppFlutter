import 'package:flutter/material.dart';
import 'package:house_input/data/price_consult.dart';
import 'package:house_input/data/property.dart';
import 'package:house_input/data/website.dart';
import 'package:house_input/providers/location.dart';
import 'package:house_input/providers/ulti.dart';
import 'package:house_input/screens/detail.dart';
import 'package:house_input/screens/test.dart';
import 'package:house_input/services/price_query.dart';
import 'package:house_input/services/similar_query.dart';
import 'package:house_input/widgets/filter.dart';
import 'package:dvhcvn/dvhcvn.dart' as dvhcvn;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class Price extends StatefulWidget {
  // final data;
  const Price({Key key}) : super(key: key);

  @override
  _PriceState createState() => _PriceState();
}

class _PriceState extends State<Price> with SingleTickerProviderStateMixin {
  TooltipBehavior _tooltipBehavior;
  SimilarQuery similarQuery;
  bool _isSimilarLoading = false;
  TabController _tabController;
  bool _isListLoading = false;
  PriceQuery bestPrice = PriceQuery();
  List<List<Property>> bestPricelst = [[], [], []];
  List<PriceQuery> pricelst = [];
  List<SalesData> chotot = [];
  List<SalesData> nhadat = [];
  List<SalesData> batdongsan = [];
  final allWebsite = WebsiteSetting(title: 'All');
  List<String> websitelst = [
    "chotot.com",
    "nhadat247.com.vn",
    "batdongsan.com.vn"
  ];
  // final websites = [
  //   WebsiteSetting(title: 'Chotot.com', id: 'chotot.com'),
  //   WebsiteSetting(title: 'Nhadat247.com.vn', id: 'nhadat247.com.vn'),
  //   WebsiteSetting(title: 'Batdongsan.com.vn', id: 'batdongsan.com.vn'),
  // ];
  // Widget buildWebsiteToggleCheckbox(WebsiteSetting website) =>
  //     buildWebsiteCheckbox(
  //         website: website,
  //         onClicked: () {
  //           final newValue = !website.value;

  //           setState(() {
  //             allWebsite.value = newValue;
  //             websites.forEach((website) {
  //               website.value = newValue;
  //             });
  //             if (newValue == true) {
  //               websitelst = [
  //                 "chotot.com",
  //                 "nhadat247.com.vn",
  //                 "batdongsan.com.vn",
  //               ];
  //             } else {
  //               websitelst.clear();
  //             }
  //           });
  //         });

  // Widget buildWebsiteSingleCheckbox(WebsiteSetting website) =>
  //     buildWebsiteCheckbox(
  //       website: website,
  //       onClicked: () {
  //         setState(() {
  //           final newValue = !website.value;
  //           website.value = newValue;

  //           if (!newValue) {
  //             allWebsite.value = false;
  //           } else {
  //             final allow = websites.every((website) => website.value);
  //             allWebsite.value = allow;
  //           }
  //           if (newValue == true) {
  //             websitelst.add(website.id);
  //           } else {
  //             websitelst.remove(website.id);
  //           }
  //         });
  //       },
  //     );

  // Widget buildWebsiteCheckbox({
  //   @required WebsiteSetting website,
  //   @required VoidCallback onClicked,
  // }) =>
  //     Container(
  //       height: 45,
  //       child: ListTile(
  //         onTap: onClicked,
  //         leading: Checkbox(
  //           activeColor: Colors.black,
  //           value: website.value,
  //           onChanged: (value) => onClicked(),
  //         ),
  //         title: Text(
  //           website.title,
  //           style: TextStyle(fontSize: 20, fontWeight: FontWeight.normal),
  //         ),
  //       ),
  //     );
  List<Map> _categoryJson = [
    {"id": "House", "name": "nhà"},
    {"id": "Flat", "name": "chung cư"},
    // {"id": "Agricultural land", "name": "đất nông nghiệp"},
    // {"id": "Industrial land", "name": "đất công nghiệp"},
    // {"id": "Residential land", "name": "đất thổ cư"},
    // {"id": "Construction land", "name": "đất nền dự án"},
  ];
  void addressSplit(a, List c) {
    List x = a.split(" > ");
    // print(x);
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

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _tabController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    UltiProvider ulti = Provider.of<UltiProvider>(context);
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Price Consulting",
            style: TextStyle(fontSize: 25),
          ),
          backgroundColor: Colors.black.withOpacity(0.7),
          leading: BackButton(
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        endDrawer: Drawer(
            child: Container(
          child: SingleChildScrollView(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding:
                    EdgeInsets.only(top: 48, left: 0, right: 0, bottom: 16),
                child: Column(
                  children: [
                    Container(
                      padding: EdgeInsets.only(
                          top: 0, left: 24, right: 0, bottom: 10),
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
                    // Container(
                    //   padding: EdgeInsets.only(
                    //       top: 20, left: 24, right: 0, bottom: 10),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         "Website",
                    //         style: TextStyle(
                    //           fontSize: 24,
                    //           fontWeight: FontWeight.bold,
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ),
                    // Padding(
                    //   padding:
                    //       EdgeInsets.only(top: 0, left: 24, right: 0, bottom: 10),
                    //   child: Column(
                    //     children: [
                    //       buildWebsiteToggleCheckbox(allWebsite),
                    //       // Divider(),
                    //       ...websites.map(buildWebsiteSingleCheckbox).toList(),
                    //     ],
                    //   ),
                    // ),
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
                                  pricelst.clear();
                                  chotot.clear();
                                  batdongsan.clear();
                                  nhadat.clear();
                                  // print(count);
                                  List location = ['null', 'null', 'null'];
                                  final data = LocationProvider.of(context,
                                      listen: false);
                                  dvhcvn.Entity entity = data.level3;
                                  entity ??= data.level2;
                                  entity ??= data.level1;
                                  if (data.level1 == null ||
                                      data.level2 == null) {
                                    return showDialog(
                                        context: context,
                                        builder: (_) {
                                          return Dialog(
                                            child: Padding(
                                              child: Text('Missing location'),
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                            ),
                                          );
                                        });
                                  } else {
                                    addressSplit(entity.toString(), location);
                                    for (var i in websitelst) {
                                      pricelst.add(PriceQuery(
                                        homepage: i,
                                        category: ulti.category,
                                        region: location[0],
                                        district: location[1],
                                      ));
                                    }
                                    // print(pricelst.toString());
                                    // print(location[0] +
                                    //     " " +
                                    //     location[1] +
                                    //     " " +
                                    //     // location[2] +
                                    //     // " " +
                                    //     // priceRange[0].toString() +
                                    //     // " " +
                                    //     // priceRange[1].toString() +
                                    //     // " " +
                                    //     ulti.category.toString() +
                                    //     " " +
                                    //     websitelst.toString() +
                                    //     " ");
                                  }
                                  Navigator.pop(context);
                                  setState(() {
                                    _isListLoading = true;
                                  });

                                  var priceChotot = await pricelst[0].run();
                                  var priceNhadat = await pricelst[1].run();
                                  var priceBatdongsan = await pricelst[2].run();
                                  bestPricelst = await bestPrice.getBestHouse(
                                      priceChotot.price,
                                      [ulti.category],
                                      location[0],
                                      location[1]);
                                  for (var x = 0;
                                      x < priceChotot.date.length;
                                      x++) {
                                    // print(x);
                                    setState(() {
                                      chotot.add(SalesData(
                                          DateFormat('MM/yyyy')
                                              .parse(priceChotot.date[x]),
                                          priceChotot.price[x]));
                                      nhadat.add(SalesData(
                                          DateFormat('MM/yyyy')
                                              .parse(priceNhadat.date[x]),
                                          priceNhadat.price[x]));
                                      batdongsan.add(SalesData(
                                          DateFormat('MM/yyyy')
                                              .parse(priceBatdongsan.date[x]),
                                          priceBatdongsan.price[x]));
                                    });
                                  }

                                  setState(() {
                                    _isListLoading = false;
                                  });
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
        body: !_isListLoading
            ? SingleChildScrollView(
                physics: ScrollPhysics(),
                child: Column(
                  children: [
                    Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height * 0.8,
                        child: SfCartesianChart(
                            tooltipBehavior: _tooltipBehavior,
                            // Enables the legend
                            legend: Legend(isVisible: true),
                            enableAxisAnimation: true,
                            // Initialize category axis
                            primaryXAxis: DateTimeCategoryAxis(
                                // X axis labels will be rendered based on the below format
                                dateFormat: DateFormat.yM(),
                                labelIntersectAction:
                                    AxisLabelIntersectAction.multipleRows),
                            series: <ChartSeries>[
                              // Initialize line series
                              SplineSeries<SalesData, DateTime>(
                                name: 'chotot.com',
                                dataSource: chotot,
                                xValueMapper: (SalesData sales, _) =>
                                    sales.year,
                                yValueMapper: (SalesData sales, _) =>
                                    sales.sales,
                                width: 4,
                                // dataLabelSettings:
                                //     DataLabelSettings(isVisible: true),
                              ),
                              SplineSeries<SalesData, DateTime>(
                                name: 'nhadat247.com.vn',
                                color: Colors.green,
                                dataSource: nhadat,
                                xValueMapper: (SalesData sales, _) =>
                                    sales.year,
                                yValueMapper: (SalesData sales, _) =>
                                    sales.sales,
                                width: 4,
                                // dataLabelSettings:
                                //     DataLabelSettings(isVisible: true),
                              ),
                              SplineSeries<SalesData, DateTime>(
                                name: 'batdongsan.com.vn',
                                dataSource: batdongsan,
                                xValueMapper: (SalesData sales, _) =>
                                    sales.year,
                                yValueMapper: (SalesData sales, _) =>
                                    sales.sales,
                                width: 4,
                                // dataLabelSettings:
                                //     DataLabelSettings(isVisible: true),
                              ),
                            ])),
                    // Divider(
                    //   color: Colors.black,
                    //   thickness: 5.0,
                    // ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      color: Colors.black.withOpacity(0.8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                          child: Text(
                            "Top Best Price",
                            style: TextStyle(
                              fontSize: 30,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Material(
                      color: Colors.black.withOpacity(0.8),
                      child: TabBar(
                        controller: _tabController,
                        tabs: <Widget>[
                          Tab(text: 'chotot.com'),
                          Tab(text: 'nhadat247.com.vn'),
                          Tab(text: 'batdongsan.com.vn'),
                        ],
                        unselectedLabelColor: Colors.grey,
                        labelColor: Colors.white,
                        indicatorColor: Colors.white,
                        indicatorWeight: 5.0,
                      ),
                    ),
                    Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          Stack(children: [
                            _buildListView(bestPricelst[0]),
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
                          Stack(children: [
                            _buildListView(bestPricelst[1]),
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
                          Stack(children: [
                            _buildListView(bestPricelst[2]),
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
                        ],
                      ),
                    ),
                  ],
                ))
            : _buildLoadingScreen());
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

  Widget _buildListView(List<Property> properties) {
    return properties.length != 0
        ? ListView.builder(
            itemBuilder: (context, idx) {
              return buildProperty(properties[idx]);
            },
            itemCount: properties.length,
            // scrollDirection: Axis.vertical,
            shrinkWrap: true,
            // primary: false,
            // physics: NeverScrollableScrollPhysics(),
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
        child: SingleChildScrollView(
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

class SalesData {
  SalesData(this.year, this.sales);
  final DateTime year;
  final double sales;
}
