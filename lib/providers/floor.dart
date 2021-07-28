import 'package:flutter/material.dart';

enum NumberOfFloor { ONE, TWO, THREE, FOUR, FIVE, MORE }

class FloorProvider with ChangeNotifier {
  NumberOfFloor _numberOfFloor;

//  getters
  NumberOfFloor get numberOfFloor => _numberOfFloor;

  FloorProvider() {
    _numberOfFloor = NumberOfFloor.ONE;
    notifyListeners();
  }

  changeNumberOfFloor(NumberOfFloor number) {
    _numberOfFloor = number;
    notifyListeners();
  }
}
