import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/actions/google_sign_in.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import './view/login_view.dart';
import 'model/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setUpInjector();
  runApp(MyApp());
}

void setUpInjector() {
  GetIt.instance.registerLazySingleton<GoogleManagerUserLogin>(
      () => GoogleManagerUserLogin());
  GetIt.instance.registerSingleton<DAODatabase>(DAODatabase());
  GetIt.instance.registerLazySingleton<Logger>(() => Logger());
  GetIt.instance.registerLazySingleton<UserModel>(
      () => UserModel(id: -1, name: "", logged: false, initialized: false));
  GetIt.instance.registerLazySingleton<ShiftScheduler>(
      () => ShiftScheduler(DateTime.now(), DateTime.now()));
}

class MyApp extends StatelessWidget {
  Future<bool> checkUser() async {
    var dao = GetIt.instance.get<DAODatabase>();
    var logger = GetIt.instance.get<Logger>();
    await dao.init();
    var user = await dao.getUser();
    if (user == null) {
      logger.d("User not in database");
      return false;
    }
    logger.d("User in database");
    var userModel = GetIt.instance.get<UserModel>();
    userModel.initialized = user.initialized;
    userModel.logged = true;
    userModel.name = user.name;
    userModel.id = user.id;
    return true;
  }

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
      home: FutureBuilder<bool>(
        future: checkUser(),
        builder: (context, result) {
          /*if (result.data == true) {
            return HomeView();
          } else {
            return LoginView();
          }*/
          return LoginView();
        },
      ),
    );
  }
}
