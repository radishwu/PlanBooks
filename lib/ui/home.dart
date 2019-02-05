import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: '阅读计划',
        home: new Scaffold(
            backgroundColor: new Color(0xFF0095D9),
            appBar: new AppBar(
              elevation: 0,
              backgroundColor: Colors.transparent,
              title: new Text('阅读计划'),
            ),
            body: new Stack(
              children: <Widget>[new HomePage()],
            )));
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy年MM月dd日');
    var today = formatter.format(now);
    return new Container(
        padding: const EdgeInsets.only(top: 40),
        child: new Column(
          children: <Widget>[
            new Row(children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(left: 55),
                child: new ClipOval(
                  child: new SizedBox(
                    width: 60.0,
                    height: 60.0,
                    child: new Image.network(
                      "https://sfault-avatar.b0.upaiyun.com/206/120/2061206110-5afe2c9d40fa3_huge256",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ]),
            new Row(children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(left: 55, top: 20),
                child: new Text(
                  'Monster',
                  style: TextStyle(color: Colors.white, fontSize: 26),
                ),
              )
            ]),
            new Row(
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(left: 55, top: 64),
                  child: new Text("今天：" + today,
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                )
              ],
            ),
            new Expanded(
              child: CardPage(),
            )
          ],
        ));
  }
}

class CardPage extends StatefulWidget {
  @override
  CardPageState createState() => CardPageState();
}

class CardPageState extends State<CardPage> {
  bool isAddGradient = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.8),
        itemCount: 3,
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: 50.0,
              top: 16.0,
              left: 10.0,
              right: 10.0,
            ),
            child: GestureDetector(
              onTap: () {
                Scaffold.of(context).showSnackBar(SnackBar(
                  backgroundColor: Colors.deepOrangeAccent,
                  duration: Duration(milliseconds: 800),
                  content: Center(
                    child: Text(
                      "哈哈哈哈哈哈",
                      style: TextStyle(fontSize: 25.0),
                    ),
                  ),
                ));
              },
              child: new Material(
                elevation: 5.0,
                child: Stack(
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new Container(
                              padding: const EdgeInsets.only(left: 20, top: 30),
                              child: new Text(
                                "结束日期：",
                                style: new TextStyle(
                                    fontSize: 16.0,
                                    color: new Color(0xff666666)),
                              ),
                            )
                          ],
                        ),
                        new Row(
                          children: <Widget>[
                            new Container(
                              padding: const EdgeInsets.only(left: 20),
                              child: new Text(
                                "2019年12月31日",
                                style: new TextStyle(
                                    fontSize: 16.0,
                                    color: new Color(0xff666666)),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                    new Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        new Row(
                          children: <Widget>[
                            new Container(
                              padding:
                                  const EdgeInsets.only(left: 20, bottom: 5),
                              child: new Text(
                                "2019年读书计划",
                                style: new TextStyle(fontSize: 26),
                              ),
                            )
                          ],
                        ),
                        new Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(
                                    bottom: 25, left: 20, right: 10),
                                child: SizedBox(
                                    height: 3,
                                    child: new LinearProgressIndicator(
                                      value: 0.5,
                                      backgroundColor: Color(0xffeeeeee),
                                    )),
                              ),
                            ),
                            Container(
                                padding: EdgeInsets.only(bottom: 25, right: 20),
                                child: Text(
                                  "3/50",
                                  style: new TextStyle(
                                      fontSize: 12,
                                      color: new Color(0xff949495)),
                                )),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          );
        },
      ),
    );
  }
}
