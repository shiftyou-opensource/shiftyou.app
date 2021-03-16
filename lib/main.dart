import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:nurse_time/actions/google_sign_in.dart';
import './view/login_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setUpInjector();
  runApp(MyApp());
}

void setUpInjector() {
  GetIt.instance.registerLazySingleton<GoogleManagerUserLogin>(
      () => GoogleManagerUserLogin());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nurse Time',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color.fromARGB(255, 242, 246, 255),
        backgroundColor: Color.fromARGB(255, 242, 246, 255),
        cardColor: Color.fromARGB(255, 242, 246, 255),
        buttonColor: Colors.deepPurpleAccent,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: LoginView(),
    );
  }
}
