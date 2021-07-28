import 'package:flutter/material.dart';

enum Property { HOUSE, FLAT, LAND }

class PropertyProvider with ChangeNotifier {
  Property _selectedProperty = Property.HOUSE;
  String typeOfProperty = "nhà";
  PropertyProvider() {
    _selectedProperty = Property.HOUSE;
    typeOfProperty = "nhà";
  }

//  getter
  Property get selectedProperty => _selectedProperty;

  changePropertyType(Property type, String propertyType) {
    _selectedProperty = type;
    typeOfProperty = propertyType;
    notifyListeners();
  }
}
