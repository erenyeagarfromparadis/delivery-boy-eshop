import 'dart:io';

import 'package:country_code_picker/country_localizations.dart';
import 'package:deliveryboy/Helper/Color.dart';
import 'package:deliveryboy/Helper/Constant.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Helper/PushNotificationService.dart';
import 'Helper/String.dart';
import 'Localization/Demo_Localization.dart';
import 'Localization/Language_Constant.dart';
import 'Provider/Theme.dart';
import 'Screens/Home.dart';
import 'Screens/Splash.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  final pushNotificationService = PushNotificationService();
  pushNotificationService.initialise();
  FirebaseMessaging.onBackgroundMessage(myForgroundMessageHandler);
  HttpOverrides.global = MyHttpOverrides();
  runApp(
    ChangeNotifierProvider<ThemeNotifier>(
      create: (BuildContext context) {
        String? theme = prefs.getString(APP_THEME);

        if (theme == DARK) {
          ISDARK = 'true';
        } else if (theme == LIGHT) {
          ISDARK = 'false';
        }

        if (theme == null || theme == '' || theme == DEFAULT_SYSTEM) {
          prefs.setString(APP_THEME, DEFAULT_SYSTEM);
          var brightness = SchedulerBinding.instance.window.platformBrightness;
          ISDARK = (brightness == Brightness.dark).toString();

          return ThemeNotifier(ThemeMode.system);
        }

        return ThemeNotifier(theme == LIGHT ? ThemeMode.light : ThemeMode.dark);
      },
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);

  static void setLocale(BuildContext context, Locale newLocale) {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>()!;
    state.setLocale(newLocale);
  }

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Locale? _locale;

  setLocale(Locale locale) {
    if (mounted) {
      setState(
        () {
          _locale = locale;
        },
      );
    }
  }

  @override
  void didChangeDependencies() {
    getLocale().then(
      (locale) {
        if (mounted) {
          setState(
            () {
              _locale = locale;
            },
          );
        }
      },
    );
    super.didChangeDependencies();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    return Selector<ThemeNotifier, ThemeMode>(
        selector: (_, themeProvider) => themeProvider.getThemeMode(),
        builder: (context, data, child) {
          print("data is $data");
          return MaterialApp(
            title: appName,
            theme: ThemeData(
              colorScheme:
                  ColorScheme.fromSwatch(primarySwatch: colors.primary_app)
                      .copyWith(brightness: Brightness.light),
              visualDensity: VisualDensity.adaptivePlatformDensity,
              canvasColor: Theme.of(context).colorScheme.lightWhite,
              cardColor: Theme.of(context).colorScheme.white,
              dialogBackgroundColor: Theme.of(context).colorScheme.white,
              iconTheme: Theme.of(context)
                  .iconTheme
                  .copyWith(color: Theme.of(context).colorScheme.primary),
              primarySwatch: colors.primary_app,
              primaryColor: Theme.of(context).colorScheme.lightWhite,
              fontFamily: 'opensans',
              textTheme: TextTheme(
                      headline6: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle1: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold))
                  .apply(bodyColor: Theme.of(context).colorScheme.fontColor),
            ),
            debugShowCheckedModeBanner: false,
            initialRoute: '/',
            locale: _locale,
            localizationsDelegates: const [
              CountryLocalizations.delegate,
              DemoLocalization.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale("en", "US"),
              Locale("zh", "CN"),
              Locale("es", "ES"),
              Locale("hi", "IN"),
              Locale("ar", "DZ"),
              Locale("ru", "RU"),
              Locale("ja", "JP"),
              Locale("de", "DE")
            ],
            localeResolutionCallback: (locale, supportedLocales) {
              for (var supportedLocale in supportedLocales) {
                if (supportedLocale.languageCode == locale!.languageCode &&
                    supportedLocale.countryCode == locale.countryCode) {
                  return supportedLocale;
                }
              }
              return supportedLocales.first;
            },
            routes: {
              '/': (context) => const Splash(),
              '/Screens/home': (context) => const Home(),
            },
            darkTheme: ThemeData(
              canvasColor: Theme.of(context).colorScheme.darkColor,
              cardColor: Theme.of(context).colorScheme.darkColor2,
              dialogBackgroundColor: Theme.of(context).colorScheme.darkColor2,
              primaryColor: Theme.of(context).colorScheme.darkColor,
              textSelectionTheme: TextSelectionThemeData(
                  cursorColor: Theme.of(context).colorScheme.lightfontColor,
                  selectionColor: Theme.of(context).colorScheme.lightfontColor,
                  selectionHandleColor:
                      Theme.of(context).colorScheme.lightfontColor),
              toggleableActiveColor: Theme.of(context).colorScheme.primary,
              fontFamily: 'ubuntu',
              brightness: Brightness.dark,
              hintColor: Theme.of(context).colorScheme.white,
              iconTheme: Theme.of(context)
                  .iconTheme
                  .copyWith(color: Theme.of(context).colorScheme.secondary),
              textTheme: TextTheme(
                      headline6: TextStyle(
                        color: Theme.of(context).colorScheme.fontColor,
                        fontWeight: FontWeight.w600,
                      ),
                      subtitle1: TextStyle(
                          color: Theme.of(context).colorScheme.fontColor,
                          fontWeight: FontWeight.bold))
                  .apply(bodyColor: Theme.of(context).colorScheme.fontColor),
              colorScheme: ColorScheme.fromSwatch(
                      primarySwatch: colors.primary_app)
                  .copyWith(brightness: Brightness.dark)
                  .copyWith(secondary: Theme.of(context).colorScheme.darkColor),
            ),
            themeMode: themeNotifier.getThemeMode(),
          );
        });
  }
}

class MyHttpOverrides extends HttpOverrides{
  @override
  HttpClient createHttpClient(SecurityContext? context){
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port)=> true;
  }
}
