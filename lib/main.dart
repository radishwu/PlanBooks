import 'package:flutter/material.dart';
import 'ui/plan_home.dart';
import 'ui/create_plan.dart';
import 'ui/splash_screen.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: new ThemeData(
          primaryColor: Colors.black,
          cursorColor: Colors.black54,
          accentColor: Colors.black87),
      home: new SplashScreen(),
      routes: <String, WidgetBuilder>{
        '/create_plan': (BuildContext context) => new CreatePlan(),
        '/home': (BuildContext context) => PlanHome(),
      },
    ));
