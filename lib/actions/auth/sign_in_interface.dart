import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:nurse_time/model/user_model.dart';

abstract class AbstractManagerUserLogin {
  Future<UserModel> signIn();
  Future<void> signOut();
  User getCurrentUser();
  bool available({TargetPlatform? platform});
  Future<void> updateUserInfo(
      {String? name, String? email, String? urlPhoto, String? phoneNumber});
}
