import 'package:flutter/material.dart';
import 'ui/home.dart';
import 'ui/create_plan.dart';

void main() => runApp(MaterialApp(
      home: new HomeApp(),
      routes: <String, WidgetBuilder>{
        '/create_plan': (BuildContext context) => new CreatePlan()
      },
    ));
