import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'plan_detail.dart';
import 'create_plan.dart';
import '../entity/plan_entity.dart';
import 'dart:ui';
import '../db/read_plan_db.dart';
import 'dart:io';
import '../event/event_bus.dart';

class HomeApp extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  int lastBackClick = 0;
  Future<bool> _willPopCallback() async {
    int now = DateTime.now().millisecondsSinceEpoch;
    if (now - lastBackClick > 1500) {
      lastBackClick = DateTime.now().millisecondsSinceEpoch;
      showInSnackBar('再按一次退出应用');
      return false;
    } else {
      exit(0);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new WillPopScope(
      child: Scaffold(key: _scaffoldKey, body: new HomeAppPage()),
      onWillPop: _willPopCallback,
    );
  }
}

class HomeAppPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => new HomeAppBgPage();
}

class HomeAppBgPage extends State<HomeAppPage> {
  @override
  Widget build(BuildContext context) {
    return new Stack(children: <Widget>[
      new Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
              fit: BoxFit.cover,
              image: AssetImage('images/home_default_bg.jpg')),
        ),
      ),
      new Container(
          child: new BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
        child: Opacity(
          opacity: 0.7,
          child: new Container(
            decoration: new BoxDecoration(
              color: Colors.black87,
            ),
          ),
        ),
      )),
      new _HomeAppPage(),
    ]);
  }
}

class _HomeAppPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        backgroundColor: Colors.transparent,
        appBar: new AppBar(
          elevation: 0,
          leading: Icon(null),
          backgroundColor: Colors.transparent,
          title: new Text('阅读计划'),
          centerTitle: true,
          actions: <Widget>[
            IconButton(
              icon: Icon(
                Icons.add,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () => Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) => new CreatePlan(),
                  )),
            )
          ],
        ),
        body: new Stack(
          children: <Widget>[new HomePage()],
        ));
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
                    child: new Image.asset(
                      'images/home_default_avatar.png',
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
  bool isLoading = true;
  final EventBus eventBus = new EventBus();
  List<PlanEntity> planList;

  @override
  void initState() {
    super.initState();
    getPlanList();
    eventBus.on('updatePlanList', (arg) {
      getPlanList();
    });
  }

  @override
  void dispose() {
    eventBus.off('updatePlanList');
    super.dispose();
  }

  void getPlanList() {
    print('plan list request.');
    DBManager dbManager = new DBManager();
    Future<List<PlanEntity>> res = dbManager.getPlanInfo();
    res.then((List<PlanEntity> planList) {
      setState(() {
        isLoading = false;
        this.planList = planList;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.fromSize(child: _normalPageView());
  }

  PageView _normalPageView() {
    return PageView.builder(
      controller: PageController(viewportFraction: 0.8),
      itemCount: _itemCount(),
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
              if (isLoading || isPlanEmpty()) return;
              Navigator.push(
                  context,
                  new MaterialPageRoute(
                    builder: (context) =>
                        new PlanDetail(planEntity: planList[index]),
                  ));
            },
            child: new Material(
              elevation: 5.0,
              child: _widget(index),
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
        );
      },
    );
  }

  int _itemCount() {
    if (isLoading || planList == null || planList.length == 0) {
      return 1;
    } else {
      return planList.length;
    }
  }

  bool isPlanEmpty() {
    return planList == null || planList.length == 0;
  }

  Widget _widget(int index) {
    if (isLoading) {
      return _loadingView();
    } else if (isPlanEmpty()) {
      return _emptyView();
    } else {
      return _planView(index);
    }
  }

  Widget _planView(int index) {
    return Stack(
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
                        fontSize: 16.0, color: new Color(0xff666666)),
                  ),
                )
              ],
            ),
            new Row(
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(left: 20),
                  child: new Text(
                    planList[index].endDate,
                    style: new TextStyle(
                        fontSize: 16.0, color: new Color(0xff666666)),
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
                  padding: const EdgeInsets.only(left: 20, bottom: 5),
                  child: new Text(
                    planList[index].name,
                    style: new TextStyle(fontSize: 26),
                  ),
                )
              ],
            ),
            new Row(
              children: <Widget>[
                Expanded(
                  child: Container(
                    padding: EdgeInsets.only(bottom: 25, left: 20, right: 10),
                    child: SizedBox(
                        height: 3,
                        child: new LinearProgressIndicator(
                          value:
                              planList[index].current / planList[index].total,
                          backgroundColor: Color(0xffeeeeee),
                        )),
                  ),
                ),
                Container(
                    padding: EdgeInsets.only(bottom: 25, right: 20),
                    child: Text(
                      "${planList[index].current}/${planList[index].total}",
                      style: new TextStyle(
                          fontSize: 12, color: new Color(0xff949495)),
                    )),
              ],
            )
          ],
        ),
      ],
    );
  }

  Widget _emptyView() {
    return new Center(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new Text(
            '还没有创建计划',
            style: TextStyle(color: Color(0xff999999), fontSize: 14),
          ),
          new Container(
            padding: EdgeInsets.only(top: 10),
            child: new Text(
              '点击+创建你的读书计划吧',
              style: TextStyle(color: Color(0xff999999), fontSize: 12),
            ),
          )
        ],
      ),
    );
  }

  Widget _loadingView() {
    return new Center(
      child: new CircularProgressIndicator(),
    );
  }
}
