// import 'dart:ffi';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'dart:math';

import 'package:cosmosdb/cosmosdb.dart';
import 'package:house_input/data/property.dart';

class SimilarQuery {
  List homepage;
  String region;
  String district;
  String ward;
  String street;
  String category;
  double surface;
  double width;
  double length;
  int toilets;
  int bedrooms;
  double price;
  SimilarQuery(
      {this.homepage,
      this.region,
      this.district,
      this.ward,
      this.street,
      this.category,
      this.surface,
      this.width,
      this.length,
      this.toilets,
      this.bedrooms,
      this.price});
  final cosmosDB = CosmosDB(
    masterKey:
        '6XOmPMbWF4IWgJE9ZiEvlSoJGB1Lz3G6L1hVW8zQKn2qqczUe1lcOWmFAYlSufHrSh67QPuZH3mg9ZBnv6lklA==',
    baseUrl: 'https://synapselink1.documents.azure.com:443/',
  );
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

// get all documents from a collection
//   Future<List> getDistrict(String model, String region, String district,
//       String ward, String category) async {
//     // final documents = await cosmosDB.documents.list('data', 'detail_data');
//     // print(documents);
//     var collectionId = "final_data";
//     var databaseId = "data";
//     String count = "-1";
//     final results = await cosmosDB.documents.query(
//         Query(
//             query:
//                 'SELECT * FROM $collectionId c where c.homepage=@model and c.district=@district and c.region=@region and c.category=@category and c.ward=@ward',
//             parameters: {
//               'model': model,
//               'region': region,
//               'district': district,
//               'category': category,
//               'ward': ward
//             }),
//         databaseId,
//         collectionId,
//         count);

//     return results.toList();
//   }

//   Future<List> getStreet(String model, String region, String district,
//       String street, String category) async {
//     // final documents = await cosmosDB.documents.list('data', 'detail_data');
//     // print(documents);
//     var collectionId = "final_data";
//     var databaseId = "data";
//     String count = "-1";
//     final results = await cosmosDB.documents.query(
//         Query(
//             query:
//                 'SELECT * FROM $collectionId c where c.homepage=@model and c.district=@district and c.region=@region and c.street=@street',
//             parameters: {
//               'model': model,
//               'region': region,
//               'district': district,
//               'street': street,
//               'category': category
//             }),
//         databaseId,
//         collectionId,
//         count);
//     return results.toList();
//   }

// // ignore: public_member_api_docs
//   Future<List<Property>> findComps() async {
//     Future<List> a = getStreet(homepage, region, district, street, category);
//     List index = [];
//     List b = await a;
//     List c = [];
//     if (b.length >= 20) {
//       c = rankPoint(b, surface, width, length, toilets, bedrooms, price);
//       Map x = {street: c.length};
//       index.add(x);
//       if (c.length < 20) {
//         List d = await getDistrict(homepage, region, district, ward, category);
//         // print(d.length);
//         List e =
//             rankPoint2(d, 3, surface, width, length, toilets, bedrooms, price);
//         c = c + e;
//         List y = haha(e);
//         index = index + y;
//       }
//     } else {
//       c = b;
//       List d = await getDistrict(homepage, region, district, ward, category);
//       Map x = {street: c.length};
//       index.add(x);
//       List e =
//           rankPoint2(d, 3, surface, width, length, toilets, bedrooms, price);
//       List y = haha(e);
//       index = index + y;
//       c = c + e;
//     }
//     // print(index);
//     // print(c.length);
//     // return [index, c];
//     // print(c[0].toString());
//     print(c.length);
//     return List.generate(c.length, (i) {
//       return Property(
//           category: c[i]['category'],
//           region: c[i]['region'],
//           price: c[i]['price'],
//           district: c[i]['district'],
//           surface: c[i]['surface'],
//           beds: c[i]['bedrooms'],
//           toilets: c[i]['toilets'],
//           description: c[i]['description'],
//           homepage: c[i]['homepage'],
//           user: c[i]['user'],
//           address: c[i]['address'],
//           date: c[i]['date'],
//           phoneNumber: c[i]['phone'],
//           url: c[i]['url'],
//           imgLink: img(),
//           width: c[i]['width'],
//           length: c[i]['length'],
//           ward: c[i]['ward'],
//           street: c[i]['street']);
//     });
//   }

//   List rankPoint(List b, double surface, double width, double length,
//       int toilets, int bedrooms, double price) {
//     List c = [];
//     for (int i = 0; i < b.length; i++) {
//       int score = 0;
//       double bSurface = double.parse(b[i]['surface']);
//       var bPrice = b[i]['price'];
//       double bWidth = 0;
//       if (b[i]['width'].runtimeType == Null) {
//         bWidth = -1;
//       } else {
//         bWidth = double.parse(b[i]['width']);
//       }
//       double bLength = 0;
//       if (b[i]['length'].runtimeType == Null) {
//         bLength = -1;
//       } else {
//         bLength = double.parse(b[i]['length']);
//       }
//       // var bWidth=double.parse(b[i]['width']);
//       var bToilets = int.parse(b[i]['toilets']);
//       var bBedrooms = int.parse(b[i]['bedrooms']);
//       if (((price / surface) - 0.005) < (bPrice / bSurface) &&
//           (bPrice / bSurface) < ((price / surface) + 0.005)) {
//         score = score + 1;
//       }
//       if ((surface - 10) < bSurface && bSurface < (surface + 10)) {
//         score = score + 1;
//       }
//       if ((width - 2 < bWidth) && (bWidth < width + 2)) {
//         score = score + 1;
//       }
//       if ((length - 2 < bLength) && (bLength < length + 2)) {
//         score = score + 1;
//       }
//       if ((toilets - 1) < bToilets && bToilets < (toilets + 1)) {
//         score = score + 1;
//       }
//       if ((bedrooms - 1) < bBedrooms && bBedrooms < (bedrooms + 1)) {
//         score = score + 1;
//       }
//       if (score > 2) {
//         c.add(b[i]);
//       }
//     }
//     return c;
//   }

//   List rankPoint2(List b, int size, double surface, double width, double length,
//       int toilets, int bedrooms, double price) {
//     List c = [];
//     for (int i = 0; i < b.length; i++) {
//       int score = 0;
//       double bSurface = double.parse(b[i]['surface']);
//       var bPrice = b[i]['price'];
//       double bWidth = -1;
//       if (b[i]['width'].runtimeType == Null) {
//         bWidth = -1;
//       } else {
//         bWidth = double.parse(b[i]['width']);
//       }
//       double bLength = 0;
//       if (b[i]['length'].runtimeType == Null) {
//         bLength = -1;
//       } else {
//         bLength = double.parse(b[i]['length']);
//       }
//       // var bWidth=double.parse(b[i]['width']);
//       var bToilets = int.parse(b[i]['toilets']);
//       var bBedrooms = int.parse(b[i]['bedrooms']);
//       if ((price / surface - 0.005) < (bPrice / bSurface) &&
//           (bPrice / bSurface) < (price / surface + 0.005)) {
//         score = score + 1;
//       }
//       if ((surface - 10) < bSurface && bSurface < (surface + 10)) {
//         score = score + 1;
//       }
//       if ((width - 2 < bWidth) && (bWidth < width + 2)) {
//         score = score + 1;
//       }
//       if ((toilets - 1) < bToilets && bToilets < (toilets + 1)) {
//         score = score + 1;
//       }
//       if ((bedrooms - 1) < bBedrooms && bBedrooms < (bedrooms + 1)) {
//         score = score + 1;
//       }
//       if ((length - 2 < bLength) && (bLength < length + 2)) {
//         score = score + 1;
//       }
//       if (score >= size) {
//         c.add(b[i]);
//       }
//     }
//     // print(c.length);

//     return c;
//   }

//   List haha(List b) {
//     List keys = [];
//     List values = [];
//     for (int i = 0; i < b.length; i++) {
//       if (keys.contains(b[i]['street'])) {
//         values[keys.indexOf(b[i]['street'])] += 1;
//       } else {
//         keys.add(b[i]['street']);
//         values.add(1);
//       }
//     }
//     List result = [];
//     for (int i = 0; i < keys.length; i++) {
//       Map x = {keys[i]: values[i]};
//       result.add(x);
//     }
//     return result;
//   }

