import 'package:firebase_auth/firebase_auth.dart';

abstract class AbstractManagerUserLogin {
  Future<void> signIn();
  Future<void> signOut();
  User getCurrentUser();
}
