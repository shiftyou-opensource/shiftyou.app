import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/actions/google_sign_in.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/app_preferences.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/home/home_view.dart';
import 'package:nurse_time/view/settings/set_up_view.dart';
import 'view/login/login_view.dart';
import 'model/user_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await AppPreferences.instance
      .putValue(PreferenceKey.BRUTE_MIGRATION_DB, true, override: false);
  await setUpInjector();
  runApp(MyApp());
}

Future<void> setUpInjector() async {
  GetIt.instance.registerLazySingleton<GoogleManagerUserLogin>(
      () => GoogleManagerUserLogin());
  var db = DAODatabase();
  await db.init();
  GetIt.instance.registerSingleton<DAODatabase>(db);
  GetIt.instance.registerLazySingleton<Logger>(() => Logger());
  //TODO Review the database rules here
  GetIt.instance.registerLazySingleton<UserModel>(
      () => UserModel(id: -1, name: "", logged: false, initialized: false));
  GetIt.instance.registerLazySingleton<ShiftScheduler>(
      () => ShiftScheduler(-1, DateTime.now(), DateTime.now()));

  List<SchedulerRules> schedulerRules = List.empty(growable: true);
  var custom = SchedulerRules("Weekly Cadence", false);
  schedulerRules.add(custom);
  var manual = SchedulerRules("Up to you", false);
  manual.manual = true;
  schedulerRules.add(manual);
  GetIt.instance.registerSingleton<List<SchedulerRules>>(schedulerRules);
}

class MyApp extends StatelessWidget {
  Future<bool> checkUser(context) async {
    var dao = GetIt.instance.get<DAODatabase>();
    var logger = GetIt.instance.get<Logger>();
    try {
      var user = await dao.getUser();
      if (user == null) {
        logger.d("User not in database");
        return false;
      }
      var userModel = GetIt.instance.get<UserModel>();
      logger.d("User in database ${userModel.toString()}");
      userModel.initialized = user.initialized;
      userModel.logged = true;
      userModel.name = user.name;
      userModel.id = user.id;
      var shift = await dao.getShift(user.id);
      logger.d("Shift from database is ${shift.toString()}");
      var shiftInstance = GetIt.instance.get<ShiftScheduler>();
      shiftInstance.userId = user.id;
      if (shift != null) {
        logger.d("The user has a Shift stored in the database");
        shiftInstance.fromShift(shift);
      } else {
        // Init inside the db the null shift
        // after that we can call only update on the shift scheduler
        shiftInstance.notify();
        shiftInstance.id = await dao.insertShift(shiftInstance);
      }
      return true;
    } catch (e, stacktrace) {
      showSnackBar(context, "Error with the Database");
      logger.e(e);
      logger.e(stacktrace);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Your Shift',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromARGB(255, 40, 42, 54),
        backgroundColor: Color.fromARGB(255, 40, 42, 54),
        cardColor: Color.fromARGB(255, 40, 42, 54),
        accentColor: Color.fromARGB(255, 255, 121, 197),
        buttonColor: Color.fromARGB(255, 57, 60, 75),
        selectedRowColor: Color.fromARGB(255, 72, 79, 114),
        dialogBackgroundColor: Color.fromARGB(255, 40, 42, 54),
        disabledColor: Color.fromARGB(255, 98, 114, 164),
        canvasColor: Color.fromARGB(255, 40, 42, 54),
        toggleableActiveColor: Color.fromARGB(255, 255, 121, 197),
        unselectedWidgetColor: Color.fromARGB(255, 98, 114, 164),
        colorScheme: ColorScheme.dark(
          background: Color.fromARGB(255, 40, 42, 54),
          onPrimary: Color.fromARGB(255, 40, 42, 54),
          primary: Color.fromARGB(255, 255, 121, 197),
        ),
        inputDecorationTheme: InputDecorationTheme(
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color.fromARGB(255, 98, 114, 164))),
          focusedBorder: OutlineInputBorder(
              borderSide:
                  BorderSide(color: Color.fromARGB(255, 255, 121, 197))),
          labelStyle: TextStyle(color: Color.fromARGB(255, 98, 114, 164)),
        ),
        textTheme: TextTheme(
          bodyText1: TextStyle(),
          bodyText2: TextStyle(),
          headline5: TextStyle(fontWeight: FontWeight.bold),
          caption: TextStyle(fontStyle: FontStyle.normal, fontSize: 13),
        ).apply(
          bodyColor: Color.fromARGB(255, 98, 114, 164),
          decorationColor: Color.fromARGB(255, 98, 114, 164),
        ),
        iconTheme: Theme.of(context).iconTheme.copyWith(
              color: Color.fromARGB(255, 98, 114, 164),
            ),
        appBarTheme: AppBarTheme(
          color: Color.fromARGB(255, 40, 42, 54),
        ),
        //visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      routes: {
        "/home": (context) => HomeView(),
        "/setting": (context) => SetUpView(
            schedulerRules: GetIt.instance.get<List<SchedulerRules>>(),
            onUpdate: (index) {
              if (!GetIt.instance.isRegistered<SchedulerRules>())
                GetIt.instance.registerSingleton<SchedulerRules>(
                    GetIt.instance.get<List<SchedulerRules>>()[index]);
            })
      },
      home: FutureBuilder<bool>(
        future: checkUser(context),
        builder: (context, result) {
          if (result.data == true) {
            return HomeView();
          }
          return LoginView();
        },
      ),
    );
  }
}
