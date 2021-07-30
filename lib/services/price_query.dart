import 'dart:math';

import 'package:cosmosdb/cosmosdb.dart';
import 'package:house_input/data/price_consult.dart';
import 'package:house_input/data/property.dart';
// import 'package:stats/stats.dart';
import 'package:intl/intl.dart';

class PriceQuery {
  String homepage;
  String category;
  String region;
  String district;
  PriceQuery({
    this.homepage,
    this.region,
    this.district,
    this.category,
  });
  final cosmosDB = CosmosDB(
    masterKey:
        '6XOmPMbWF4IWgJE9ZiEvlSoJGB1Lz3G6L1hVW8zQKn2qqczUe1lcOWmFAYlSufHrSh67QPuZH3mg9ZBnv6lklA==',
    baseUrl: 'https://synapselink1.documents.azure.com:443/',
  );
  Future<PriceConsult> run() async {
    // final documents = await cosmosDB.documents.list('data', 'detail_data');
    // print(documents);
    String collectionId = "final_data";
    String databaseId = "data";
    String count = "-1";
    List condtion = [];

    // if (homepage.length == 1) {
    //   if (homepage[0] != "all") {
    //     String b = '(' + 'c.homepage=' + "'" + homepage[0] + "'" + ')';
    //     condtion.add(b);
    //   }
    // } else if (homepage.length == 2) {
    //   String b = '(' +
    //       'c.homepage=' +
    //       "'" +
    //       homepage[0] +
    //       "'" +
    //       'or c.homepage=' +
    //       "'" +
    //       homepage[1] +
    //       "'" ')';
    //   condtion.add(b);
    // } else if (homepage.length == 3) {
    //   String b = '(' +
    //       'c.homepage=' +
    //       "'" +
    //       homepage[0] +
    //       "'" +
    //       'or c.homepage=' +
    //       "'" +
    //       homepage[1] +
    //       "'" 'or c.homepage=' +
    //       "'" +
    //       homepage[2] +
    //       "'" ')';
    //   condtion.add(b);
    // }

    // if (category.length == 1) {
    //   if (category[0] != "all") {
    //     String b = '(' + 'c.category=' + "'" + category[0] + "'" + ')';
    //     condtion.add(b);
    //   }
    // } else {
    //   String b = "(";
    //   for (int i = 0; i < category.length; i++) {
    //     b = b + "c.category = " + "'" + category[i] + "'";
    //     if (i + 1 < category.length) {
    //       b = b + " or ";
    //     } else {
    //       b = b + ")";
    //     }
    //   }
    //   condtion.add(b);
    // }

    if (region != 'null') {
      String b = '(' + 'c.region=' + "'" + region + "'" + ')';
      condtion.add(b);
    }

    if (district != 'null') {
      String b = '(' + 'c.district=' + "'" + district + "'" + ')';
      condtion.add(b);
    }
    String query =
        'SELECT c.surface, c.date, c.price FROM $collectionId c where c.category=@category and c.homepage=@homepage and ';
    for (int i = 0; i < condtion.length; i++) {
      query = query + condtion[i];
      if (i + 1 < condtion.length) {
        query = query + " and ";
      }
    }
    // print(query);

    final results = await cosmosDB.documents.query(
        Query(query: query, parameters: {
          'region': DateTime.now().millisecondsSinceEpoch,
          'district': district,
          'category': category,
          'homepage': homepage,
        }),
        databaseId,
        collectionId,
        count);

    Map<List<String>, List<double>> resultlst = getInput(results.toList());
    PriceConsult finalResult = PriceConsult(price: [], date: []);
    // print(resultlst.length);
    finalResult.date = resultlst.keys.first;
    finalResult.price = resultlst.values.first;

    return finalResult;
  }

  Map<List<String>, List<double>> getInput(List c) {
    // DateFormat format = DateFormat.yM();

    List keys = [];
    List values = [];
    for (int i = 0; i < c.length; i++) {
      if (c[i]['date'] != null) {
        List b = c[i]['date'].split("/");
        c[i]['date'] = b[1] + "/" + b[2];
      }
    }
    for (int i = 0; i < c.length; i++) {
      if (c[i]['date'] != null) {
        double cSurface = double.parse(c[i]['surface']);
        var cPrice = c[i]['price'];
        if (cSurface != 0 && cPrice < 200) {
          {
            if (keys.contains(c[i]['date'])) {
              values[keys.indexOf(c[i]['date'])][0] =
                  values[keys.indexOf(c[i]['date'])][0] + cPrice / cSurface;
              values[keys.indexOf(c[i]['date'])][1] =
                  values[keys.indexOf(c[i]['date'])][1] + 1;
            } else {
              keys.add(c[i]['date']);
              List a = [cPrice / cSurface, 1];
              values.add(a);
            }
          }
        }
      }
    }
    double total = 0;
    for (int i = 0; i < values.length; i++) {
      values[i] = values[i][0] / values[i][1] * 1000;
      values[i] = double.parse((values[i]).toStringAsFixed(2));
      total = total + values[i];
    }
    double medium = double.parse((total / values.length).toStringAsFixed(2));

    // for (int i = 0; i < values.length; i++) {
    //   values[i] = values[i][0] / values[i][1] * 1000;
    //   values[i] = double.parse((values[i]).toStringAsFixed(2));
    // }
    List<String> finalKeys = [
      // '09/2020',
      '10/2020',
      '11/2020',
      '12/2020',
      '01/2021',
      '02/2021',
      '03/2021',
      '04/2021',
      '05/2021',
      '06/2021',
      '07/2021'
    ];
    List<double> finalValues = List.filled(10, 0);
    for (int i = 0; i < keys.length; i++) {
      // List x=keys[i].split("/");
      // int y=int.parse(x[0])+int.parse(x[1])*100;
      // finalKeys[compare.indexOf(y)]=keys[i];
      if (finalKeys.contains(keys[i])) {
        finalValues[finalKeys.indexOf(keys[i])] = values[keys.indexOf(keys[i])];
      }
    }
    for (int i = 0; i < finalValues.length; i++) {
      if (finalValues[i] == 0) {
        finalValues[i] = medium;
      }
    }
    Map<List<String>, List<double>> result = {finalKeys: finalValues};
    // print(result);
    // print(result);
    return result;
  }

