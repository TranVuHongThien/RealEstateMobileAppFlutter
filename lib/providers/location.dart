import 'package:dvhcvn/dvhcvn.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LocationProvider extends ChangeNotifier {
  int _latestChange;
  int get latestChange => _latestChange;

  Level1 _level1;
  Level1 get level1 => _level1;
  set level1(Level1 v) {
    if (v == _level1) return;

    _level1 = v;
    _level2 = null;
    _level3 = null;
    _latestChange = 1;
    notifyListeners();
  }

  Level2 _level2;
  Level2 get level2 => _level2;
  set level2(Level2 v) {
    if (v == _level2) return;

    _level2 = v;
    _level3 = null;
    _latestChange = 2;
    notifyListeners();
  }

  Level3 _level3;
  Level3 get level3 => _level3;
  set level3(Level3 v) {
    if (v == _level3) return;

    _level3 = v;
    _latestChange = 3;
    notifyListeners();
  }

  static LocationProvider of(BuildContext context, {bool listen = true}) =>
      Provider.of<LocationProvider>(context, listen: listen);
}