  Future<List> getDistrict(List homepage, String region, String district,
      String ward, String category) async {
    // final documents = await cosmosDB.documents.list('data', 'detail_data');
    // print(documents);
    var collectionId = "final_data";
    var databaseId = "data";
    String count = "-1";

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
    String query = '';
    for (int i = 0; i < condtion.length; i++) {
      query = query + condtion[i];
      if (i + 1 < condtion.length) {
        query = query + " and ";
      }
    }
    // print(query);
    final results = await cosmosDB.documents.query(
        Query(
            query:
                'SELECT * FROM $collectionId c where c.district=@district and c.region=@region and c.ward=@ward and c.category=@category and ' +
                    query,
            parameters: {
              'region': region,
              'district': district,
              'ward': ward,
              'category': category
            }),
        databaseId,
        collectionId,
        count);

    return results.toList();
  }

  Future<List> getStreet(List homepage, String region, String district,
      String street, String category) async {
    // final documents = await cosmosDB.documents.list('data', 'detail_data');
    // print(documents);
    var collectionId = "final_data";
    var databaseId = "data";
    String count = "-1";
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
    String query = '';
    for (int i = 0; i < condtion.length; i++) {
      query = query + condtion[i];
      if (i + 1 < condtion.length) {
        query = query + " and ";
      }
    }
    // print(query);
    final results = await cosmosDB.documents.query(
        Query(
            query:
                'SELECT * FROM $collectionId c where c.district=@district and c.region=@region and c.street=@street and c.category=@category and ' +
                    query,
            parameters: {
              'region': region,
              'district': district,
              'street': street,
              'category': category
            }),
        databaseId,
        collectionId,
        count);
    return results.toList();
  }

// void address_split(a, List c) {
//   List x = a.split(" > ");
//   //region
//   if (x[0].contains('Thành phố')) {
//     c.add(x[0].split("Thành phố ")[1]);
//   } else if (x[0].contains('Tỉnh')) {
//     c.add(x[0].split("Tỉnh ")[1]);
//   } else {
//     c.add(x[0]);
//   }
//   //district
//   if (x[1].contains('Quận')) {
//     c.add("d " + x[1].split("Quận ")[1]);
//   } else if (x[1].contains('Huyện')) {
//     c.add("d " + x[1].split("Huyện ")[1]);
//   } else if (x[1].contains('Thành phố')) {
//     c.add("d " + x[1].split("Thành phố ")[1]);
//   } else if (x[1].contains('Thị xã')) {
//     c.add("d " + x[1].split("Thị xã ")[1]);
//   } else {
//     c.add("d " + x[1]);
//   }
//   //ward
//   if (x[2].contains('Phường')) {
//     c.add(x[2].split("Phường ")[1]);
//   } else if (x[2].contains('Xã')) {
//     c.add(x[2].split("Xã ")[1]);
//   }
// }

// ignore: public_member_api_docs
  Future<List<Property>> findComps() async {
    Future<List> a = getStreet(homepage, region, district, street, category);
    List index = [];
    List b = await a;
    List c = [];
    if (b.length >= 20) {
      c = rankPoint(b, surface, width, length, toilets, bedrooms, price);
      if (c.length < 20) {
        List d = await getDistrict(homepage, region, district, ward, category);
        List e =
            rankPoint2(d, 3, surface, width, length, toilets, bedrooms, price);
        c = c + e;
        // List y = haha(c);
        index = index + c;
      } else {
        // List y = haha(c);
        index = index + c;
      }
    } else {
      c = c + b;
      List d = await getDistrict(homepage, region, district, ward, category);
      List e =
          rankPoint2(d, 3, surface, width, length, toilets, bedrooms, price);
      c = c + e;
      // List y = haha(c);
      index = index + c;
    }
    print(index.length);
    return List.generate(index.length, (i) {
      return Property(
          category: index[i]['category'],
          region: index[i]['region'],
          price: index[i]['price'],
          district: index[i]['district'],
          surface: index[i]['surface'],
          beds: index[i]['bedrooms'],
          toilets: index[i]['toilets'],
          description: index[i]['description'],
          homepage: index[i]['homepage'],
          user: index[i]['user'],
          address: index[i]['address'],
          date: index[i]['date'],
          phoneNumber: index[i]['phone'],
          url: index[i]['url'],
          imgLink: img(),
          width: index[i]['width'],
          length: index[i]['length'],
          ward: index[i]['ward'],
          street: index[i]['street']);
    });
  }

