import 'package:context_holder/context_holder.dart';
import 'package:flutter/material.dart';
import 'package:house_input/providers/location.dart';
import 'package:house_input/providers/bathrooms.dart';
import 'package:house_input/providers/property.dart';
import 'package:house_input/providers/rooms.dart';
import 'package:house_input/providers/ulti.dart';

import 'package:house_input/screens/main_page.dart';
import 'package:provider/provider.dart';
import 'package:house_input/providers/floor.dart';

void main() => runApp(MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: PropertyProvider()),
        ChangeNotifierProvider.value(value: RoomsProvider()),
        ChangeNotifierProvider.value(value: BathRoomsProvider()),
        ChangeNotifierProvider.value(value: FloorProvider()),
        ChangeNotifierProvider.value(value: LocationProvider()),
        ChangeNotifierProvider.value(value: UltiProvider())
      ],
      child: MyApp(),
    ));

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        navigatorKey: ContextHolder.key,
        debugShowCheckedModeBanner: false,
        title: 'Real State',
        theme: ThemeData(
          primarySwatch: Colors.indigo,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: MainPage());
  }
}
