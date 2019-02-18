import 'package:flutter/material.dart';
import '../entity/plan_entity.dart';
import '../entity/plan_book_entity.dart';
import '../db/read_plan_db.dart';
import '../event/event_bus.dart';

class PlanDetail extends StatefulWidget {
  final PlanEntity planEntity;

  PlanDetail({Key key, @required this.planEntity}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new PlanDetailPage(planEntity);
}

class PlanDetailPage extends State<PlanDetail> {
  final EventBus eventBus = new EventBus();
  final PlanEntity planEntity;
  final DBManager dbManager = new DBManager();
  List<PlanBookEntity> planBookList;
  bool isLoading = true;

  PlanDetailPage(this.planEntity);

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
        isLoading = false;
        planBooks.sort();
        this.planBookList = planBooks;
      });
    });
  }

  final addBookNameController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 2,
        backgroundColor: Colors.black87,
        title: new Text(
          planEntity.name,
        ),
      ),
      body: new Column(
        children: <Widget>[
          new Container(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20),
            child: new ListTile(
              title: Text('阅读目标本数'),
              subtitle: Text(
                planEntity.total.toString(),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          new Divider(indent: 36),
          new Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: new ListTile(
              title: Text('已读本数'),
              subtitle: Text(
                planEntity.current.toString(),
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          new Divider(indent: 36),
          new Container(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: new ListTile(
              title: Text('结束时间'),
              subtitle: Text(
                planEntity.endDate,
                style: TextStyle(fontSize: 18),
              ),
            ),
          ),
          new Divider(indent: 36),
          new Container(
            padding: const EdgeInsets.only(left: 36, right: 20, top: 10),
            alignment: Alignment.centerLeft,
            child: Text(
              '书单',
              style: TextStyle(fontSize: 16),
            ),
          ),
          new Divider(indent: 36),
          new Card(
              margin: const EdgeInsets.only(right: 20, left: 20, bottom: 10),
              child: new Container(
                  child: new ListTile(
                      leading: Icon(Icons.add),
                      title: new TextField(
                        controller: addBookNameController,
                        decoration:
                            InputDecoration.collapsed(hintText: '添加书籍名称...'),
                        onSubmitted: (text) {
                          dbManager.insertBook(planEntity.id, text, '');
                          setState(() {
                            requestPlanBooks();
                          });
                          addBookNameController.text = '';
                        },
                      )))),
          new Expanded(
            child: planBookList == null || planBookList.length == 0
                ? Text('')
                : booksView(),
          )
        ],
      ),
    );
  }

  Widget booksView() {
    return new ListView.builder(
      itemCount: planBookList.length,
      itemBuilder: (context, index) {
        return new Card(
            margin: const EdgeInsets.only(right: 20, left: 20, bottom: 5),
            child: new Container(
              child: new CheckboxListTile(
                controlAffinity: ListTileControlAffinity.leading,
                title: new Text(
                  planBookList[index].title,
                  style: TextStyle(
                      decoration: planBookList[index].isRead == 1
                          ? TextDecoration.lineThrough
                          : TextDecoration.none),
                ),
                subtitle: planBookList[index].doneDate.isNotEmpty
                    ? Text('结束时间：${planBookList[index].doneDate}')
                    : null,
                value: planBookList[index].isRead == 1,
                onChanged: (bool value) {
                  if (!value) return;
                  dbManager.updatePlanBookRead(planBookList[index].id);
                  dbManager.updatePlanCurrent(planBookList[index].planId);
                  eventBus.emit('updatePlanList');
                  setState(() {
                    requestPlanBooks();
                    planEntity.current++;
                  });
                },
              ),
            ));
      },
    );
  }
}
