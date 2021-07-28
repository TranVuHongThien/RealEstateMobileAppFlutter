import 'package:flutter/material.dart';

class UltiProvider with ChangeNotifier {
  // NumberOfBathRooms _numberOfBathRooms;
  String category;
  String homepage;
  var selectedRange;
  String count;
  String picked;
  String similarHomepage;
//  getters
  // NumberOfBathRooms get numberOfBathRooms => _numberOfBathRooms;

  UltiProvider() {
    similarHomepage = "chotot.com";
    selectedRange = RangeValues(0, 10);
    category = "nhà";
    homepage = "all";
    count = "100";
    picked = "100";
    // _numberOfBathRooms = NumberOfBathRooms.ONE;
    // bathNumber = 1;
    // notifyListeners();
  }

  changeCategory(String cat) {
    category = cat;
    notifyListeners();
  }

  changeSimilarHomepage(String cat) {
    similarHomepage = cat;
    notifyListeners();
  }

  changeSelectedRange(var range) {
    selectedRange = range;
    notifyListeners();
  }

  changeHomepage(String page) {
    homepage = page;
    notifyListeners();
  }

  changeCount(String no) {
    count = no;
    notifyListeners();
  }

  changePicked(String no) {
    picked = no;
    notifyListeners();
  }
}
