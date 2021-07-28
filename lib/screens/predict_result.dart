import 'package:flutter/material.dart';
import 'package:cosmosdb/cosmosdb.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:url_launcher/url_launcher.dart';

class PredictResult extends StatefulWidget {
  final String category;
  final String district;
  final String region;
  final double surface;
  final double width;
  final double length;
  final int bedroom;
  final int bathroom;
  const PredictResult(
      {@required this.category,
      @required this.district,
      @required this.region,
      @required this.surface,
      @required this.width,
      @required this.length,
      @required this.bedroom,
      @required this.bathroom});

  @override
  _PredictResultState createState() => _PredictResultState();
}

class _PredictResultState extends State<PredictResult> {
  TooltipBehavior _tooltipBehavior;
  final cosmosDB = CosmosDB(
    masterKey:
        '6XOmPMbWF4IWgJE9ZiEvlSoJGB1Lz3G6L1hVW8zQKn2qqczUe1lcOWmFAYlSufHrSh67QPuZH3mg9ZBnv6lklA==',
    baseUrl: 'https://synapselink1.documents.azure.com:443/',
  );

// get all documents from a collection
  Future<List> getConfig(String model) async {
    var collectionId = "config";
    var databaseId = "data";
    String count = "100";
    final results = await cosmosDB.documents.query(
      Query(
          query: 'SELECT * FROM $collectionId c where c.model=@model',
          parameters: {'model': model}),
      databaseId,
      collectionId,
      count,
    );
    Map indexDict = jsonDecode(results.toList().last['list']);
    int size = results.toList().last['size'];
    return [size, indexDict];
  }

  // final List<SalesData> chartData = [
  //   SalesData("Market price", 35),
  //   SalesData("Chotot", 38),
  //   SalesData("Nhadat", 34),
  //   SalesData("Batdongsan", 52),
  // ];
  Future predict(
      String type,
      Map index,
      int size,
      String category,
      String region,
      String district,
      double surface,
      double width,
      double length,
      int toilets,
      int bedrooms) async {
    List output = List.filled(size, 0);
    output[index['surface']] = surface;
    output[index['width']] = width;
    output[index['length']] = length;
    output[index['toilets']] = toilets;
    output[index['bedrooms']] = bedrooms;
    if (index.keys.contains(category)) {
      output[index[category]] = 1;
    }
    String resultDistrict = district;
    if (index.keys.contains(resultDistrict)) {
      output[index[district]] = 1;
    } else {
      output[index['other_district']] = 1;
    }
    String resultRegion = region;
    if (index.keys.contains(resultRegion)) {
      output[index[region]] = 1;
    } else {
      // print(2);
      output[index['other_region']] = 1;
    }
    var inputData = json.encode({
      'data': [output.toList()]
    });
    // Map headers = {'Content-Type': 'application/json'};
    String scoringUri = "";
    if (type == "chotot") {
      scoringUri =
          "http://d9335624-e7be-4992-b0be-8faa74f0c7a2.westus2.azurecontainer.io/score";
    } else if (type == "main") {
      scoringUri =
          "http://abf0cfc9-a656-42ad-9b5f-5675ff1e2302.westus2.azurecontainer.io/score";
    } else if (type == "nhadat247") {
      scoringUri =
          "http://ade89376-19f8-46b2-82df-4fd76c15a224.westus2.azurecontainer.io/score";
    } else if (type == "batdongsan") {
      scoringUri =
          "http://129b6b9e-eb15-498b-8128-a2ee3967fc8e.westus2.azurecontainer.io/score";
    }
    http.Response response = await http.post(
      Uri.parse(scoringUri),
      headers: {"Content-Type": "application/json"},
      body: inputData,
      // encoding: Encoding.getByName("utf-8")
    );
    // JSONObject myObject = new JSONObject(result);
    var data = json.decode(response.body);

    return data;
    // scoring_uri = "http://3b3ce046-1670-45e1-9300-172a430172a1.eastus2.azurecontainer.io/score"
    // resp = requests.post(scoring_uri, input_data, headers=headers)

    // return resp.text
  }

