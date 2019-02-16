import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../db/read_plan_db.dart';
import 'plan_detail.dart';
import '../entity/plan_entity.dart';

class CreatePlan extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => CreatePlanState();
}

class CreatePlanState extends State<CreatePlan> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  TextEditingController nameEditController = TextEditingController();
  TextEditingController numEditController = TextEditingController();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        backgroundColor: Colors.white,
        appBar: new AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () => Navigator.of(context).pop('/create_plan'),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
          title: new Text(
            '新建计划',
            style: TextStyle(color: Colors.black),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Color(0xff0095D9),
          child: FlatButton(
            child: new Text(
              '完成',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            onPressed: () {
              if (nameEditController.text == null ||
                  nameEditController.text.trim().isEmpty) {
                showInSnackBar("请输入名称");
              } else if (numEditController.text == null ||
                  numEditController.text.trim().isEmpty) {
                showInSnackBar("请输入数量");
              } else if (_time == null || _time == "") {
                showInSnackBar("请选择结束日期");
              } else {
                DBManager dbManager = new DBManager();
                Future<int> res = dbManager.insertPlanInfo(
                    nameEditController.text,
                    int.parse(numEditController.text),
                    0,
                    _time);
                res.then((int id) {
                  Navigator.pushAndRemoveUntil(
                      context,
                      new MaterialPageRoute(
                        builder: (context) => new PlanDetail(
                            planEntity: PlanEntity.formParams(
                                1,
                                nameEditController.text,
                                int.parse(numEditController.text),
                                0,
                                _time)),
                      ),
                      ModalRoute.withName('/home'));
                });
              }
            },
          ),
        ),
        body: new Stack(children: <Widget>[
          new Column(
            children: <Widget>[
              new Column(
                children: <Widget>[
                  new Container(
                    padding: new EdgeInsets.only(top: 50),
                    child: new ListTile(
                      leading: Icon(Icons.bookmark),
                      title: new TextField(
                        controller: nameEditController,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: Color(0xff666666)),
                            helperText: '给自己的读书计划起个名字',
                            labelText: '名称'),
                        autofocus: false,
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ),
                  new Container(
                    child: new ListTile(
                      leading: Icon(Icons.confirmation_number),
                      title: new TextField(
                        controller: numEditController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: Color(0xff666666)),
                            helperText: '打算搞定多少本书',
                            labelText: '数量'),
                        autofocus: false,
                        inputFormatters: [
                          WhitelistingTextInputFormatter.digitsOnly
                        ],
                        textInputAction: TextInputAction.done,
                      ),
                    ),
                  ),
                  new Container(
                    child: new ListTile(
                      leading: const Icon(Icons.timer),
                      title: const Text(
                        '结束日期',
                        style: TextStyle(color: Color(0xff666666)),
                      ),
                      subtitle: Text(
                        _time == null || _time == 'null'
                            ? '给计划设置一个结束时间'
                            : _time,
                        style: TextStyle(fontSize: 12),
                      ),
                      onTap: () => _selectDate(context),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ]));
  }

  var _time;

  Future<Null> _selectDate(BuildContext context) async {
    var firstDate = DateTime.now().add(new Duration(days: 6));
    var initialDate = DateTime.now().add(new Duration(days: 7));
    final DateTime _picked = await showDatePicker(
        context: context,
        firstDate: firstDate,
        initialDate: initialDate,
        lastDate:
            DateTime(initialDate.year + 2, initialDate.month, initialDate.day));

    setState(() {
      var formatter = new DateFormat('yyyy年MM月dd日');
      _time = formatter.format(_picked);
    });
  }
}
