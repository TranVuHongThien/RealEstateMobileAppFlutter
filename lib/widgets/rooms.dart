import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_input/providers/rooms.dart';
import 'package:house_input/services/style.dart';

import 'custom_text.dart';

// ignore: must_be_immutable
class Rooms extends StatelessWidget {
  final int number;
  int id;
  Rooms(this.number, this.id);

  @override
  Widget build(BuildContext context) {
    RoomsProvider rooms = Provider.of<RoomsProvider>(context);
    return Container(
      decoration: BoxDecoration(
          color: rooms.numberOfRooms == NumberOfRooms.ONE && id == 1 ||
                  rooms.numberOfRooms == NumberOfRooms.TWO && id == 2 ||
                  rooms.numberOfRooms == NumberOfRooms.THREE && id == 3 ||
                  rooms.numberOfRooms == NumberOfRooms.FOUR && id == 4 ||
                  rooms.numberOfRooms == NumberOfRooms.FIVE && id == 5 ||
                  rooms.numberOfRooms == NumberOfRooms.MORE && id == 6
              ? black
              : grey[200],
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        child: (number == null)
            ? (rooms.numberOfRooms == NumberOfRooms.MORE && id == 6)
                ? (rooms.roomNumber == null)
                    ? CustomText(
                        msg: "N/A",
                        color: white,
                        size: 24,
                        weight: FontWeight.w400,
                      )
                    : CustomText(
                        msg: rooms.roomNumber.toString(),
                        color: white,
                        size: 24,
                        weight: FontWeight.w400,
                      )
                : CustomText(
                    msg: '+',
                    color: black,
                    size: 24,
                    weight: FontWeight.w400,
                  )
            : CustomText(
                msg: number.toString(),
                color: rooms.numberOfRooms == NumberOfRooms.ONE && id == 1 ||
                        rooms.numberOfRooms == NumberOfRooms.TWO && id == 2 ||
                        rooms.numberOfRooms == NumberOfRooms.THREE && id == 3 ||
                        rooms.numberOfRooms == NumberOfRooms.FOUR && id == 4 ||
                        rooms.numberOfRooms == NumberOfRooms.FIVE && id == 5 ||
                        rooms.numberOfRooms == NumberOfRooms.MORE && id == 6
                    ? white
                    : black,
                size: 24,
                weight: FontWeight.w400,
              ),
      ),
    );
  }
}