  Future getPredictResult() async {
    List a = await getConfig("main");
    int mainSize = a[0];
    Map mainDict = a[1];
    List b = await getConfig("chotot");
    int chototSize = b[0];
    Map chototDict = b[1];
    List c = await getConfig("nhadat247");
    int nhadatSize = c[0];
    Map nhadatDict = c[1];
    List d = await getConfig("batdongsan");
    int batdongsanSize = d[0];
    Map batsongsanDict = d[1];
    return [
      await predict(
          "main",
          mainDict,
          mainSize,
          widget.category,
          widget.region,
          widget.district,
          widget.surface,
          widget.width,
          widget.length,
          widget.bathroom,
          widget.bedroom),
      await predict(
          "chotot",
          chototDict,
          chototSize,
          widget.category,
          widget.region,
          widget.district,
          widget.surface,
          widget.width,
          widget.length,
          widget.bathroom,
          widget.bedroom),
      await predict(
          "nhadat247",
          nhadatDict,
          nhadatSize,
          widget.category,
          widget.region,
          widget.district,
          widget.surface,
          widget.width,
          widget.length,
          widget.bathroom,
          widget.bedroom),
      await predict(
          "batdongsan",
          batsongsanDict,
          batdongsanSize,
          widget.category,
          widget.region,
          widget.district,
          widget.surface,
          widget.width,
          widget.length,
          widget.bathroom,
          widget.bedroom),
    ];
    // print(a1.toString());
  }

  Future<List<ColumnSeries<ChartData, String>>>
      _getDefaultColumnSeries() async {
    var result = await getPredictResult();
    final List<ChartData> chartData = <ChartData>[
      ChartData('Market price',
          double.parse(result[0]["predict"][0].toStringAsFixed(3))),
      ChartData(
          'Chotot', double.parse(result[1]["predict"][0].toStringAsFixed(3))),
      ChartData('Nhadat247',
          double.parse(result[2]["predict"][0].toStringAsFixed(3))),
      ChartData('Batdongsan',
          double.parse(result[3]["predict"][0].toStringAsFixed(3))),
    ];
    return <ColumnSeries<ChartData, String>>[
      ColumnSeries<ChartData, String>(
        name: "Predicted Price",
        color: Colors.grey[600],
        dataSource: chartData,
        xValueMapper: (ChartData sales, _) => sales.x,
        yValueMapper: (ChartData sales, _) => sales.y,
        dataLabelSettings: DataLabelSettings(
            isVisible: true, textStyle: TextStyle(fontSize: 11)),
      )
    ];
  }

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(enable: true);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _getDefaultColumnSeries(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Scaffold(
                backgroundColor: Colors.white.withOpacity(1),
                appBar: AppBar(
                  centerTitle: true,
                  backgroundColor: Colors.black.withOpacity(0.7),
                  elevation: 0,
                  title: Text(
                    "Result",
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
                body: Container(
                    height: MediaQuery.of(context).size.height,
                    child: Stack(children: [
                      Container(
                        height: 30,
                        color: Colors.black.withOpacity(0.7),
                      ),
                      Container(
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(7)),
                              color: Colors.white),
                          // width: MediaQuery.of(context).size.width,
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: SfCartesianChart(
                            tooltipBehavior: _tooltipBehavior,
                            // legend: Legend(isVisible: true),
                            enableAxisAnimation: true,
                            primaryYAxis: NumericAxis(
                                axisLine: const AxisLine(width: 0),
                                labelFormat: '{value}B VNĐ',
                                majorTickLines: const MajorTickLines(size: 0)),
                            primaryXAxis: CategoryAxis(
                                labelAlignment: LabelAlignment.center,
                                labelIntersectAction:
                                    AxisLabelIntersectAction.multipleRows),
                            series: snapshot.data,
                          ))
                    ])));
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

  _launchURL(String homepage) async {
    // ignore: unnecessary_brace_in_string_interps
    String url = 'https://$homepage';
    print(url);
    try {
      await launch(url, forceWebView: true);
    } catch (e) {
      throw 'Could not launch $url';
    }
  }
}

class ChartData {
  ChartData(this.x, this.y);
  final String x;
  final double y;
}
