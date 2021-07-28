import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_input/providers/floor.dart';
import 'package:house_input/services/style.dart';

import 'custom_text.dart';

// ignore: must_be_immutable
class Floor extends StatelessWidget {
  final int number;
  int id;
  Floor(this.number, this.id);

  @override
  Widget build(BuildContext context) {
    FloorProvider rooms = Provider.of<FloorProvider>(context);
    return Container(
      decoration: BoxDecoration(
          color: rooms.numberOfFloor == NumberOfFloor.ONE && id == 1 ||
                  rooms.numberOfFloor == NumberOfFloor.TWO && id == 2 ||
                  rooms.numberOfFloor == NumberOfFloor.THREE && id == 3 ||
                  rooms.numberOfFloor == NumberOfFloor.FOUR && id == 4 ||
                  rooms.numberOfFloor == NumberOfFloor.FIVE && id == 5 ||
                  rooms.numberOfFloor == NumberOfFloor.MORE && id == 6
              ? black
              : grey[200],
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        child: (number == null)
            ? CustomText(
                msg: '?',
                color:
                    rooms.numberOfFloor == NumberOfFloor.MORE && number == null
                        ? white
                        : black,
                size: 24,
                weight: FontWeight.w400,
              )
            : CustomText(
                msg: number.toString(),
                color: rooms.numberOfFloor == NumberOfFloor.ONE && id == 1 ||
                        rooms.numberOfFloor == NumberOfFloor.TWO && id == 2 ||
                        rooms.numberOfFloor == NumberOfFloor.THREE && id == 3 ||
                        rooms.numberOfFloor == NumberOfFloor.FOUR && id == 4 ||
                        rooms.numberOfFloor == NumberOfFloor.FIVE && id == 5 ||
                        rooms.numberOfFloor == NumberOfFloor.MORE && id == 6
                    ? white
                    : black,
                size: 24,
                weight: FontWeight.w400,
              ),
      ),
    );
  }
}
