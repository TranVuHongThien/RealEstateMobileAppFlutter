import 'dart:math';

import 'package:cosmosdb/cosmosdb.dart';
import 'package:house_input/data/property.dart';

class SearchQuery {
  String region;
  String district;
  String ward;
  var priceFrom;
  var priceTo;
  List category;
  List homepage;
  SearchQuery({
    this.region,
    this.district,
    this.ward,
    this.priceFrom,
    this.priceTo,
    this.category,
    this.homepage,
  });
  final _cosmosDB = CosmosDB(
    masterKey:
        '6XOmPMbWF4IWgJE9ZiEvlSoJGB1Lz3G6L1hVW8zQKn2qqczUe1lcOWmFAYlSufHrSh67QPuZH3mg9ZBnv6lklA==',
    baseUrl: 'https://synapselink1.documents.azure.com:443/',
  );
  String _collectionId = "final_data";
  String _databaseId = "data";
  String count = "-1";
  List condtion = [];
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

  // Future<List<Property>> queryNoHomePage() async {
  //   // get all documents from a collection

  //   // final documents = await cosmosDB.documents.list('data', 'detail_data');
  //   // print(documents);
  //   final results = await _cosmosDB.documents.query(
  //     Query(
  //         query:
  //             'SELECT c.price,c.bedrooms,c.category,c.region,c.district,c.surface,c.toilets,c.user,c.homepage,c.description,c.address,c.date,c.phone FROM $_collectionId c where c.region=@region and c.district=@district and c.price <= @price2 and c.price >= @price1 and c.category=@category',
  //         parameters: {
  //           'region': region,
  //           'district': district,
  //           'price1': priceFrom,
  //           'price2': priceTo,
  //           'category': category
  //         }),
  //     _databaseId,
  //     _collectionId,
  //     count,
  //   );
  //   // await Future.delayed(Duration(seconds: 10));
  //   // return results.toList();
  //   List<dynamic> resultlst = results.toList();
  //   print(resultlst.length);
  //   return List.generate(resultlst.length, (i) {
  //     return Property(
  //         category: resultlst[i]['category'],
  //         region: resultlst[i]['region'],
  //         price: resultlst[i]['price'],
  //         district: resultlst[i]['district'],
  //         surface: resultlst[i]['surface'],
  //         beds: resultlst[i]['bedrooms'],
  //         toilets: resultlst[i]['toilets'],
  //         description: resultlst[i]['description'],
  //         homepage: resultlst[i]['homepage'],
  //         user: resultlst[i]['user'],
  //         address: resultlst[i]['address'],
  //         date: resultlst[i]['date'],
  //         phoneNumber: resultlst[i]['phone'],
  //         imgLink: img(),
  //         url: resultlst[i]['url']);
  //   });
  //   // run("Hồ Chí Minh","Quận 1",1,10);
  // }

  Future<List<Property>> queryWithHomePage() async {
    // get all documents from a collection

    // final documents = await cosmosDB.documents.list('data', 'detail_data');
    // print(documents);
    // final results = await _cosmosDB.documents.query(
    //   Query(
    //       query:
    //           'SELECT c.price,c.bedrooms,c.category,c.region,c.district,c.surface,c.toilets,c.user,c.homepage,c.description,c.address,c.date,c.phone FROM $_collectionId c where c.region=@region and c.district=@district and c.price <= @price2 and c.price >= @price1 and c.category=@category and c.homepage=@homepage',
    //       parameters: {
    //         'region': region,
    //         'district': district,
    //         'price1': priceFrom,
    //         'price2': priceTo,
    //         'category': category,
    //         'homepage': homepage
    //       }),
    //   _databaseId,
    //   _collectionId,
    //   count,
    // );
    // // await Future.delayed(Duration(seconds: 10));
    // // return results.toList();
    // List<dynamic> resultlst = results.toList();
    // print(resultlst.length);
    // return List.generate(resultlst.length, (i) {
    //   return Property(
    //       category: resultlst[i]['category'],
    //       region: resultlst[i]['region'],
    //       price: resultlst[i]['price'],
    //       district: resultlst[i]['district'],
    //       surface: resultlst[i]['surface'],
    //       beds: resultlst[i]['bedrooms'],
    //       toilets: resultlst[i]['toilets'],
    //       description: resultlst[i]['description'],
    //       homepage: resultlst[i]['homepage'],
    //       user: resultlst[i]['user'],
    //       address: resultlst[i]['address'],
    //       date: resultlst[i]['date'],
    //       phoneNumber: resultlst[i]['phone'],
    //       imgLink: img(),
    //       url: resultlst[i]['url']);
    // });
    // run("Hồ Chí Minh","Quận 1",1,10);
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

    if (ward != 'null') {
      String b = '(' + 'c.ward=' + "'" + ward + "'" + ')';
      condtion.add(b);
    }

    condtion.add('(' + 'c.price>' + priceFrom.toString() + ')');
    if (priceTo.runtimeType == double) {
      condtion.add('(' + 'c.price<' + priceTo.toString() + ')');
    }
    String query = 'SELECT * FROM $_collectionId c where ';
    for (int i = 0; i < condtion.length; i++) {
      query = query + condtion[i];
      if (i + 1 < condtion.length) {
        query = query + " and ";
      }
    }

    final results = await _cosmosDB.documents.query(
        Query(query: query, parameters: {
          'region': DateTime.now().millisecondsSinceEpoch,
          'district': district,
          'price1': priceFrom,
          'price2': priceTo
        }),
        _databaseId,
        _collectionId,
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
  }

  Future<List<Property>> initQuery() async {
    // get all documents from a collection

    // final documents = await cosmosDB.documents.list('data', 'detail_data');
    // print(documents);
    final results = await _cosmosDB.documents.query2(
      Query(
          query: 'SELECT * FROM $_collectionId c order by c._ts desc',
          parameters: {}),
      _databaseId,
      _collectionId,
      "20",
    );
    // await Future.delayed(Duration(seconds: 10));
    // return results.toList();
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
          width: resultlst[i]['width'],
          length: resultlst[i]['length'],
          ward: resultlst[i]['ward'],
          street: resultlst[i]['street']);
    });
    // run("Hồ Chí Minh","Quận 1",1,10);
  }
}
