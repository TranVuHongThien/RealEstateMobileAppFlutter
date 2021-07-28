import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:house_input/providers/bathrooms.dart';
import 'package:house_input/services/style.dart';

import 'custom_text.dart';

// ignore: must_be_immutable
class BathRooms extends StatelessWidget {
  final int number;
  int id;
  BathRooms(this.number, this.id);

  @override
  Widget build(BuildContext context) {
    BathRoomsProvider rooms = Provider.of<BathRoomsProvider>(context);
    return Container(
      decoration: BoxDecoration(
          color: rooms.numberOfBathRooms == NumberOfBathRooms.ONE && id == 1 ||
                  rooms.numberOfBathRooms == NumberOfBathRooms.TWO && id == 2 ||
                  rooms.numberOfBathRooms == NumberOfBathRooms.THREE &&
                      id == 3 ||
                  rooms.numberOfBathRooms == NumberOfBathRooms.FOUR &&
                      id == 4 ||
                  rooms.numberOfBathRooms == NumberOfBathRooms.FIVE &&
                      id == 5 ||
                  rooms.numberOfBathRooms == NumberOfBathRooms.MORE && id == 6
              ? black
              : grey[200],
          borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
        child: (number == null)
            ? (rooms.numberOfBathRooms == NumberOfBathRooms.MORE && id == 6)
                ? (rooms.bathNumber == null)
                    ? CustomText(
                        msg: "N/A",
                        color: white,
                        size: 24,
                        weight: FontWeight.w400,
                      )
                    : CustomText(
                        msg: rooms.bathNumber.toString(),
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
                color: rooms.numberOfBathRooms == NumberOfBathRooms.ONE &&
                            id == 1 ||
                        rooms.numberOfBathRooms == NumberOfBathRooms.TWO &&
                            id == 2 ||
                        rooms.numberOfBathRooms == NumberOfBathRooms.THREE &&
                            id == 3 ||
                        rooms.numberOfBathRooms == NumberOfBathRooms.FOUR &&
                            id == 4 ||
                        rooms.numberOfBathRooms == NumberOfBathRooms.FIVE &&
                            id == 5 ||
                        rooms.numberOfBathRooms == NumberOfBathRooms.MORE &&
                            id == 6
                    ? white
                    : black,
                size: 24,
                weight: FontWeight.w400,
              ),
      ),
    );
  }
}
