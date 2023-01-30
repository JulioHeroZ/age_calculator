import 'package:age_calculator/firebase_options.dart';
import 'package:age_calculator/views/home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:localization/localization.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'constant/color.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

final FlutterLocalization localization = FlutterLocalization.instance;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: primaryColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark));

  runApp(MyApp());
}

/// the setState function here is a must to add

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      debugShowCheckedModeBanner: false,
      title: 'Aniversariantes DVIP',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        colorScheme: ColorScheme.light(
          primary: primaryColor, // header background color
          onPrimary: textColor, // header text color
          onSurface: textColor, // body text color
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            primary: secondaryColor, // button text color
          ),
        ),
      ),
      home: HomePage(),
    );
  }
}
