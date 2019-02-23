import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import '../db/read_plan_db.dart';
import 'plan_detail.dart';
import '../entity/plan_entity.dart';
import '../event/event_bus.dart';

class CreatePlan extends StatefulWidget {
  final PlanEntity planEntity;

  CreatePlan({this.planEntity});

  @override
  State<StatefulWidget> createState() =>
      CreatePlanState(planEntity: planEntity);
}

class CreatePlanState extends State<CreatePlan> {
  final EventBus eventBus = new EventBus();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PlanEntity planEntity;

  CreatePlanState({this.planEntity});

  TextEditingController nameEditController = TextEditingController();
  TextEditingController numEditController = TextEditingController();

  void showInSnackBar(String message) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text(message),
    ));
  }

  @override
  void initState() {
    super.initState();
    if (planEntity != null) {
      nameEditController.text = planEntity.name;
      numEditController.text = planEntity.total.toString();
      _time = planEntity.endDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        key: _scaffoldKey,
        appBar: new AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop('/create_plan'),
          ),
          elevation: 2,
          backgroundColor: Colors.black87,
          title: new Text(
            planEntity == null ? '新建计划' : '编辑计划',
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.black87,
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
                if (planEntity == null) {
                  createPlan();
                } else {
                  editPlan();
                }
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
                    padding: new EdgeInsets.only(top: 20),
                    child: new ListTile(
                      leading: Icon(Icons.bookmark),
                      title: new TextField(
                        controller: nameEditController,
                        decoration: InputDecoration(
                            labelStyle: TextStyle(color: Color(0xff666666)),
                            helperText: '给自己的阅读计划起个名字',
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
    var formatter = new DateFormat('yyyy年MM月dd日');
    var firstDate = DateTime.now().add(new Duration(days: 6));
    var initialDate = _time == null
        ? DateTime.now().add(new Duration(days: 7))
        : formatter.parse(_time);
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

  void createPlan() {
    DBManager dbManager = new DBManager();
    Future<int> res = dbManager.insertPlanInfo(
        nameEditController.text, int.parse(numEditController.text), 0, _time);
    res.then((int id) {
      eventBus.emit('updatePlanList');
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
            builder: (context) => new PlanDetail(
                planEntity: PlanEntity.formParams(id, nameEditController.text,
                    int.parse(numEditController.text), 0, _time)),
          ),
          ModalRoute.withName('/home'));
    });
  }

  void editPlan() {
    DBManager dbManager = new DBManager();
    var _planEntity = PlanEntity.formParams(
        planEntity.id,
        nameEditController.text,
        int.parse(numEditController.text),
        planEntity.current,
        _time);
    Future<int> res = dbManager.updatePlanInfo(_planEntity);
    res.then((int row) {
      eventBus.emit('updatePlanList');
      Navigator.pushAndRemoveUntil(
          context,
          new MaterialPageRoute(
            builder: (context) => new PlanDetail(planEntity: _planEntity),
          ),
          ModalRoute.withName('/home'));
    });
  }
}
