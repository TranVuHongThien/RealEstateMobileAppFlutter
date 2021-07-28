import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_input/providers/property.dart';
import 'package:house_input/services/style.dart';

import 'custom_text.dart';

class PropertyType extends StatefulWidget {
  final String image;
  final String title;

  PropertyType({@required this.image, @required this.title});

  @override
  _PropertyTypeState createState() => _PropertyTypeState();
}

class _PropertyTypeState extends State<PropertyType> {
  @override
  Widget build(BuildContext context) {
    PropertyProvider property = Provider.of<PropertyProvider>(context);

    return Container(
      decoration: BoxDecoration(
          color: white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: property.selectedProperty == Property.HOUSE &&
                            widget.title == "House" ||
                        property.selectedProperty == Property.FLAT &&
                            widget.title == "Flat" ||
                        property.selectedProperty == Property.LAND &&
                            widget.title == "Land"
                    //     ||
                    // property.selectedProperty == Property.HOUSELAND &&
                    //     widget.title == "Residential land" ||
                    // property.selectedProperty == Property.CONSLAND &&
                    //     widget.title == "Construction land"
                    ? black
                    : grey[400],
                offset: Offset(2, 3),
                blurRadius: 6)
          ]),
      // height: 240,
      width: 220,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Padding(
            child: CustomText(
              msg: widget.title,
              size: 24,
              color: property.selectedProperty == Property.HOUSE &&
                          widget.title == "House" ||
                      property.selectedProperty == Property.FLAT &&
                          widget.title == "Flat" ||
                      property.selectedProperty == Property.LAND &&
                          widget.title == "Land"
                  //     ||
                  // property.selectedProperty == Property.HOUSELAND &&
                  //     widget.title == "Residential land" ||
                  // property.selectedProperty == Property.CONSLAND &&
                  //     widget.title == "Construction land"
                  ? black
                  : grey,
              weight: FontWeight.bold,
            ),
            padding: EdgeInsets.all(5),
          ),
          Container(
            height: 180,
            width: 240,
            child: Image.asset("images/${widget.image}"),
            alignment: Alignment.bottomCenter,
          ),
        ],
      ),
    );
  }
}
