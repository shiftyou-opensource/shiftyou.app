import 'package:flutter/widgets.dart';
import 'package:nurse_time/model/shift.dart';

class Converter {
  static ShiftTime fromIntToShiftTime(int index) {
    switch (index) {
      case 0:
        return ShiftTime.MORNING;
      case 1:
        return ShiftTime.AFTERNOON;
      case 2:
        return ShiftTime.NIGHT;
      case 3:
        return ShiftTime.FREE;
      default:
        print(index);
        throw Exception(
            "Index not recognize to (re)cereate the shift time enumas");
    }
  }

  static int fromShiftTimeToIndex(ShiftTime shiftTime) {
    switch (shiftTime) {
      case ShiftTime.MORNING:
        return 0;
      case ShiftTime.AFTERNOON:
        return 1;
      case ShiftTime.NIGHT:
        return 2;
      case ShiftTime.FREE:
        return 3;
      default:
        throw Exception("Shift time not recognized");
    }
  }

  static String fromShiftTimeToString(ShiftTime shiftTime) {
    switch (shiftTime) {
      case ShiftTime.MORNING:
        return "Morning";
      case ShiftTime.AFTERNOON:
        return "Afternoon";
      case ShiftTime.NIGHT:
        return "Night";
      case ShiftTime.FREE:
        return "Free";
      default:
        throw Exception("Shift time not recognized");
    }
  }

  static String fromShiftTimeToImage(ShiftTime shift) {
    switch (shift) {
      case ShiftTime.AFTERNOON:
        return "coffee.png";
      case ShiftTime.MORNING:
        return "morning.png";
      case ShiftTime.FREE:
        return "foryou.png";
      case ShiftTime.NIGHT:
        return "night.png";
      default:
        throw Exception("No image found with name $shift");
    }
  }

  static List<Image> shiftToListOfImages(
      {String baseImgPath = "assets/images", double height = 35.0}) {
    var shiftTime = [
      ShiftTime.MORNING,
      ShiftTime.AFTERNOON,
      ShiftTime.NIGHT,
      ShiftTime.FREE
    ];
    List<Image> images = List.empty(growable: true);
    for (var index = 0; index < shiftTime.length; index++) {
      var shift = shiftTime[index];
      images.add(Image(
          image: AssetImage(
              "$baseImgPath/${Converter.fromShiftTimeToImage(shift)}"),
          height: height));
    }
    return images;
  }

  static int shiftToListPosition(ShiftTime time) {
    switch (time) {
      case ShiftTime.AFTERNOON:
        return 1;
      case ShiftTime.MORNING:
        return 0;
      case ShiftTime.FREE:
        return 3;
      case ShiftTime.NIGHT:
        return 2;
      default:
        throw Exception("Not valid shift $time");
    }
  }
}
