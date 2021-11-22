import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/localization/keys.dart';
import 'package:nurse_time/model/user_model.dart';
import 'sign_in_interface.dart';

class GoogleManagerUserLogin extends AbstractManagerUserLogin {
  late GoogleSignIn _googleSignIn;
  late User _currentUser;

  GoogleManagerUserLogin() {
    this._googleSignIn = GoogleSignIn();
  }

  @override
  User getCurrentUser() {
    return this._currentUser;
  }

  @override
  Future<UserModel> signIn() async {
    // Trigger the authentication flow
    var auth = FirebaseAuth.instance;
    var logger = GetIt.instance.get<Logger>();
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    // Create a new credential
    final OAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential authResult =
        await auth.signInWithCredential(credential);
    if (authResult.user == null) {
      throw Exception("User credential are a null object");
    }
    this._currentUser = authResult.user!;

    logger.d("User is anonymous ${this._currentUser.isAnonymous}");
    final User? currentUser = auth.currentUser;

    return UserModel(
        name: currentUser!.displayName ??
            AppLocalization.getWithKey(Keys.Words_Anonymous),
        email: currentUser.email ??
            AppLocalization.getWithKey(Keys.Words_Anonymous),
        logged: true,
        initialized: true);
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }

  @override
  bool available({TargetPlatform? platform}) {
    return true;
  }

  @override
  Future<void> updateUserInfo(
      {String? name,
      String? email,
      String? urlPhoto,
      String? phoneNumber}) async {
    if (name == null && email == null) {
      return;
    }
    if (name != null) {
      _currentUser.updateDisplayName(name);
    }
    if (email != null) {
      _currentUser.updateEmail(email);
    }
  }
}
