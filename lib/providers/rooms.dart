import 'package:flutter/material.dart';

enum NumberOfRooms { ONE, TWO, THREE, FOUR, FIVE, MORE }

class RoomsProvider with ChangeNotifier {
  NumberOfRooms _numberOfRooms;
  int roomNumber;
//  getters
  NumberOfRooms get numberOfRooms => _numberOfRooms;

  RoomsProvider() {
    _numberOfRooms = NumberOfRooms.ONE;
    roomNumber = 1;
    notifyListeners();
  }

  changeNumberOfRooms(NumberOfRooms number, int noRooms) {
    _numberOfRooms = number;
    roomNumber = noRooms;
    notifyListeners();
  }
}
