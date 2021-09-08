import 'package:flutter/cupertino.dart';

enum AppIcon { SORRY, NICE }

class IconProvider {
  static final IconProvider instance = IconProvider.__internal();

  factory IconProvider() => instance;

  static const BASE_IMAGE_PATH = "assets/images";
  final Map<String, String> _images = {
    AppIcon.SORRY.toString(): "$BASE_IMAGE_PATH/sorry.png",
    AppIcon.NICE.toString(): "$BASE_IMAGE_PATH/nice.png"
  };

  IconProvider.__internal();

  AssetImage getImage(AppIcon key) {
    var localKey = key.toString();
    if (_images.containsKey(localKey)) return AssetImage(_images[localKey]!);
    throw ErrorDescription("No image with key $key found");
  }
}