  Future<List<List<Property>>> getBestHouse(
      List y, List category, String region, String district) async {
    // var x=y[y.length-1].values.toList();
    var x = [y[y.length - 1]];
    // print(x[0]);
    List<Property> a =
        await run2(["chotot.com"], category, region, district, x[0]);
    List<Property> b =
        await run2(["nhadat247.com.vn"], category, region, district, x[0]);
    List<Property> c =
        await run2(["batdongsan.com.vn"], category, region, district, x[0]);
    return [a, b, c];
  }

  Future<List<Property>> run2(List homepage, List category, String region,
      String district, double price) async {
    // final documents = await cosmosDB.documents.list('data', 'detail_data');
    // print(documents);
    String collectionId = "final_data";
    String databaseId = "data";
    String count = "10";
    List condtion = [];

    if (homepage.length == 1) {
      if (homepage[0] != "all") {
        String b = '(' + 'c.homepage=' + "'" + homepage[0] + "'" + ')';
        condtion.add(b);
      }
    } else if (homepage.length == 2) {
      String b = '(' +
          'c.homepage=' +
          "'" +
          homepage[0] +
          "'" +
          'or c.homepage=' +
          "'" +
          homepage[1] +
          "'" ')';
      condtion.add(b);
    } else if (homepage.length == 3) {
      String b = '(' +
          'c.homepage=' +
          "'" +
          homepage[0] +
          "'" +
          'or c.homepage=' +
          "'" +
          homepage[1] +
          "'" 'or c.homepage=' +
          "'" +
          homepage[2] +
          "'" ')';
      condtion.add(b);
    }

    if (category.length == 1) {
      if (category[0] != "all") {
        String b = '(' + 'c.category=' + "'" + category[0] + "'" + ')';
        condtion.add(b);
      }
    } else {
      String b = "(";
      for (int i = 0; i < category.length; i++) {
        b = b + "c.category = " + "'" + category[i] + "'";
        if (i + 1 < category.length) {
          b = b + " or ";
        } else {
          b = b + ")";
        }
      }
      condtion.add(b);
    }

    if (region != 'null') {
      String b = '(' + 'c.region=' + "'" + region + "'" + ')';
      condtion.add(b);
    }

    if (district != 'null') {
      String b = '(' + 'c.district=' + "'" + district + "'" + ')';
      condtion.add(b);
    }
    String query = 'SELECT * FROM $collectionId c where ';
    for (int i = 0; i < condtion.length; i++) {
      query = query + condtion[i];
      if (i + 1 < condtion.length) {
        query = query + " and ";
      }
    }
    final results = await cosmosDB.documents.query(
        Query(
            query: query + "and c.price/StringToNumber(c.surface)<@price",
            parameters: {'price': price}),
        databaseId,
        collectionId,
        count);
    List<dynamic> resultlst = results.toList();
    print(resultlst.length);
    return List.generate(resultlst.length, (i) {
      return Property(
          category: resultlst[i]['category'],
          region: resultlst[i]['region'],
          price: resultlst[i]['price'],
          district: resultlst[i]['district'],
          surface: resultlst[i]['surface'],
          beds: resultlst[i]['bedrooms'],
          toilets: resultlst[i]['toilets'],
          description: resultlst[i]['description'],
          homepage: resultlst[i]['homepage'],
          user: resultlst[i]['user'],
          address: resultlst[i]['address'],
          date: resultlst[i]['date'],
          phoneNumber: resultlst[i]['phone'],
          imgLink: img(),
          url: resultlst[i]['url'],
          ward: resultlst[i]['ward'],
          width: resultlst[i]['width'],
          length: resultlst[i]['length'],
          street: resultlst[i]['street']);
    });
    // return results.toList();
  }

  dynamic listImages = [
    "images/house_01.jpg",
    "images/house_02.jpg",
    "images/house_03.jpg",
    "images/house_04.jpg",
    "images/house_05.jpg",
    "images/house_06.jpg",
    "images/house_07.jpg",
    "images/house_08.jpg",
  ];
  Random rnd;
  String img() {
    int min = 0;
    int max = listImages.length - 1;
    rnd = new Random();
    int r = min + rnd.nextInt(max - min);
    String imageName = listImages[r].toString();
    return imageName;
  }
}
