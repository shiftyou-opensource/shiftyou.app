import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'sign_in_interface.dart';

class GoogleManagerUserLogin extends AbstractManagerUserLogin {
  FirebaseAuth _auth;
  GoogleSignIn _googleSignIn;
  User _currentUser;

  GoogleManagerUserLogin() {
    this._auth = FirebaseAuth.instance;
    this._googleSignIn = GoogleSignIn();
  }

  @override
  User getCurrentUser() {
    return this._currentUser;
  }

  @override
  Future<void> signIn() async {
    // Trigger the authentication flow
    final GoogleSignInAccount googleUser = await _googleSignIn.signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final GoogleAuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Once signed in, return the UserCredential
    final UserCredential authResult =
        await _auth.signInWithCredential(credential);
    this._currentUser = authResult.user;

    // FIXME(vincenzopalazzo): Remove the code from this assert
    assert(!this._currentUser.isAnonymous);
    assert(await this._currentUser.getIdToken() != null);

    final User currentUser = _auth.currentUser;
    // FIXME(vincenzopalazzo): Remove the code from this assert
    assert(this._currentUser.uid == currentUser.uid);

    // return 'signInWithGoogle succeeded: $user';
  }

  @override
  Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}
