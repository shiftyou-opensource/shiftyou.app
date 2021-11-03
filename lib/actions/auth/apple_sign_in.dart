import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nurse_time/actions/auth/sign_in_interface.dart';
import 'package:nurse_time/model/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class AppleManageUserLogin extends AbstractManagerUserLogin {
  late User _currentUser;

  @override
  User getCurrentUser() {
    return _currentUser;
  }

  @override
  Future<UserModel> signIn() async {
    var auth = FirebaseAuth.instance;
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    //TODO support also the web to support android https://stackoverflow.com/a/63515753/10854225
    var redirectURL =
        "https://now.bruce.bublina.eu.org/callbacks/sign_in_with_apple";
    var clientID = "io.github.vincenzopalazzo.shiftyou";
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
      webAuthenticationOptions: WebAuthenticationOptions(
          clientId: clientID, redirectUri: Uri.parse(redirectURL)),
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider("apple.com").credential(
      accessToken: appleCredential.authorizationCode,
      rawNonce: rawNonce,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    _currentUser = (await auth.signInWithCredential(oauthCredential)).user!;

    var userId = _currentUser.getIdToken().hashCode;
    return UserModel(
        id: userId,
        name: _currentUser.displayName.toString(),
        logged: true,
        initialized: true);
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    final charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  @override
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  bool available() {
    return true;
  }
}
