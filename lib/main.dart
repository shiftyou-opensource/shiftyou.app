import 'dart:ui';

import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:nurse_time/actions/auth/auth_provider.dart';
import 'package:nurse_time/localization/app_localizzation.dart';
import 'package:nurse_time/model/scheduler_rules.dart';
import 'package:nurse_time/model/shift_scheduler.dart';
import 'package:nurse_time/persistence/dao_database.dart';
import 'package:nurse_time/utils/app_preferences.dart';
import 'package:nurse_time/utils/generic_components.dart';
import 'package:nurse_time/view/home/home_view.dart';
import 'package:nurse_time/view/settings/set_up_view.dart';

import 'view/login/login_view.dart';
import 'model/user_model.dart';
import 'localization/keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitDown,
    DeviceOrientation.portraitUp,
  ]);
  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en', supportedLocales: ['en', 'it']);
  await Firebase.initializeApp();
  await AppPreferences.instance
      .putValue(PreferenceKey.BRUTE_MIGRATION_DB, true, override: false);
  await setUpInjector();
  runApp(LocalizedApp(delegate, MyApp()));
}

Future<void> setUpInjector() async {
  var db = DAODatabase();
  await db.init();
  GetIt.instance.registerSingleton<DAODatabase>(db);
  GetIt.instance.registerLazySingleton<Logger>(() => Logger());
  //TODO Review the database rules here
  GetIt.instance.registerLazySingleton<UserModel>(
      () => UserModel(name: "", email: "", logged: false, initialized: false));
  GetIt.instance.registerLazySingleton<ShiftScheduler>(
      () => ShiftScheduler(-1, DateTime.now(), DateTime.now()));

  List<SchedulerRules> schedulerRules = List.empty(growable: true);
  var custom = SchedulerRules(
      AppLocalization.getWithKey(Keys.Scheduler_Name_Weekly_Cadence), false);
  schedulerRules.add(custom);
  var manual = SchedulerRules(
      AppLocalization.getWithKey(Keys.Scheduler_Name_Up_To_You), false);
  manual.manual = true;
  schedulerRules.add(manual);
  GetIt.instance.registerSingleton<List<SchedulerRules>>(schedulerRules);

  if (await AppPreferences.instance.containsKey(PreferenceKey.LOGIN_PROVIDER)) {
    var provider = await AppPreferences.instance
        .valueWithKey(PreferenceKey.LOGIN_PROVIDER) as String;
    var authProvider = AuthProvider.build(provider: provider);
    GetIt.instance.registerSingleton<AuthProvider>(authProvider);
  }
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
      logger.w("User in database first startup $user");
      userModel.bind(user);
      logger.w("UserModel after binding $user");
      var shift = await dao.getShift(user.id!);
      logger.i("Shift from database is $shift");
      var shiftInstance = GetIt.instance.get<ShiftScheduler>();
      shiftInstance.userId = user.id!;
      if (shift != null) {
        logger.d("The user has a Shift stored in the database");
        shiftInstance.fromShift(shift).notify();
      } else {
        // Init inside the db the null shift
        // after that we can call only update on the shift scheduler
        shiftInstance.notify();
        shiftInstance.id = await dao.insertShift(shiftInstance);
      }
      logger.d("User is logged -> ${userModel.logged}");
      logger.d("ShiftScheduler have following payload -> $shiftInstance");
      return userModel.logged;
    } catch (e, stacktrace) {
      showSnackBar(context, AppLocalization.getWithKey(Keys.Errors_Db_Errors));
      logger.e(e);
      logger.e(stacktrace);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return LocalizationProvider(
        state: LocalizationProvider.of(context).state,
        child: MaterialApp(
          title: AppLocalization.getWithKey(Keys.App_Bar_Title),
          debugShowCheckedModeBanner: false,
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            localizationDelegate
          ],
          supportedLocales: localizationDelegate.supportedLocales,
          themeMode: ThemeMode.dark,
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primaryColor: Color.fromARGB(255, 40, 42, 54),
            backgroundColor: Color.fromARGB(255, 40, 42, 54),
            cardColor: Color.fromARGB(255, 40, 42, 54),
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
              secondary: Color.fromARGB(255, 40, 42, 54),
              primaryVariant: Color.fromARGB(255, 57, 60, 75),
            ),
            inputDecorationTheme: InputDecorationTheme(
              enabledBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 98, 114, 164))),
              focusedBorder: OutlineInputBorder(
                  borderSide:
                      BorderSide(color: Color.fromARGB(255, 255, 121, 197))),
              labelStyle: TextStyle(color: Color.fromARGB(255, 98, 114, 164)),
              prefixStyle: TextStyle(color: Color.fromARGB(255, 98, 114, 164)),
              suffixStyle: TextStyle(color: Color.fromARGB(255, 98, 114, 164)),
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
            "/login": (context) => LoginView(),
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
        ));
  }
}
