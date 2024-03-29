import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
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
        return ShiftTime.STOP_WORK;
      case 4:
        return ShiftTime.FREE;
      default:
        var logger = Logger();
        logger.wtf(
            "Index  $index not recognize to (re)create the shift time enums");
        throw Exception(
            "Index  $index not recognize to (re)create the shift time enums");
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
      case ShiftTime.STOP_WORK:
        return 3;
      case ShiftTime.FREE:
        return 4;
      default:
        throw Exception("Shift time not recognized");
    }
  }

  static String fromShiftTimeToString(ShiftTime shiftTime) {
    switch (shiftTime) {
      case ShiftTime.MORNING:
        return AppLocalization.getWithKey(Keys.Shifts_Name_Morning);
      case ShiftTime.AFTERNOON:
        return AppLocalization.getWithKey(Keys.Shifts_Name_Afternoon);
      case ShiftTime.NIGHT:
        return AppLocalization.getWithKey(Keys.Shifts_Name_Night);
      case ShiftTime.FREE:
        return AppLocalization.getWithKey(Keys.Shifts_Name_Free);
      case ShiftTime.STOP_WORK:
        return AppLocalization.getWithKey(Keys.Shifts_Name_Stop_Work);
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
      case ShiftTime.STOP_WORK:
        return "home.png";
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
      ShiftTime.STOP_WORK,
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
        return 4;
      case ShiftTime.NIGHT:
        return 2;
      case ShiftTime.STOP_WORK:
        return 3;
      default:
        throw Exception("Not valid shift $time");
    }
  }
}
