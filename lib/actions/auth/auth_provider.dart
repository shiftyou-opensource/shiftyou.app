import 'package:flutter/cupertino.dart';
import 'package:nurse_time/actions/auth/apple_sign_in.dart';
import 'package:nurse_time/actions/auth/google_sign_in.dart';
import 'package:nurse_time/actions/auth/sign_in_interface.dart';
import 'package:nurse_time/model/user_model.dart';

class AuthProvider {
  AuthProvider({required this.providerIml});

  //TODO: adding this in a map with the following mapping
  // <key, Provider>
  static const GOOGLE = "GOOGLE";
  static const APPLE = "APPLE";

  late AbstractManagerUserLogin providerIml;

  factory AuthProvider.build({required String provider}) {
    switch (provider) {
      case GOOGLE:
        {
          return AuthProvider(providerIml: _createGoogleProvider());
        }
      case APPLE:
        {
          return AuthProvider(providerIml: _createAppleProvider());
        }
    }
    throw Exception("Provider $provider not supported");
  }

  static AbstractManagerUserLogin _createGoogleProvider() {
    return GoogleManagerUserLogin();
  }

  static AbstractManagerUserLogin _createAppleProvider() {
    return AppleManageUserLogin();
  }

  Future<UserModel> login({String? email, String? password}) async {
    return await providerIml.signIn();
  }

  Future<bool> logOut() async {
    await providerIml.signOut();
    return true;
  }

  bool available({TargetPlatform? platform}) {
    return providerIml.available(platform: platform);
  }
}