  List rankPoint(List b, double surface, double width, double length,
      int toilets, int bedrooms, double price) {
    List c = [];
    for (int i = 0; i < b.length; i++) {
      int score = 0;
      double bSurface = double.parse(b[i]['surface']);
      double bWidth = 0;
      if (b[i]['width'].runtimeType == Null) {
        bWidth = -1;
      } else {
        bWidth = double.parse(b[i]['width']);
      }
      double bLength = 0;
      if (b[i]['length'].runtimeType == Null) {
        bLength = -1;
      } else {
        bLength = double.parse(b[i]['length']);
      }
      // var bWidth=double.parse(b[i]['width']);
      var bToilets = int.parse(b[i]['toilets']);
      var bBedrooms = int.parse(b[i]['bedrooms']);
      if (price != -1) {
        var bPrice = b[i]['price'];
        if (((price / surface) - 0.005) < (bPrice / bSurface) &&
            (bPrice / bSurface) < ((price / surface) + 0.005)) {
          score = score + 1;
        }
      }
      if ((surface - 10) < bSurface && bSurface < (surface + 10)) {
        score = score + 1;
      }
      if ((width - 2 < bWidth) && (bWidth < width + 2)) {
        score = score + 1;
      }
      if ((length - 2 < bLength) && (bLength < length + 2)) {
        score = score + 1;
      }
      if ((toilets - 1) < bToilets && bToilets < (toilets + 1)) {
        score = score + 1;
      }
      if ((bedrooms - 1) < bBedrooms && bBedrooms < (bedrooms + 1)) {
        score = score + 1;
      }
      if (score > 2) {
        c.add(b[i]);
      }
    }
    return c;
  }

