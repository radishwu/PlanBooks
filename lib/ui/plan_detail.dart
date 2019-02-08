import 'package:flutter/material.dart';
import '../entity/plan_entity.dart';
import '../entity/book_entity.dart';

class PlanDetail extends StatefulWidget {
  final PlanEntity planEntity;

  PlanDetail({Key key, @required this.planEntity}) : super(key: key);

  @override
  State<StatefulWidget> createState() => new PlanDetailPage(planEntity);
}

class PlanDetailPage extends State<PlanDetail> {
  final PlanEntity planEntity;

  PlanDetailPage(this.planEntity);

  var items = new List<BookEntity>.generate(
      20, (i) => new BookEntity('title $i', false));

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: Colors.white,
      appBar: new AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        title: new Text(
          planEntity.name,
          style: TextStyle(color: Colors.black),
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
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              new Container(
                padding: const EdgeInsets.only(left: 35),
                child: Text(
                  '书单',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              FlatButton(
                onPressed: () {},
                child: Text(
                  '添加',
                  style: TextStyle(fontSize: 16, color: Colors.blue),
                ),
              ),
            ],
          ),
          new Expanded(
            child: new ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return new Card(
                    margin:
                        const EdgeInsets.only(right: 20, left: 20, bottom: 10),
                    child: new Container(
                      child: new CheckboxListTile(
                        controlAffinity: ListTileControlAffinity.leading,
                        title: new Text(items[index].title),
                        value: items[index].isRead,
                        onChanged: (bool value) {
                          setState(() {
                            items[index].isRead = value;
                          });
                        },
                      ),
                    ));
              },
            ),
          )
        ],
      ),
    );
  }
}
