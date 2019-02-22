import 'package:flutter/material.dart';
import '../entity/plan_entity.dart';
import '../entity/plan_book_entity.dart';
import '../db/read_plan_db.dart';
import '../event/event_bus.dart';
import 'package:intl/intl.dart';

class PlanDetailPanel extends StatefulWidget {
  final AnimationController controller;
  final PlanEntity planEntity;

  PlanDetailPanel({this.controller, this.planEntity});

  @override
  _PlanDetailPanelState createState() =>
      new _PlanDetailPanelState(planEntity: planEntity);
}

class _PlanDetailPanelState extends State<PlanDetailPanel> {
  static const header_height = 32.0;
  final EventBus eventBus = new EventBus();
  final DBManager dbManager = new DBManager();
  final PlanEntity planEntity;
  final addBookNameController = TextEditingController();
  List<PlanBookEntity> planBookList;

  _PlanDetailPanelState({this.planEntity});

  @override
  void initState() {
    super.initState();
    requestPlanBooks();
  }

  void requestPlanBooks() {
    print('plan book list request.');
    Future<List<PlanBookEntity>> res = dbManager.getPlanBook(planEntity.id);
    res.then((List<PlanBookEntity> planBooks) {
      setState(() {
        planBooks.sort();
        this.planBookList = planBooks;
      });
    });
  }

  Animation<RelativeRect> getPanelAnimation(BoxConstraints constraints) {
    final height = constraints.biggest.height;
    final backPanelHeight = height - header_height;
    final frontPanelHeight = -header_height;

    return new RelativeRectTween(
      begin: new RelativeRect.fromLTRB(
          0.0, backPanelHeight, 0.0, frontPanelHeight),
      end: new RelativeRect.fromLTRB(0.0, 0.0, 0.0, 0.0),
    ).animate(
        new CurvedAnimation(parent: widget.controller, curve: Curves.linear));
  }

  Widget planDetailPanel(BuildContext context, BoxConstraints constraints) {
    final ThemeData themeData = Theme.of(context);

    return new Container(
      child: new Stack(
        children: <Widget>[
          new Container(
              color: themeData.accentColor,
              child: new Column(children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
                  child: new ListTile(
                    title: Text(
                      '阅读目标本数',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      planEntity.total.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                new Divider(
                  indent: 36,
                  color: Colors.white,
                ),
                new Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: new ListTile(
                    title: Text(
                      '已读本数',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      planEntity.current.toString(),
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                new Divider(
                  indent: 36,
                  color: Colors.white,
                ),
                new Container(
                  padding: const EdgeInsets.only(left: 20, right: 20),
                  child: new ListTile(
                    title: Text(
                      '结束时间',
                      style: TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      planEntity.endDate,
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
              ])),
          new PositionedTransition(
              rect: getPanelAnimation(constraints),
              child: new Material(
                elevation: 12.0,
                child: new Column(
                  children: <Widget>[
                    new Expanded(
                      child: booksView(),
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }

  Widget booksView() {
    return new ListView.builder(
      itemCount: planBookList == null ? 1 : planBookList.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return new Card(
              color: Color(0xFFF6F6F6),
              margin: const EdgeInsets.only(
                  right: 20, left: 20, bottom: 15, top: 20),
              child: new Container(
                  child: new ListTile(
                      leading: Icon(Icons.add),
                      title: new TextField(
                        controller: addBookNameController,
                        decoration:
                            InputDecoration.collapsed(hintText: '添加图书名称...'),
                        onSubmitted: (text) {
                          dbManager.insertBook(planEntity.id, text, '');
                          setState(() {
                            requestPlanBooks();
                          });
                          addBookNameController.text = '';
                        },
                      ))));
        } else {
          int i = index - 1;
          return new Dismissible(
            key: new Key(planBookList[i].id.toString()),
            onDismissed: (direction) async {
              await dbManager.deletePlanBook(planBookList[i].id);
              if (planBookList[i].isRead == 1) {
                await dbManager.updatePlanCurrent(planBookList[i].planId);
                eventBus.emit('updatePlanList');
                setState(() {
                  planEntity.current--;
                });
              }
              planBookList.removeAt(i);
            },
            child: new Card(
                margin: const EdgeInsets.only(right: 20, left: 20, bottom: 5),
                child: new Container(
                  child: new CheckboxListTile(
                    controlAffinity: ListTileControlAffinity.leading,
                    title: new Text(
                      planBookList[i].title,
                      style: TextStyle(
                          decoration: planBookList[i].isRead == 1
                              ? TextDecoration.lineThrough
                              : TextDecoration.none),
                    ),
                    subtitle: planBookList[i].doneDate.isNotEmpty
                        ? new Row(
                            children: <Widget>[
                              Text('结束时间：${planBookList[i].doneDate}'),
                              Padding(
                                padding: EdgeInsets.only(left: 10),
                              ),
                              InkWell(
                                child: Text(
                                  '修改',
                                  style: TextStyle(color: Colors.blue),
                                ),
                                onTap: () {
                                  _selectDate(context, planBookList[i].id);
                                },
                              )
                            ],
                          )
                        : null,
                    value: planBookList[i].isRead == 1,
                    onChanged: (bool value) async {
                      if (!value) return;
                      await dbManager.updatePlanBookRead(planBookList[i].id);
                      await dbManager.updatePlanCurrent(planBookList[i].planId);
                      eventBus.emit('updatePlanList');
                      setState(() {
                        requestPlanBooks();
                        planEntity.current++;
                      });
                    },
                  ),
                )),
          );
        }
      },
    );
  }

  var _time;

  Future<Null> _selectDate(BuildContext context, int id) async {
    var firstDate = DateTime(2018, 1, 1);
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
      dbManager.updatePlanBookDoneDate(id, _time);
      requestPlanBooks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return new LayoutBuilder(
      builder: planDetailPanel,
    );
  }
}
