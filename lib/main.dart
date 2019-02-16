import 'package:flutter/material.dart';
import 'ui/home.dart';
import 'ui/create_plan.dart';
import 'ui/splash_screen.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/create_plan': (BuildContext context) => new CreatePlan(),
        '/home': (BuildContext context) => HomeApp(),
      },
    ));
