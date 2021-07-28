import 'package:flutter/material.dart';

enum NumberOfBathRooms { ONE, TWO, THREE, FOUR, FIVE, MORE }

class BathRoomsProvider with ChangeNotifier {
  NumberOfBathRooms _numberOfBathRooms;
  int bathNumber;
//  getters
  NumberOfBathRooms get numberOfBathRooms => _numberOfBathRooms;

  BathRoomsProvider() {
    _numberOfBathRooms = NumberOfBathRooms.ONE;
    bathNumber = 1;
    notifyListeners();
  }

  changeNumberOfBathRooms(NumberOfBathRooms number, int noBath) {
    _numberOfBathRooms = number;
    bathNumber = noBath;
    notifyListeners();
  }
}
