import 'dart:async';

import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3),
        () => Navigator.popAndPushNamed(context, '/home'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          Container(
            decoration: BoxDecoration(color: Colors.white),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(''),
              ),
              Expanded(
                flex: 3,
                child: Container(
                  child: Column(
                    children: <Widget>[
                      SizedBox(
                        width: 100,
                        height: 100,
                        child: new Container(
                          decoration: new BoxDecoration(
                            image: new DecorationImage(
                                fit: BoxFit.cover,
                                image: AssetImage('images/plan_book_icon.png')),
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(top: 10.0),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      '计划书单',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.black),
                    ),
                    Padding(
                      padding: EdgeInsets.only(top: 5),
                    ),
                    Text(
                      '你的私人阅读计划',
                      softWrap: true,
                      textAlign: TextAlign.center,
                      style:
                          TextStyle(fontSize: 12.0, color: Color(0xff999999)),
                    )
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