  List rankPoint2(List b, int size, double surface, double width, double length,
      int toilets, int bedrooms, double price) {
    List c = [];
    for (int i = 0; i < b.length; i++) {
      int score = 0;
      double bSurface = double.parse(b[i]['surface']);
      double bWidth = -1;
      if (b[i]['width'].runtimeType == Null) {
        bWidth = -1;
      } else {
        bWidth = double.parse(b[i]['width']);
      }
      double bLength = 0;
      if (b[i]['length'].runtimeType == Null) {
        bLength = -1;
      } else {
        bLength = double.parse(b[i]['length']);
      }
      // var bWidth=double.parse(b[i]['width']);
      var bToilets = int.parse(b[i]['toilets']);
      var bBedrooms = int.parse(b[i]['bedrooms']);
      if (price != -1) {
        var bPrice = b[i]['price'];
        if ((price / surface - 0.005) < (bPrice / bSurface) &&
            (bPrice / bSurface) < (price / surface + 0.005)) {
          score = score + 1;
        }
      }
      if ((surface - 10) < bSurface && bSurface < (surface + 10)) {
        score = score + 1;
      }
      if ((width - 2 < bWidth) && (bWidth < width + 2)) {
        score = score + 1;
      }
      if ((toilets - 1) < bToilets && bToilets < (toilets + 1)) {
        score = score + 1;
      }
      if ((bedrooms - 1) < bBedrooms && bBedrooms < (bedrooms + 1)) {
        score = score + 1;
      }
      if ((length - 2 < bLength) && (bLength < length + 2)) {
        score = score + 1;
      }
      if (score >= size) {
        c.add(b[i]);
      }
    }

    return c;
  }

  // List haha(List b) {
  //   List keys = [];
  //   List values = [];
  //   for (int i = 0; i < b.length; i++) {
  //     if (keys.contains(b[i]['street'])) {
  //       values[keys.indexOf(b[i]['street'])].add(b[i]);
  //     } else {
  //       keys.add(b[i]['street']);
  //       List a = [b[i]];
  //       values.add(a);
  //     }
  //   }
  //   // print(keys.length);
  //   // print(values[0].runtimeType);
  //   List result = [];
  //   for (int i = 0; i < keys.length; i++) {
  //     Map x = {keys[i]: values[i]};
  //     result.add(x);
  //   }
  //   // print("**********************");
  //   // print(result[0].values.toList()[0].length);
  //   // print("**********************");
  //   return result;
  // }
  List haha(List b) {
    List keys = [];
    List values = [];
    for (int i = 0; i < b.length; i++) {
      if (keys.contains(b[i]['street'])) {
        values[keys.indexOf(b[i]['street'])] += 1;
      } else {
        keys.add(b[i]['street']);
        values.add(1);
      }
    }
    List result = [];
    for (int i = 0; i < keys.length; i++) {
      Map x = {keys[i]: values[i]};
      result.add(x);
    }
    return result;
  }
}
